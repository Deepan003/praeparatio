import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ── Environment variables (set in Supabase Dashboard → Settings → Secrets) ──
const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID")!;
const SERVICE_ACCOUNT = JSON.parse(Deno.env.get("FIREBASE_SERVICE_ACCOUNT")!);
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

// ── JWT helper for FCM v1 API auth ──────────────────────────────────────────

function base64url(data: string): string {
  return btoa(data).replace(/\+/g, "-").replace(/\//g, "_").replace(/=/g, "");
}

async function getAccessToken(): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = base64url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const payload = base64url(
    JSON.stringify({
      iss: SERVICE_ACCOUNT.client_email,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
    })
  );
  const signingInput = `${header}.${payload}`;

  // Import RSA private key
  const pem = SERVICE_ACCOUNT.private_key
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\n/g, "");
  const keyBytes = Uint8Array.from(atob(pem), (c) => c.charCodeAt(0));
  const key = await crypto.subtle.importKey(
    "pkcs8",
    keyBytes,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );
  const sig = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(signingInput)
  );
  const sigB64 = btoa(String.fromCharCode(...new Uint8Array(sig)))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=/g, "");
  const jwt = `${signingInput}.${sigB64}`;

  // Exchange JWT for access token
  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  const data = await res.json();
  if (!data.access_token) throw new Error(`Token exchange failed: ${JSON.stringify(data)}`);
  return data.access_token;
}

// ── FCM senders ──────────────────────────────────────────────────────────────

const FCM_URL = `https://fcm.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/messages:send`;

async function sendToTopic(
  topic: string,
  title: string,
  body: string,
  data: Record<string, string>,
  accessToken: string
) {
  const res = await fetch(FCM_URL, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      message: {
        topic,
        notification: { title, body },
        data,
        android: {
          priority: "high",
          notification: {
            sound: "default",
            channel_id: "praeparatio_default",
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
        },
      },
    }),
  });
  return res.json();
}

async function sendToToken(
  token: string,
  title: string,
  body: string,
  data: Record<string, string>,
  accessToken: string
) {
  const res = await fetch(FCM_URL, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      message: {
        token,
        notification: { title, body },
        data,
        android: {
          priority: "high",
          notification: {
            sound: "default",
            channel_id: "praeparatio_default",
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
        },
      },
    }),
  });
  return res.json();
}

// Sanitise batch name → safe FCM topic (matches Flutter side)
function batchTopic(batch: string): string {
  return `batch_${batch.trim().replace(/[^a-zA-Z0-9_-]/g, "_")}`;
}

// ── Main handler ─────────────────────────────────────────────────────────────

serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  try {
    const payload = await req.json();

    // Supabase database webhook payload: { type, table, schema, record, old_record }
    const notification = payload.record ?? payload;
    const { type, title, body, data, target_type, target_batches, target_student_id } = notification;

    if (!title || !body) {
      return new Response(JSON.stringify({ skip: "no title/body" }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    // FCM data payload — stringified for Android compatibility
    const fcmData: Record<string, string> = {
      type:  type        ?? "announcement",
      route: data?.route ?? "/student/dashboard",
      title: title       ?? "",
      body:  body        ?? "",
    };

    const accessToken = await getAccessToken();
    const results = [];

    if (target_type === "all") {
      // One call → FCM fans out to all subscribers of this topic
      const r = await sendToTopic("all_students", title, body, fcmData, accessToken);
      results.push(r);

    } else if (target_type === "batch" && Array.isArray(target_batches) && target_batches.length > 0) {
      // One call per batch topic
      for (const batch of target_batches) {
        const r = await sendToTopic(batchTopic(batch), title, body, fcmData, accessToken);
        results.push(r);
      }

    } else if (target_type === "individual" && target_student_id) {
      // Look up student's FCM token
      const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
      const { data: row } = await supabase
        .from("fcm_tokens")
        .select("token")
        .eq("student_id", target_student_id)
        .maybeSingle();

      if (row?.token) {
        const r = await sendToToken(row.token, title, body, fcmData, accessToken);
        results.push(r);
      }
    }

    return new Response(JSON.stringify({ ok: true, results }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("send-push error:", err);
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
