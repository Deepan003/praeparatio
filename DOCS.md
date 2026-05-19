# PRAEPARATIO — Full Technical Documentation

> *"Examination is nothing but fine preparation."*

Complete technical reference covering every file, database table, workflow, and deployment step.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Tech Stack](#2-tech-stack)
3. [Architecture](#3-architecture)
4. [Complete File Reference — All 105 Dart Files](#4-complete-file-reference)
5. [Database Schema — Every Table and Column](#5-database-schema)
6. [Workflows — Step by Step](#6-workflows)
7. [State Management](#7-state-management)
8. [Routing](#8-routing)
9. [Admin Panel Guide](#9-admin-panel-guide)
10. [Student App Guide](#10-student-app-guide)
11. [Setup and Deployment](#11-setup-and-deployment)
12. [SQL Migrations](#12-sql-migrations)
13. [Production Checklist](#13-production-checklist)

---

## 1. Overview

PRAEPARATIO is a private EdTech coaching platform for NEET Biology aspirants. One admin (the teacher) manages everything. Students are enrolled manually — no self-registration.

### Batch System

| Class Level | Content Visible |
|---|---|
| Class 11 | Class 11 content only |
| Class 12 | Class 11 + Class 12 |
| NEET Exclusive | Everything |

Each class level can have multiple named batches (e.g. "11 NEET 2025 A"). Batches are created dynamically — nothing hardcoded.

### Platforms

| Platform | Method | Primary? |
|---|---|---|
| Web | Vercel (Flutter Web) | Yes |
| Android | APK distributed by admin | Secondary |
| Desktop | Browser, responsive layout | Via web |

---

## 2. Tech Stack

| Package | Version | Role |
|---|---|---|
| flutter | 3.x | Cross-platform UI |
| supabase_flutter | ^2.5.0 | PostgreSQL + Realtime + Storage |
| flutter_riverpod | ^2.5.1 | State management |
| go_router | ^14.2.7 | Navigation + shell routes |
| hive_flutter | ^1.1.0 | Local cache (flashcards, session) |
| flutter_animate | ^4.5.0 | UI animations |
| pdf + printing | ^3.11.1 / ^5.13.1 | PDF generation |
| csv | ^6.0.0 | PYQ + student import/export |
| file_picker | ^8.1.2 | File selection |
| http | ^1.2.2 | Gemini API calls |
| webview_flutter | ^4.10.0 | PDF viewer on mobile |
| fl_chart | ^0.69.0 | Score charts |
| crypto | ^3.0.5 | SHA-256 password hashing |
| uuid | ^4.5.1 | Client-side UUID generation |

**Why no Supabase Auth?** Students log in with admin-assigned usernames, not email. Admin controls all accounts. Custom SHA-256 hashing is simpler for a private coaching context.

---

## 3. Architecture

```
FLUTTER APP
  AdminShell | StudentShell | LoginScreen
        |
  RIVERPOD PROVIDERS
  authProvider (StateNotifier)
  examProvider (StreamProvider — Realtime)
  pyqProvider (FutureProvider + family)
  developerInfoProvider (StreamProvider — Realtime)
  batchesProvider | notificationProvider | studentProvider
        |
  SupabaseService  (Singleton, ~1200 lines)
  THE ONLY class that touches the database.
  Sections: Users | Batches | Exams | Questions | Results
            PYQ | Notes | Offline Tests | Lesson Plans
            Notifications | Developer Info | App Settings
        |
  SUPABASE CLOUD
  PostgreSQL (13 tables + indexes)
  Realtime WebSockets (exams, results, developer_info)
  PostgREST (auto REST API from schema)
```

**Key decision:** No custom backend server. All logic runs in the Flutter client. SupabaseService is the single point of contact with PostgreSQL.

---

## 4. Complete File Reference

### lib/main.dart

Entry point. Initialises Hive, Supabase, seeds 500+ flashcards.
`PraeparatioApp` (ConsumerWidget): watches routerProvider.
If `isMaintenance == true` AND not admin → shows MaintenanceScreen in builder callback instead of normal content.
Wraps everything in `ToastOverlay`.

---

### lib/core/constants/

**supabase_config.dart** — Supabase URL and anon key. Anon key is safe to commit. Never put the service role key here.

**app_constants.dart** — Admin trigger credentials (4444/4444), default batch names, prepcoins defaults.

**routes.dart** — Named constants for every GoRouter route string. Example: `Routes.studentDashboard = '/student/dashboard'`. Used everywhere instead of raw strings.

**ncert_chapters.dart** — Master list of all NCERT Class 11 + 12 Biology chapters.
- `NcertChapters.classFor(chapter)` returns '11' or '12'
- `NcertChapters.chapterNumber(chapter)` returns int for sort order
Used in PYQ screen, Bio Lab, and exam creator for filtering and sorting.

**flashcard_data.dart** — `FlashcardData.all`: 500+ hardcoded NEET Biology flashcards. Seeded into Hive on first launch.

---

### lib/core/theme/

**app_colors.dart** — Central colour palette:
- `neuBackground`, `neuSurface` — neumorphic page/card colours
- `primary` = Color(0xFF4E46A8) — main purple
- `primaryGradient` — LinearGradient for buttons and headers
- `batch11`, `batch12`, `batchNeet` — class-level colour coding
- `success`, `error`, `warning`, `info` + `*Surface` variants
- `neuRaisedSoft` — standard box shadow for cards

**app_theme.dart** — `ThemeData.lightTheme`. Sets font family, InputDecoration theme, card theme, button styles, AppBar style.

---

### lib/models/ — 14 Data Models

All follow the same pattern: `fromJson()` factory + `toJson()` + `copyWith()`.

| File | DB Table | Key Fields |
|---|---|---|
| user_model.dart | users | id, name, username, passwordHash, passwordPlain, studentClass, batch, prepcoins, isAdmin, isBanned, monthlyPayments (JSONB), loginStreak (JSONB) |
| exam_model.dart | exams | id, title, questions (loaded from questions table), targetBatches[], durationMinutes, isPublished, allowDownload, expRequired, visibilityStart, visibilityEnd |
| question_model.dart | questions | id, examId, text, optionA-D, correctOption, explanation, chapter, difficulty, sortOrder |
| exam_result_model.dart | exam_results | id, examId, studentId, score, answers (JSONB Map), isFirstAttempt, isInProgress, remainingSeconds, correctCount, incorrectCount |
| pyq_model.dart | pyq | id, year (text — was int, altered for "2025 Cancelled" support), chapter, question, optionA-D, correctOption (always uppercase) |
| note_model.dart | notes | id, name, link, visibility (all/11/12/neet/private), sectionName, isLink, sortOrder, isPrivate |
| offline_test_model.dart | offline_tests | id, name, date, fullMarks, batch, studentMarks (JSONB Map<id,marks>) |
| lesson_plan_model.dart | lesson_plans | id, studentId, title, date, isCompleted, tasks (List<LessonTask>) |
| notification_model.dart | notifications | id, type (enum), title, body, data (Map), targetType, targetBatches[] |
| developer_info_model.dart | developer_info | isEnabled (dev button), isMaintenance (overlay for students), name, avatarUrl, showAvatar, links (List<DeveloperLink>) |
| batch_model.dart | batches | id, name, classLevel ('11'/'12'/'neet'), sortOrder |
| badge_model.dart | local only | id, name, description, icon |
| flashcard_model.dart | Hive local | id, chapter, front, back |
| pyq_paper_model.dart | reserved | id, yearName, pdfUrl — for future PDF-based year papers |

---

### lib/providers/ — 7 Provider Files

| File | Key Providers | Type |
|---|---|---|
| auth_provider.dart | authProvider, currentUserProvider, isAdminProvider | StateNotifierProvider — login state + Hive session |
| exam_provider.dart | publishedExamsProvider, allExamsProvider | StreamProvider — Supabase Realtime, always live |
| pyq_provider.dart | allPYQProvider, pyqYearsProvider, pyqByChapterProvider, pyqTestProvider | FutureProvider + family + StateNotifier |
| batch_provider.dart | batchesProvider | FutureProvider |
| developer_provider.dart | developerInfoProvider | StreamProvider — Realtime, streams maintenance flag changes |
| notification_provider.dart | notificationProvider, unreadCountProvider | FutureProvider.family |
| student_provider.dart | allStudentsProvider, studentsByBatchProvider | FutureProvider + family |

---

### lib/router/app_router.dart

GoRouter config with shell routes. AdminShell and StudentShell wrap their child routes so nav chrome stays persistent.

Redirect logic (every navigation):
```
No session            →  /login
Admin on /student/*   →  /admin/dashboard
Student on /admin/*   →  /student/dashboard
```

---

### lib/services/supabase_service.dart

**THE database layer.** ~1,200 lines. Singleton via `SupabaseService.instance`. The only file that imports supabase_flutter.

Sections (marked with `// ---- SECTION ----`):

**Users** — getStudents, getStudentById, upsertUser, deleteUser, banUser, unbanUser, updatePrepcoins, updateLoginStreak, updateMonthlyPayment, searchStudents

**Batches** — getBatches, upsertBatch, deleteBatch, promoteStudents (migrates students + offline test marks + exam target_batches), syncStudentClassForBatch, syncAllStudentClasses

**Exams** — streamPublishedExams (Realtime), streamAllExams (Realtime), upsertExam, deleteExam, publishExam, getExamWithQuestions

**Questions** — upsertQuestions (batch), deleteQuestionsForExam

**Exam Results** — submitResult, getResultsForStudent, getResultsForExam, saveInProgressResult (live JSONB patch during exam), getInProgressForExam (resume support), getFirstAttemptResults

**PYQ** — getAllPYQ (limit 20,000), getPYQByChapter, getPYQByYears, getPYQByChapters, getAvailablePYQYears (newest-first numeric sort), **replacePYQForYear** (chunked safe replacement — insert all → collect IDs → delete old rows for that year not in new set), replacePYQ (full replace legacy)

**Notes** — streamAllNotes (Realtime), upsertNote, deleteNote

**Offline Tests** — getOfflineTestsForBatch, upsertOfflineTest, enterMarks

**Lesson Plans** — getLessonPlansForStudent, upsertLessonPlan, deleteLessonPlan, upsertLessonTask, deleteLessonTask

**Notifications** — getNotificationsForStudent (via RPC), insertNotification, markRead, markAllRead, streamNotificationsForStudent (Realtime)

**Developer Info** — streamDeveloperInfo (Realtime), getDeveloperInfo, upsertDeveloperInfo

**App Settings** — getSetting(key), setSetting(key, value) — JSONB key-value store

---

### lib/services/auth_service.dart

- `hashPassword(password)` → SHA-256 hex string
- `login(username, password)` → query users, compare hash, return UserModel
- `logout()` → clear Hive session
- `saveSession(user)` / `loadSession()` → Hive serialisation
- `isAdminTrigger(username, password)` → checks 4444/4444 shortcut

---

### lib/services/notification_service.dart

`send()` inserts into notifications table with type, title, body, target_type, target_batches. After insert calls `_cleanup()` to keep only 50 most recent.

Helper methods (handle admin toast + DB insert):
- `notifyExamPublished(examTitle, createdBy)`
- `notifyNotesUploaded(noteName, createdBy, visibility)`
- `notifyPyqAdded(paperTitle, createdBy)`
- `notifyWelcome(studentId, studentName)`

---

### lib/services/ai_service.dart

Two distinct AI integrations:

**Exam question generator (Gemini):**
- `generateExamQuestions()` calls Gemini API using key from DB (`exam_ai_api_key` in app_settings). Falls back to SharedPreferences for legacy compatibility.
- `saveApiKey()` now saves to both DB and SharedPreferences.
- `loadSavedKey()` checks DB first, then SharedPreferences.

**Biology Doubt Solver (Universal OpenAI-compatible):**
- `askChatbotQuestion(question)` fetches `chatbot_api_key`, `chatbot_model`, `chatbot_endpoint` from app_settings at call time.
- Uses OpenAI-compatible API format — works with Groq, OpenAI, Together AI, Mistral, and any compatible provider.
- Default: Groq endpoint + llama-3.3-70b-versatile model.
- System prompt constrains responses to NEET Biology Class 11 and 12. Mental health queries receive empathy first, then study help.
- Each question is independent — no conversation memory.

---

### lib/services/pdf_service.dart (~1,000 lines)

PDF types: examResultsPdf, batchReportPdf, studentReportPdf, questionPaperPdf (with optional answer key section), studentTestReportPdf, studentProgressReportPdf.

Shared helpers: `_pageHeader()`, `_pageFooter()` on all pages. `_s(text)` replaces Unicode arrows/special chars with ASCII equivalents (prevents PDF rendering boxes).

---

### lib/services/csv_service.dart

**`parsePYQCsv(bytes, yearName)`** — main PYQ import:
1. UTF-8 decode (BOM + Windows line endings handled)
2. Parse CSV with `shouldParseNumbers: false` (keeps year as string)
3. Skip header row. For each row: trim, validate 8+ columns, question + correct_option not empty, correct_option.toUpperCase() in [A,B,C,D]
4. Returns `List<PYQModel>` (invalid rows skipped with debugPrint)

**`parseStudentsCsv(bytes)`** — imports students (name, username, password, class, batch).

**Export methods:** exportStudentsCsv (includes plain-text password), exportExamResults, exportTestProgressReport, exportStudentReport.

---

### lib/features/admin/

| File | Purpose |
|---|---|
| admin_shell.dart | Adaptive shell: sidebar (>=1000px) / bottom nav (<1000px) |
| dashboard/admin_dashboard.dart | Platform stats, activity charts, quick actions |
| database/database_screen.dart | Full student CRUD. Password required for new users (blank = keep existing for edits). CSV import with preview. Fee tracking. Ban/unban |
| batch_management/batch_management_screen.dart | Batch CRUD. Promote flow migrates students + offline test records + exam target_batches arrays |
| exam_engine/exam_creator_screen.dart | Steps: metadata → questions (manual or Gemini AI) → schedule → save |
| exam_engine/exam_engine_screen.dart | List, publish/unpublish (Realtime + notification), edit, delete, PDF download |
| exam_engine/exam_statistics_screen.dart | Leaderboard, score histogram, batch analytics |
| notes_admin/notes_admin_screen.dart | Two tabs (Notes/Links). Reorder with arrows + explicit Save. **FIXED:** Set equality bug (was using != on Set instances = always true, causing _initFrom to reset order on every stream emit — now uses .containsAll()) |
| pyq_admin/pyq_upload_screen.dart | Year name field, CSV picker, chunked upload, existing years chip list |
| developer/developer_admin_screen.dart | **Maintenance toggle** (red warning card). Developer button toggle. Profile + links config |
| student_activity/student_activity_screen.dart | Per-student monitoring: exam history, offline marks, score trend |
| notifications/send_notification_screen.dart | Compose + send to all/batch/individual |

---

### lib/features/student/

| File | Purpose |
|---|---|
| student_shell.dart | **Maintenance check** — if isMaintenance == true → return MaintenanceScreen(onLogout, onAdminTap). Navigation + Dev button conditional. Realtime subscriptions |
| dashboard/student_dashboard.dart | Prepcoins, streak, upcoming exams (next 3), recent scores, quick-access grid |
| cbt/cbt_portal.dart | Exam engine: resume support, live JSONB answer save, countdown timer, auto-submit, question navigator |
| cbt/exam_result_screen.dart | NEET score, per-question review, explanations, PDF download |
| online_test/online_test_screen.dart | Exams filtered by batch + class. Visibility window check. Coin gate |
| pyq/pyq_screen.dart | 3 tabs: Chapterwise (grid), Yearwise (newest-first sort), Custom Test (multi-select). Case-insensitive correct option comparison |
| bio_lab/bio_lab_screen.dart | Process list + toggle pill (Animation | Steps, only when diagram exists) + animation panel |
| bio_lab/bio_diagram_painter.dart | Registry: buildBioDiagram(id, step, t) → Widget? + 16 CustomPainter classes |
| bio_lab/bio_diagram_painter_2.dart | 16 more CustomPainter classes (part of bio_diagram_painter.dart) |
| bio_lab/bio_process_data.dart | Pure data: 32 BioProcess objects with title, chapter, classLevel, description, keyPoints, steps |
| games/games_screen.dart | Quiz games hub: MCQ Speed, Matching, Fill-in-blank, True/False |
| notes/notes_screen.dart | Collapsible sections (ConsumerStatefulWidget, _collapsed Set). Sorted by sortOrder. AnimatedCrossFade show/hide |
| notes/pdf_viewer_screen.dart | WebView (mobile, Google Docs embed) + iframe (web) |
| chatbot/chatbot_screen.dart | Biology Doubt Solver using universal OpenAI-compatible API (Groq default). Rate limited 350 q/day per student via chatbot_usage table. Skeleton loading animations with rotating "thinking" text. PDF download per answer. Mental health support. Chats not saved — each question is independent. |
| lesson_planner/lesson_planner_screen.dart | Personal daily study planner with tasks and completion tracking. Route exists (`/student/lesson-planner`) but screen is not in the main navigation bar — accessible via direct URL only. |
| history/history_screen.dart | Full exam activity log, score trends. In main navigation as "History". |
| results/offline_results_screen.dart | Admin-entered test marks + batch rankings. In main navigation as "Results". |
| developer/developer_modal.dart | Terminal frosted glass modal. Boot sequence typing animation. **_TravelingBorderPainter:** SweepGradient (9 rainbow colours) rotated by GradientRotation(t×2π) on name container border — colours travel around perimeter. 3D tilt avatar. Floating code particles |
| maintenance/maintenance_screen.dart | Dark gradient + grid + animated gears (CustomPainter) + loading dots. Logout button (full-width). Admin Access link (subtle, bottom) |

---

### lib/widgets/ — 14 Shared Widgets

| File | Purpose |
|---|---|
| adaptive_nav.dart | NavItem model. Sidebar (>=1000px) or bottom nav (<1000px) |
| glass_card.dart | SolidCard — primary card widget throughout the app |
| custom_button.dart | GradientButton, OutlineButton, ChipButton |
| exam_toast.dart | ToastOverlay — typed toasts above all navigation, slide-in animation |
| notification_bell.dart | Bell icon + unread count badge from unreadCountProvider |
| exam_start_dialog.dart | Confirmation before exam: title, count, duration, coin cost |
| download_button.dart | Platform-aware PDF download (conditional import) |
| animated_logo.dart | PRAEPARATIO animated logo |
| skeleton.dart | Shimmer loaders for loading states |
| stat_card.dart | Metric card: number + label + icon |
| iframe_viewer_web.dart | Web iframe for PDF embedding via dart:html |
| iframe_viewer_stub.dart | Mobile stub for iframe_viewer_web |
| badge_widget.dart | Achievement badge display card. Used in student dashboard and games. Badges are UI-only — `earned_badge_ids` stored in users table but badge definitions are hardcoded locally (no separate DB table). |
| neu_widgets.dart | Neumorphic pressed/raised container helpers |

---

## 5. Database Schema

### Relationships

```
users (1) ←→ (many) exam_results
users (1) ←→ (many) lesson_plans ←→ (many) lesson_tasks
exams (1) ←→ (many) questions
exams.target_batches[] ↔ users.batch  (array match, no FK)
notifications (1) ←→ (many) notification_reads
```

### Full Column Reference

```sql
-- USERS
id uuid PK DEFAULT gen_random_uuid()
name text NOT NULL
username text UNIQUE NOT NULL
password_hash text NOT NULL          -- SHA-256 hex
student_class text DEFAULT '11'      -- '11' | '12' | 'neet' | 'admin'
batch text DEFAULT '11 NEET'
prepcoins integer DEFAULT 80
is_admin boolean DEFAULT false
is_banned boolean DEFAULT false
earned_badge_ids text[] DEFAULT '{}'
monthly_payments jsonb DEFAULT '{}'  -- {"2025-01": true}
login_streak jsonb DEFAULT '{}'      -- {"current": 5, "longest": 12, "lastDate": "..."}
created_at timestamptz DEFAULT now()
last_login timestamptz

-- EXAMS
id uuid PK, title text NOT NULL
target_batches text[] DEFAULT '{}'   -- ["11 NEET", "12 NEET"]
duration_minutes integer DEFAULT 60
is_published boolean DEFAULT false
allow_download boolean DEFAULT false -- students can download question paper
exp_required integer DEFAULT 0       -- prepcoins needed to unlock
visibility_start timestamptz         -- scheduled release
visibility_end timestamptz           -- auto-hide after this

-- QUESTIONS
id uuid PK
exam_id uuid REFERENCES exams(id) ON DELETE CASCADE
text, option_a, option_b, option_c, option_d text NOT NULL
correct_option text CHECK (IN ('A','B','C','D'))
image_url text, explanation text, chapter text, sort_order integer

-- EXAM_RESULTS
id uuid PK
exam_id uuid               -- no FK (exam may be deleted)
student_id uuid REFERENCES users(id) ON DELETE CASCADE
score integer              -- NEET score (+4/-1)
answers jsonb DEFAULT '{}'  -- {"q_uuid": "A", ...}
is_first_attempt boolean DEFAULT true
is_in_progress boolean DEFAULT false  -- resume support
started_at timestamptz, remaining_seconds integer DEFAULT 0
correct_count, incorrect_count, unattempted_count integer

-- PYQ
id uuid PK
year text NOT NULL          -- "2024" | "2025 Cancelled" (was int, altered)
chapter text NOT NULL, question text NOT NULL
option_a, option_b, option_c, option_d text NOT NULL
correct_option text         -- always uppercase A|B|C|D

-- NOTES
id uuid PK, name text NOT NULL, link text NOT NULL
visibility text DEFAULT 'all'  -- 'all' | '11' | '12' | 'neet' | 'private'
section_name text NOT NULL
is_link boolean DEFAULT false  -- false = PDF viewer, true = browser
sort_order integer DEFAULT 0   -- admin-set display order
is_private boolean DEFAULT false  -- hidden toggle

-- OFFLINE_TESTS
id uuid PK, name text NOT NULL, test_date date NOT NULL
full_marks integer NOT NULL, batch text NOT NULL
student_marks jsonb DEFAULT '{}'  -- {"student_uuid": 45, ...}

-- NOTIFICATIONS
id uuid PK, type text NOT NULL
title text, body text, data jsonb DEFAULT '{}'
target_type text DEFAULT 'all'  -- 'all' | 'batch' | 'student'
target_batches text[] DEFAULT '{}'
target_student_id uuid, created_by text

-- BATCHES
id uuid PK, name text UNIQUE NOT NULL
class_level text NOT NULL  -- '11' | '12' | 'neet'
sort_order integer DEFAULT 0

-- DEVELOPER_INFO
id uuid PK
is_enabled boolean DEFAULT false    -- show dev button in student app
is_maintenance boolean DEFAULT false -- show maintenance screen to students
name text, avatar_url text, show_avatar boolean DEFAULT true
links jsonb DEFAULT '[]'  -- [{"platform": "github", "url": "..."}]

-- APP_SETTINGS
key text PK, value jsonb
-- defaults: show_payment_status = 'true', monthly_prepcoins = '80'
```

### Indexes

```sql
idx_users_username           ON users(username)
idx_exams_published          ON exams(is_published)
idx_questions_exam_id        ON questions(exam_id)
idx_results_student          ON exam_results(student_id)
idx_results_exam             ON exam_results(exam_id)
idx_pyq_chapter              ON pyq(chapter)
idx_pyq_year                 ON pyq(year)
idx_pyq_year_chapter         ON pyq(year, chapter)  ← added migration
idx_lesson_plans_student     ON lesson_plans(student_id)
idx_offline_tests_batch      ON offline_tests(batch)
```

---

## 6. Workflows

### Student Login

```
Open app → SplashScreen → GoRouter redirect
  authProvider checks Hive for saved session
  If valid session: verify in DB, check not banned, not admin
    → /student/dashboard
  If no session:
    → /login

On /login form:
  AuthNotifier.login():
    a. SHA-256 hash the password
    b. SELECT * FROM users WHERE username = ?
    c. Compare password_hash
    d. Check is_banned == false
    e. Check is_admin == false (admin cannot log in as student)
    f. Save UserModel to Hive, update last_login
    g. state = AsyncData(user)
  GoRouter detects new session → /student/dashboard

StudentShell mounts:
  Subscribe Realtime exam channel (new exam published toast)
  Subscribe Realtime results channel
  Watch developerInfoProvider for maintenance state
```

### Admin Login

```
Enter "4444" / "4444" on login screen
AuthService.isAdminTrigger() == true
AdminLoginDialog opens (modal over login screen)
Enter real admin credentials
Same AuthNotifier.login() flow
is_admin == true → GoRouter → /admin/dashboard
```

### Exam Creation + Publish

```
/admin/exams → Create Exam → ExamCreatorScreen

Step 1: Title, target batches (multi-select), duration, tags, expRequired, allowDownload
Step 2: Questions
  Manual: type question + 4 options + correct option + chapter + explanation
  AI: enter topic prompt → Gemini API call → parse JSON → review questions
Step 3: Schedule (optional visibility_start / visibility_end)
Step 4: Save
  INSERT INTO exams (metadata)
  INSERT INTO questions (all questions with exam_id FK)
  Navigate to exam list (exam is unpublished)

Admin taps Publish:
  UPDATE exams SET is_published = true, published_at = now()
  Supabase Realtime fires PostgresChangeEvent.update
  publishedExamsProvider StreamProvider emits new list to ALL connected student apps
  ToastService shows "New Exam Available" toast on all student screens
  NotificationService.notifyExamPublished() → INSERT INTO notifications
  Students see bell badge increment
```

### Student Taking an Exam

```
/student/tests (OnlineTestScreen):
  Filter: target_batches contains student.batch
  Check: visibility window (start ≤ now ≤ end, if set)
  Check: expRequired ≤ student.prepcoins

Tap exam → ExamStartDialog (confirm) → CBTPortal mounts

CBTPortal:
  getInProgressForExam(examId, studentId)
  If found (resume): load saved answers, set timer to remaining_seconds
  If not found: INSERT exam_results (is_in_progress: true, started_at: now)

During exam:
  Every answer selection → saveInProgressResult():
    PATCH exam_results SET answers = answers || '{"q_uuid": "A"}'::jsonb
    (answers survive app crash or accidental close)
  Timer countdown (AnimationController), auto-submit on expiry

Submit:
  Calculate correct_count, incorrect_count, unattempted_count
  NEET score = correct_count × 4 - incorrect_count × 1
  UPDATE exam_results: is_in_progress=false, score, counts, submitted_at
  Navigate to ExamResultScreen

ExamResultScreen:
  Show NEET score, counts with coloured rings
  Per-question review with option highlight and explanations
  Download PDF button → PdfService.studentTestReportPdf()
```

### PYQ Upload

```
/admin/pyq:
  Enter year name (e.g. "2025" or "2024 Cancelled")
  Tap Select CSV → FilePicker (CSV only)

CsvService.parsePYQCsv(bytes, yearName):
  1. UTF-8 decode with BOM handling
  2. Normalise \r\n → \n (Windows line endings)
  3. Parse CSV (shouldParseNumbers: false — keeps year as string)
  4. Skip header row (row 0)
  5. For each row:
       - Trim all cells
       - Skip if < 8 columns or blank
       - Validate: question not empty, correct_option not empty
       - Validate: correct_option.toUpperCase() IN [A,B,C,D]
       - Create PYQModel (yearName overrides any year column from CSV)
  6. Return List<PYQModel>

Confirmation dialog: "N questions for year X. Replace existing? Continue?"

SupabaseService.replacePYQForYear(yearName, questions):
  Map questions to insert data
  Split into chunks of 100
  For each chunk:
    INSERT INTO pyq (...) RETURNING id
    Collect inserted IDs into insertedIds list
  DELETE FROM pyq WHERE year = yearName AND id NOT IN (insertedIds)
  (Safe: only removes OLD rows for this year, other years untouched)

ref.invalidate(allPYQProvider, pyqYearsProvider, pyqChaptersProvider)
NotificationService.notifyPyqAdded() → notification to all students
Admin sees success message with count
```

### Maintenance Mode

```
TURNING ON:
  Admin → /admin/developer → toggle Maintenance Mode ON → Save
  SupabaseService.upsertDeveloperInfo({..., is_maintenance: true})
  Supabase Realtime fires update event on developer_info table
  developerInfoProvider StreamProvider emits DeveloperInfoModel(isMaintenance: true)
  In StudentShell.build():
    if (isMaintenance) {
      return MaintenanceScreen(
        onAdminTap: () => context.go('/admin'),
        onLogout: () => ref.read(authProvider.notifier).logout(),
      );
    }
  Students see full-screen maintenance overlay
  Admin (isAdmin == true) is completely unaffected, sees normal app

TURNING OFF:
  Admin goes to /admin/developer → toggle OFF → Save
  Same Realtime flow → isMaintenance = false emitted to all clients
  Students see normal student app again instantly

STUDENT OPTIONS ON MAINTENANCE SCREEN:
  Log Out button → authProvider.notifier.logout() → returns to /login
  Admin Access link (white, very subtle) → router.go('/admin')
    (Admin can log in here if needed and toggle maintenance off)
```

---

## 7. State Management

```dart
// StreamProvider: Realtime, always live, never needs manual refresh
final developerInfoProvider = StreamProvider<DeveloperInfoModel>((ref) async* {
  await for (final data in SupabaseService.instance.streamDeveloperInfo()) {
    yield data == null
        ? DeveloperInfoModel(isEnabled: false, isMaintenance: false, ...)
        : DeveloperInfoModel.fromJson(data);
  }
});

// FutureProvider: one-shot fetch, cached until ref.invalidate() called
final allPYQProvider = FutureProvider<List<PYQModel>>((ref) async {
  return SupabaseService.instance.getAllPYQ();
});

// FutureProvider.family: parameterised — each unique param = separate cache
final pyqByChapterProvider = FutureProvider.family<List<PYQModel>, String>(
  (ref, chapter) => SupabaseService.instance.getPYQByChapter(chapter),
);
// Usage: ref.watch(pyqByChapterProvider('Cell Biology'))

// StateNotifierProvider: mutable local state with methods
class PYQTestNotifier extends StateNotifier<PYQTestState> {
  PYQTestNotifier() : super(const PYQTestState());
  void startTest(List<PYQModel> questions) {
    state = PYQTestState(questions: questions);
  }
  void answerQuestion(String id, String opt) {
    state = state.copyWith(answers: {...state.answers, id: opt});
  }
  void submit() { /* calculate score, update state */ }
}
final pyqTestProvider = StateNotifierProvider<PYQTestNotifier, PYQTestState>(
  (_) => PYQTestNotifier(),
);

// Provider: synchronous derived value
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider)?.isAdmin ?? false;
});
```

**Usage patterns:**
- `ref.watch(p)` — in build(), rebuilds widget when value changes
- `ref.read(p)` — in callbacks/methods, no subscription overhead
- `ref.read(p.notifier)` — access StateNotifier to call methods
- `ref.invalidate(p)` — force FutureProvider to re-fetch (e.g. after PYQ upload)

---

## 8. Routing

```
/                           SplashScreen (auto-redirect based on session)
/login                      LoginScreen

/admin                      AdminShell (GoRouter shell route)
  /admin/dashboard          AdminDashboard
  /admin/database           DatabaseScreen (student CRUD)
  /admin/batches            BatchManagementScreen
  /admin/exams              ExamEngineScreen
  /admin/exams/create       ExamCreatorScreen (new)
  /admin/exams/:id          ExamCreatorScreen (edit)
  /admin/pyq                PYQUploadScreen
  /admin/notes              NotesAdminScreen
  /admin/notifications      SendNotificationScreen
  /admin/activity           StudentActivityScreen
  /admin/developer          DeveloperAdminScreen (maintenance, chatbot AI, exam AI, dev profile)
  /admin/credits            CreditsScreen

/student                    StudentShell (GoRouter shell route)
  ── Main navigation (11 items in bottom nav / sidebar) ──
  /student/dashboard        StudentDashboard
  /student/tests            OnlineTestScreen
  /student/results          OfflineResultsScreen
  /student/pyq              PYQScreen (3 tabs)
  /student/flashcards       FlashcardScreen
  /student/glossary         GlossaryScreen
  /student/bio-lab          BioLabScreen (32 animated diagrams)
  /student/games            GamesScreen
  /student/notes            NotesScreen (collapsible sections)
  /student/chat             ChatbotScreen (Biology Doubt Solver)
  /student/history          HistoryScreen

  ── Routed but NOT in main navigation ──
  /student/lesson-planner   LessonPlannerScreen (route exists, no nav item)
  /student/external-links   ExternalLinksScreen (accessible via more menu)
```

**Redirect rules:**
- No session → `/login`
- Admin session → `/admin/dashboard` (cannot enter /student)
- Student session → `/student/dashboard` (cannot enter /admin)

---

## 9. Admin Panel Guide

### Admin Navigation (10 items)

| Screen | Route | Purpose |
|---|---|---|
| Dashboard | /admin/dashboard | Platform stats, quick actions |
| Students | /admin/activity | Per-student activity monitoring |
| Exam Engine | /admin/exams | List, publish, manage exams |
| Notes | /admin/notes | Upload PDFs and links |
| Notify | /admin/notifications | Send targeted notifications |
| Database | /admin/database | Full student CRUD |
| PYQ Upload | /admin/pyq | Upload question CSV per year |
| Credits | /admin/credits | Manage student Prepcoins |
| Batches | /admin/batches | Create/rename/delete batches |
| Developer Config | /admin/developer | Maintenance, AI settings, developer profile |

> **Note:** Offline test marks (physical tests) are stored in the `offline_tests` database table and managed via the SupabaseService layer. There is no dedicated admin UI screen for offline tests — marks must be entered via direct Supabase table access or via a future admin screen.

### First-Time Setup

1. Enter `4444` + `4444` on login screen → AdminLoginDialog opens
2. Use default credentials: `admin` / `praeparatio@admin2024`
3. Change admin password immediately via Supabase SQL:

```sql
UPDATE users
SET password_hash = encode(digest('YourNewPassword', 'sha256'), 'hex')
WHERE username = 'admin';
```

### Creating Students

Database → `+` button → fill: name, username, **password (required for new users)**, class, batch.

Or import via CSV: format `name,username,password,class,batch` with header row.

### Creating Batches

Batches → Create Batch → enter name and class level (11/12/neet).
Use the **Edit (pencil)** button on each batch card to rename it or change class level — all student records, offline tests, and exam targets update automatically.
Naming convention: `"11 NEET 2025 Morning"`, `"12 Evening Batch"`.

### Creating Exams

Exams → Create → complete all 4 steps → Save (unpublished). Publish when ready — students see it instantly via Realtime.

AI generation: in Step 2, type a prompt like *"15 MCQs on Cell Division, NEET level, with explanations"* → Gemini returns structured questions.

Exam AI key and model are configured in **Developer Config → Exam AI Settings** and stored in the database.

### Uploading PYQ

PYQ Upload → type year name exactly as students should see it → pick CSV → confirm. Existing questions for that year are safely replaced without touching other years.

CSV format (8 required columns): `year | chapter | question | optA | optB | optC | optD | correct (A/B/C/D)`

### Uploading Notes

Notes → Add Note → name, URL (Google Drive share link for PDFs), section (existing or new), visibility. Reorder with ▲▼ arrows → Save to persist order.

### Configuring the Biology Chatbot

Developer Config → Chatbot Settings → enter your Groq API key, model name, and daily limit per student. Get a free key at console.groq.com.

### Maintenance Mode

Developer Config → toggle Maintenance Mode ON → Save. Red warning card appears confirming it's on. All students see maintenance screen instantly. You (admin) are unaffected. Toggle OFF to restore.

---

## 10. Student App Guide

### Main Navigation (11 items)

Home · Tests · Results · PYQs · Cards · Glossary · Bio Lab · Games · Notes · Chat · History

### Content by Class Level

| Student Class | Sees |
|---|---|
| Class 11 | Only Class 11 chapters, exams, PYQ |
| Class 12 | Class 11 + Class 12 content |
| NEET Exclusive | Everything (all classes) |

### Prepcoins

- Default: 80 on account creation
- Admin sets `exp_required` on exams as a coin gate (0 = free)
- Adjust individual student coins via Database screen in admin panel

### PYQ Practice Modes

| Mode | How to Use |
|---|---|
| Chapterwise | Browse chapter grid → tap chapter → see all questions across all years |
| Yearwise | Browse year grid → tap year → browse or take as full timed test |
| Custom Test | Select chapters or years → set question count → start shuffled test |

### Bio Lab

Each of the 32 processes has two views toggled by a pill button:
- **Animation** — live CustomPainter diagram updating with each step and animating continuously
- **Steps** — text explanation (title + detail + auto-play progress bar)

The toggle only appears when an animation is implemented for that process. Processes without animation always show Steps mode.

### Biology Doubt Solver (Chat)

- Ask any NEET Biology question (Class 11 or 12, NCERT-based)
- Rate limited to 350 questions per day (resets at midnight)
- Each question is independent — no memory of previous questions
- Chats are NOT saved — use the **Save as PDF** button after each answer to keep a record
- Mental health / stress queries receive empathy first, then study help
- No API key needed from student side — configured by admin

### Notifications

Notifications appear as a bell badge in the top bar. Tapping opens an in-app inbox showing all notifications. There is no separate full-screen notifications route — the inbox is a modal sheet.

---

## 11. Setup and Deployment

### Prerequisites

```bash
flutter --version  # Flutter 3.x required, Dart 3.x
```

### Step 1: Clone and install

```bash
git clone https://github.com/YOUR_USERNAME/praeparatio.git
cd praeparatio
flutter pub get
```

### Step 2: Configure Supabase

Edit `lib/core/constants/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String url = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String anonKey = 'YOUR_ANON_KEY';
}
```

Find in Supabase dashboard → Settings → API.

### Step 3: Set up database

1. Supabase → SQL Editor → run entire `supabase_schema.sql`
2. Run all migrations from Section 12

### Step 4: Run locally

```bash
flutter run -d chrome    # Web (hot reload works, best for development)
flutter run              # First available device
flutter devices          # List available devices
```

### Step 5: Build for production

```bash
flutter build web --release    # Web (output: build/web/)
flutter build apk --release    # Android APK (direct distribution)
```

### Step 6: Deploy to Vercel

Option A — CLI:
```bash
npm install -g vercel
vercel --prod
```

Option B — GitHub integration:
1. Push to GitHub
2. vercel.com → New Project → import repo
3. Framework: **Other**
4. `vercel.json` is pre-configured:
```json
{
  "buildCommand": "flutter build web --release",
  "outputDirectory": "build/web",
  "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }]
}
```
5. Every push to main auto-deploys.

### Updating the App

1. Enable maintenance mode (admin panel)
2. Make changes locally, test with `flutter run -d chrome`
3. Build: `flutter build web --release`
4. Deploy: `vercel --prod`
5. Disable maintenance mode

---

## 12. SQL Migrations

Run in Supabase SQL Editor in order. All use `IF NOT EXISTS` and are safe to re-run.

```sql
-- 1. PYQ year as text (supports "2025 Cancelled" style names)
ALTER TABLE pyq ALTER COLUMN year TYPE text USING year::text;

-- 2. Maintenance mode for student overlay
ALTER TABLE developer_info
  ADD COLUMN IF NOT EXISTS is_maintenance boolean DEFAULT false;

-- 3. Notes ordering and hidden toggle
ALTER TABLE notes
  ADD COLUMN IF NOT EXISTS sort_order integer DEFAULT 0;
ALTER TABLE notes
  ADD COLUMN IF NOT EXISTS is_private boolean DEFAULT false;

-- 4. Exam PDF download permission
ALTER TABLE exams
  ADD COLUMN IF NOT EXISTS allow_download boolean DEFAULT false;

-- 5. Exam resume support
ALTER TABLE exam_results
  ADD COLUMN IF NOT EXISTS is_in_progress boolean DEFAULT false;
ALTER TABLE exam_results
  ADD COLUMN IF NOT EXISTS started_at timestamptz;
ALTER TABLE exam_results
  ADD COLUMN IF NOT EXISTS remaining_seconds integer DEFAULT 0;

-- 6. Performance index on PYQ year + chapter
CREATE INDEX IF NOT EXISTS idx_pyq_year_chapter ON pyq(year, chapter);

-- 7. Batches table additional columns
ALTER TABLE batches
  ADD COLUMN IF NOT EXISTS class_level text DEFAULT '11';
ALTER TABLE batches
  ADD COLUMN IF NOT EXISTS sort_order integer DEFAULT 0;
```

---

## 13. Production Checklist

### Code

- [ ] `flutter analyze` shows 0 errors
- [ ] `debugShowCheckedModeBanner: false` in main.dart *(already done)*
- [ ] No `print()` statements (only `debugPrint`, stripped in release builds)
- [ ] No placeholder content visible to users

### Supabase

- [ ] All SQL migrations from Section 12 run
- [ ] Default admin password changed from `praeparatio@admin2024`
- [ ] Supabase project not on paused free tier
- [ ] Supabase anon key in code *(correct — it is designed to be public)*
- [ ] Service role key NOT in code *(never put this anywhere in the app)*

### Web (Vercel)

- [ ] `web/index.html` has correct title, description, meta tags *(done)*
- [ ] `web/manifest.json` has correct name and theme_color *(done)*
- [ ] `vercel.json` rewrite rules present for SPA routing *(done)*
- [ ] Custom domain configured in Vercel *(optional)*

### Android

- [ ] App icon set (`flutter pub run flutter_launcher_icons`)
- [ ] Release signing configured in `android/app/build.gradle.kts` *(currently debug key)*
- [ ] Correct `applicationId` in build.gradle.kts

### Security

- [ ] Admin trigger credentials (4444/4444) changed if app is distributed widely
- [ ] No SQL injection risk — all queries use parameterised Supabase SDK calls

---

## Linking from README.md

The animated `README.md` links to this file with:

```markdown
[Full Technical Documentation](DOCS.md)
```

---

*PRAEPARATIO Technical Documentation v1.0.0*

*"Examination is nothing but fine preparation."*
