# RELEASE NOTES

**Project:** PRAEPARATIO — NEET Biology Preparation Platform
**Author:** Deepan Pramanick
**Document Version:** 1.0

---

## VERSION 1.0.0 — INITIAL PRODUCTION RELEASE

**Release Date:** 2026
**Release Type:** Major Release (Initial Production)
**Platform:** Flutter Web (Vercel) + Android (APK)
**Flutter Version:** 3.x | Dart: 3.x | Supabase SDK: 2.5.x

---

## Executive Summary

PRAEPARATIO v1.0.0 is the first production release of the NEET Biology preparation platform. This release delivers a complete EdTech platform for coaching institutes, covering online examination, previous year question practice, animated biological diagrams, AI-powered learning, and full institute management capabilities.

---

## New Features in v1.0.0

### Authentication and User Management
- **Custom Authentication System** — SHA-256 password hashing with admin-managed accounts. No self-registration; admin creates all student accounts.
- **Admin Trigger Login** — Special shortcut (admin-configured) to open admin login dialog from the student login screen.
- **Session Persistence** — Login session persisted locally (Hive) so users don't need to re-login on app restart or browser refresh.
- **Role-Based Routing** — GoRouter automatically redirects admin to admin panel and students to student shell based on session type.
- **Ban / Unban Students** — Admin can suspend student access; banned students see a clear message on login attempt.

### Student Management (Admin)
- **Full Student CRUD** — Create, read, update, and delete student accounts with name, username, password, class level, and batch.
- **CSV Bulk Import** — Import multiple students at once from a CSV file (columns: name, username, password, class, batch).
- **CSV Export** — Export full student list including credentials for admin record-keeping.
- **Fee Tracking** — Mark monthly payment status per student; toggle visible on student management screen.
- **Student Search** — Search and filter students by name, username, or batch.

### Batch Management (Admin)
- **Dynamic Batch Creation** — Create, rename, and delete batches with class level assignment (Class 11, Class 12, NEET Exclusive).
- **Student Promotion** — Move students from one batch to another; the system migrates offline test records and updates exam target arrays automatically.
- **Class Level Sync** — Sync all students in a batch to the batch's class level in one operation.

### Online Exam Engine (Admin + Student)
- **Exam Creator** — Multi-step wizard: metadata → questions → scheduling → publish.
- **Manual Question Entry** — Enter question text, 4 options, correct answer, chapter, and explanation per question.
- **AI Question Generation** — Generate questions using Google Gemini API from a topic prompt; review and edit before saving.
- **Visibility Scheduling** — Set optional start and end datetimes; exams only appear to students within the window.
- **Prepcoins Gate** — Require a coin payment to unlock premium exams.
- **Real-Time Publishing** — Publishing an exam notifies all connected student apps within 2 seconds via Supabase Realtime WebSockets.
- **Computer-Based Test (CBT)** — Timed exam interface with question navigator, countdown timer, and live progress.
- **Live Answer Save** — Every answer selection is immediately saved to the database; answers survive force-close or network interruption.
- **Exam Resume** — Students can resume an in-progress exam with all saved answers and remaining time restored.
- **Auto-Submit** — Exam auto-submits when the countdown timer reaches zero.
- **NEET Scoring** — Results calculated using the official NEET formula: +4 for correct, -1 for wrong, 0 for unattempted.
- **Detailed Results** — Post-exam review showing correct answers, student's answers, and explanations per question.
- **Exam Statistics (Admin)** — Per-exam leaderboard, score distribution chart, and batch-wise average scores.
- **Question Paper PDF** — Admin can download question papers as PDF (questions only, or with separate answer key section).
- **Result PDF** — Student can download their exam result as a formatted PDF report.

### PYQ (Previous Year Questions) System
- **CSV-Based Upload** — Admin uploads PYQ questions per year via UTF-8 encoded CSV files. Handles Windows line endings.
- **Text Year Names** — Year field stored as text; supports "2025 Cancelled", "2025 Retest", etc.
- **Safe Year Replacement** — Uploading for a year replaces only that year's questions; all other years are untouched.
- **Chunked Upload** — Large CSVs inserted in 100-row chunks for reliability.
- **Row Validation** — Invalid rows (missing data, incorrect correct_option) are skipped; valid rows proceed.
- **Chapterwise Mode** — Browse questions organized by NCERT chapter; filter by Class 11 / Class 12 / All.
- **Yearwise Mode** — Browse questions organized by year; sorted newest-first using numeric extraction from year text.
- **Custom Test Mode** — Select specific chapters or years, choose question count, take a shuffled timed test.
- **Case-Insensitive Answers** — Correct option comparison is case-insensitive (A/a/B/b all work correctly).
- **Class Level Filter** — Class 11 students see only Class 11 chapters; Class 12 / NEET students see all.

### Dynamic Bio Lab — 32 Animated Diagrams
- **32 Biological Processes** — All major NEET Biology processes from Class 11 and Class 12.
- **CustomPainter Animations** — All diagrams built with Flutter's CustomPainter; smooth 60fps canvas animations.
- **Animation / Steps Toggle** — Each process offers both an animated diagram view and a step-by-step text view.
- **Step Navigation** — Prev/Next buttons and step bubbles for navigation through stages.
- **Auto-Play** — Auto-advances through steps with a progress bar.
- **NEET Key Points** — Curated key points for each process displayed below the diagram.
- **Responsive Canvas** — Diagrams scale correctly from mobile (320px) to 4K desktop.

Class 12 Diagrams: Megasporogenesis, Double Fertilization, Embryo Development, Placenta Formation, Spermatogenesis, Oogenesis, DNA Double Helix, Griffith's Experiment, Hershey-Chase Experiment, Meselson-Stahl Experiment, DNA Replication, Transcription, Translation, Lac Operon, Recombinant DNA Technology, Gel Electrophoresis, PCR, Micropropagation

Class 11 Diagrams: Bryophyta Life Cycle, Pteridophyta Life Cycle, Mitosis, Meiosis, Z-Scheme of Photosynthesis, Chemiosmotic Hypothesis, Calvin Cycle (C3), C4 Cycle (Hatch-Slack), Oxidative Phosphorylation (ETC), Blood Circulation, Counter-Current Mechanism (Kidney), Sliding Filament Theory (Sarcomere), Action Potential, Hormone Mechanism

### Flashcards
- **500+ NEET Biology Flashcards** — Pre-seeded into local Hive database on first launch.
- **Chapter-Based Organisation** — Chapters from both Class 11 and Class 12 NCERT syllabus.
- **Flip Animation** — Card flips between question and answer on tap.
- **Offline Access** — Flashcards work without internet connection.

### Glossary
- **Searchable Biology Terms** — Definitions for key NEET Biology terminology.
- **Alphabetical Index** — Quick navigation to term groups.

### Biology Games
- **Multiple Game Modes** — MCQ Speed, Matching Pairs, Fill-in-the-blank, True/False.
- **Interactive Learning** — Gamified question practice with immediate feedback.

### Notes and PDFs
- **Admin Upload** — Upload PDF links (e.g. Google Drive) and external URLs organised in sections.
- **Section Organisation** — Notes grouped into named sections with admin-controlled display order.
- **Drag-Free Reorder** — Arrow buttons for reordering notes and sections; changes saved only when admin clicks Save.
- **Visibility Control** — Per-note visibility: All Students, Class 11 Only, Class 12 Only, NEET Exclusive, Private (hidden).
- **Enable/Disable Toggle** — Admin can hide individual notes without changing their visibility setting.
- **In-App PDF Viewer** — PDFs open in WebView (mobile) or iframe (web).
- **Collapsible Sections** — Students can collapse/expand note sections.
- **Sort Order Preserved** — Fixed a Set equality comparison bug that was causing sort order to reset on every Supabase stream event.
- **Edit Button** — Admin can edit note name, link, section, and visibility via edit dialog.

### AI Chatbot
- **Google Gemini Integration** — Powered by Google Gemini AI for biology question answering.
- **User-Provided API Key** — Students enter their own Gemini API key (stored locally in SharedPreferences).
- **Markdown Rendering** — AI responses rendered as formatted Markdown.
- **Chat History** — Conversation maintained in local session state.

### Lesson Planner
- **Daily Study Plans** — Students create date-based study plans with tasks.
- **Task Completion** — Mark individual tasks as done.
- **Calendar View** — Navigate plans by date.

### Offline Test Results (Admin + Student)
- **Admin Mark Entry** — Admin enters marks for physical/offline tests per student.
- **Batch Ranking** — Students see batch-wise ranking for offline tests.
- **Export CSV** — Admin can export test progress reports.

### Notifications System
- **Real-Time In-App Notifications** — Delivered via Supabase Realtime WebSocket; appear as toast pop-ups when the app is open.
- **Automatic Triggers** — Notifications sent automatically when exams are published, notes uploaded, or PYQ added.
- **Manual Send** — Admin can compose and send notifications to all students, a specific batch, or an individual student.
- **Notification Inbox** — Student notification history with read/unread status.
- **Bell Badge** — Unread count displayed on navigation bell icon.

### Maintenance Mode
- **Admin-Controlled Toggle** — Admin enables/disables maintenance mode from the Developer Config screen.
- **Real-Time Propagation** — Maintenance state streams to all connected clients via Supabase Realtime within ~2 seconds.
- **Student Overlay** — Logged-in students see an animated full-screen maintenance page (gears, countdown dots, status indicator).
- **Admin Bypass** — Admin is never affected by maintenance mode and retains full access.
- **Student Logout** — Students can log out from the maintenance screen.
- **Admin Access Link** — Subtle admin link on maintenance screen for emergency admin access.

### Developer Modal
- **Terminal-Style Glass Modal** — Frosted glass card with BackdropFilter blur, shown to students when Dev button is enabled.
- **Boot Sequence Animation** — Typing animation: 6 lines of terminal text appear sequentially before revealing profile.
- **Animated Rainbow Border** — SweepGradient rotating on the developer name container; all rainbow colors travel continuously around the perimeter.
- **3D Tilt Avatar** — Interactive avatar with Matrix4 parallax effect responding to mouse hover or touch.
- **Floating Code Particles** — Subtle background animation of code characters (0, 1, {, }, <, >, etc.) drifting upward.
- **Social Links** — Platform-specific colored chip buttons for GitHub, LinkedIn, Discord, Twitter, Email, Website.
- **Admin Toggle** — Admin can enable/disable the Dev button from Developer Config.

### PDF Reports (Admin)
- **Exam Results PDF** — All student results for one exam with NEET scores and rankings.
- **Batch Report PDF** — Full batch performance across all online exams and offline tests.
- **Student Report PDF** — Individual student history (online + offline) for parent/student sharing.
- **Test Progress PDF** — Offline test marks grid across all tests for a batch.
- **Page Headers and Footers** — All PDFs include header (title, date) and footer (page number).
- **Unicode Safety** — Special characters (→, ×, ², Greek letters, ±) sanitized to ASCII equivalents to prevent PDF rendering boxes.

### Responsive Design
- **Adaptive Navigation** — Bottom navigation bar on mobile/tablet (< 1000px); persistent sidebar on desktop (≥ 1000px).
- **Responsive Admin Panel** — All admin screens adapt to mobile and desktop.
- **Responsive Bio Lab** — Split panel view on wide screens; full-screen on mobile.

### Web-Specific
- **Clean URL Strategy** — `usePathUrlStrategy()` removes the `#` from web URLs for clean, SEO-friendly links.
- **Vercel Deployment** — Pre-configured `vercel.json` with Flutter web build and SPA rewrite rules.
- **PWA Manifest** — `manifest.json` configured with correct name, theme color (#4E46A8), and icons.

---

## Bug Fixes in v1.0.0

Since this is the initial release, the following bugs were discovered and fixed during development:

| ID | Bug | Fix Applied |
|---|---|---|
| BUG-001 | Notes sort order reset on every Supabase stream event | Fixed Set equality comparison: replaced `!=` with `.containsAll()` for value-based ID comparison |
| BUG-002 | PYQ correct option not highlighting when stored as lowercase | Made comparison case-insensitive: `opt.toUpperCase() == correctOption.toUpperCase()` |
| BUG-003 | `changeme123` default password for new students | Removed; system now requires admin to enter password for new accounts |
| BUG-004 | Duplicate PYQ query method declarations causing compile error | Removed duplicate declarations; kept single set |
| BUG-005 | `_dashedLine()` in bio diagram painter missing `w` parameter | Added `w` parameter to function signature |
| BUG-006 | `FirebaseMessaging` import in FCM service causing compile error | Replaced with stub (Firebase not yet integrated) |
| BUG-007 | `year` column in pyq table was INTEGER, blocking text year names | Ran `ALTER TABLE pyq ALTER COLUMN year TYPE text USING year::text` |
| BUG-008 | PDF generation: Unicode arrows (→) showing as boxes (⊠) | Added `_s()` sanitiser replacing Unicode with ASCII equivalents |
| BUG-009 | Admin sees maintenance screen (cannot turn it off) | Fixed: maintenance check moved to StudentShell only; admin bypasses |
| BUG-010 | Maintenance screen blocked admin login (entire app wrapped) | Fixed: moved maintenance check from main.dart builder to StudentShell |
| BUG-011 | `developer_modal.dart` part directive placed after declarations | Moved `part` directive to top of file (after imports) |
| BUG-012 | PYQ limit too low (5000) — close to actual data size | Increased all PYQ query limits to 20,000 |

---

## Database Schema Changes (v1.0.0)

The following SQL migrations must be applied to any Supabase project upgrading to v1.0.0:

```sql
-- 1. PYQ year stored as text
ALTER TABLE pyq ALTER COLUMN year TYPE text USING year::text;

-- 2. Maintenance mode flag
ALTER TABLE developer_info
  ADD COLUMN IF NOT EXISTS is_maintenance boolean DEFAULT false;

-- 3. Notes reordering and visibility control
ALTER TABLE notes
  ADD COLUMN IF NOT EXISTS sort_order integer DEFAULT 0;
ALTER TABLE notes
  ADD COLUMN IF NOT EXISTS is_private boolean DEFAULT false;

-- 4. Exam download permission
ALTER TABLE exams
  ADD COLUMN IF NOT EXISTS allow_download boolean DEFAULT false;

-- 5. Exam resume support
ALTER TABLE exam_results
  ADD COLUMN IF NOT EXISTS is_in_progress boolean DEFAULT false;
ALTER TABLE exam_results
  ADD COLUMN IF NOT EXISTS started_at timestamptz;
ALTER TABLE exam_results
  ADD COLUMN IF NOT EXISTS remaining_seconds integer DEFAULT 0;

-- 6. Performance index
CREATE INDEX IF NOT EXISTS idx_pyq_year_chapter ON pyq(year, chapter);
```

---

## Performance Improvements

- **PYQ Query Optimisation** — Added composite index `idx_pyq_year_chapter ON pyq(year, chapter)` for faster chapter+year filtering.
- **PYQ Limit Increase** — Increased all PYQ query limits from 5,000 to 20,000 rows to support growing question banks.
- **Chunked PYQ Upload** — Upload uses 100-row chunks to avoid Supabase request size limits and improve reliability.
- **Hive Session Cache** — Login session loaded from Hive on app start, avoiding a DB round-trip for session validation.

---

## Known Issues and Limitations

| Issue | Severity | Workaround | Planned Fix |
|---|---|---|---|
| Firebase Cloud Messaging (push notifications) not implemented | Low | In-app notifications work via Realtime WebSocket when app is open | v1.1.0 |
| AI exam generation requires valid Gemini API key | Low | Use manual question entry | N/A (by design) |
| No iOS support | Low | Use web version on Safari | v1.2.0 |
| Gemini API key entered per-device by student | Medium | Admin communicates the key directly | v1.1.0 (admin-set key) |
| PDF download on iOS web (Safari) may open inline | Low | Use "Share" button to save | OS limitation |
| Bio Lab particles animation may be slow on very old devices | Low | Animation pauses in Steps mode | v1.1.0 optimise |
| `withOpacity()` deprecation warnings in Flutter 3.x | Info | App functions correctly; cosmetic only | v1.1.0 batch update |

---

## Security Notes

- **Supabase Anon Key** — Included in source code as designed. This is the public client key protected by Supabase PostgREST and is safe for client-side use.
- **Service Role Key** — NOT included anywhere in client code. Never commit this key.
- **Row Level Security (RLS)** — Currently disabled on all tables for simplicity (private single-institution app). Consider enabling RLS if the app scales to multiple institutions.
- **Admin Trigger Credentials** — The 4444/4444 shortcut is documented in source code. Change `AppConstants.adminTriggerUsername/Password` if wider distribution is planned.
- **Password Storage** — Student passwords stored as SHA-256 hashes. `password_plain` stored for admin password-reset capability (admin can never decrypt, only reset).

---

## Deployment Instructions

### Web (Vercel)

```bash
# Build
flutter build web --release

# Deploy via CLI
vercel --prod

# Or connect GitHub repo in vercel.com (auto-deploys on push to main)
```

### Android (APK)

```bash
# Build release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
# Distribute directly to students via WhatsApp, email, or Google Drive
```

---

## Version History

| Version | Date | Type | Summary |
|---|---|---|---|
| 1.0.0 | 2026 | Major Release | Initial production release — complete platform |

---

## Future Roadmap

| Feature | Target Version | Description |
|---|---|---|
| Firebase Push Notifications | v1.1.0 | Background push notifications when app is closed |
| iOS App | v1.2.0 | Native Flutter iOS build |
| Admin-Set Gemini Key | v1.1.0 | Admin configures Gemini key in admin panel; students use it without entering their own |
| Student Self-Reset Password | v1.2.0 | Students reset via OTP to admin-registered phone |
| Supabase RLS Policies | v1.1.0 | Enable Row Level Security for additional data protection |
| Multi-Institution Support | v2.0.0 | Support multiple coaching institutes under one platform |
| Video Lessons Integration | v2.0.0 | Embed YouTube/Drive video lessons in notes |
| Parent Dashboard | v2.0.0 | Read-only parent portal for monitoring student progress |
| Analytics Dashboard (Student) | v1.1.0 | Student-facing performance analytics and weak area identification |

---

## Contact and Support

**Developer:** Deepan Pramanick
**For Issues:** Contact the developer directly
**Emergency Admin Access:** Use the "Admin Access" link at the bottom of the maintenance screen

---

*End of Release Notes*
*PRAEPARATIO v1.0.0 — 2026*
*"Examination is nothing but fine preparation."*
