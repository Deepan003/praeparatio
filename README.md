<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:4E46A8,50:7C3AED,100:06B6D4&height=220&section=header&text=PRAEPARATIO&fontSize=90&fontAlignY=38&animation=twinkling&fontColor=ffffff&desc=Examination%20is%20nothing%20but%20fine%20preparation.&descAlignY=62&descFontSize=18&descFontColor=ffffffcc" width="100%"/>

<br/>

[![Typing SVG](https://readme-typing-svg.demolab.com?font=Fira+Code&size=20&pause=1200&color=4E46A8&center=true&vCenter=true&width=700&lines=Full-Scale+EdTech+Platform+for+NEET+Biology;Flutter+%2B+Supabase+%2B+Riverpod+%2B+GoRouter;32+Animated+Biological+Process+Diagrams;AI-Powered+Exam+Generator+%2B+Biology+Chatbot;Built+for+Class+11%2C+12+%26+NEET+Aspirants)](https://github.com/DeepanPramanick)

<br/>

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Vercel](https://img.shields.io/badge/Vercel-000000?style=for-the-badge&logo=vercel&logoColor=white)
![Google Gemini](https://img.shields.io/badge/Gemini_AI-4285F4?style=for-the-badge&logo=google&logoColor=white)
![Groq](https://img.shields.io/badge/Groq_AI-F55036?style=for-the-badge&logo=groq&logoColor=white)

<br/>

![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Android-blueviolet?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-2.1.0-success?style=for-the-badge)
![Dart Files](https://img.shields.io/badge/Dart_Files-120+-informational?style=for-the-badge)
![Bio Diagrams](https://img.shields.io/badge/Bio_Diagrams-32_Animated-ff69b4?style=for-the-badge)
![Badges](https://img.shields.io/badge/Achievement_Badges-90-gold?style=for-the-badge)
![PYQ Questions](https://img.shields.io/badge/PYQ_Questions-20K%2B-orange?style=for-the-badge)

</div>

📖 **[Full Technical Documentation →](DOCS.md)** — every file, every table, every workflow in detail.

---

## At a Glance

| Metric | Value |
|:---:|:---:|
| Target Audience | NEET Biology Aspirants — Class 11, 12, NEET |
| Architecture | Flutter + Riverpod + SupabaseService + PostgreSQL |
| Backend | Supabase — **no custom server needed** |
| Deployment | Web (Vercel) + Android (APK) |
| Bio Lab | **32 fully animated CustomPainter processes** |
| PYQ Bank | **20,000+ questions** across all NEET years |
| AI Chatbot | Groq/OpenAI-compatible Biology Doubt Solver. 350 q/day per student. Skeleton loading + PDF download per answer. Admin-configurable key + model in DB. |
| Exam AI | Gemini-powered exam question generator. Key + model stored in DB via admin panel. |

---

## What's New in v2.0

### v2.0 — Major Release

| Feature | Description |
|---|---|
| **90-Badge Achievement System** | 15 categories × 6 tiers (Bronze → Bio Legend). Fully retroactive — existing students get badges on first open. Animated unlock dialog with tier-specific animations. Dedicated Badges screen with progress tracking. |
| **Terms of Service** | Professional 14-clause TOS shown after first login. Acceptance timestamp stored in DB. Version-gated — bumping `kTosVersion` re-shows to all users. |
| **Import Questions from Exam** | Admin can browse any published exam and copy individual questions or entire sets into a new exam. Two-step sheet UI. Questions are cloned (new UUIDs) — fully independent. |
| **Full App Realtime** | Batches, offline test marks, exam results on cards, and user data (prepcoins, badges) now update live via Supabase Streams. No page refresh needed anywhere. |
| **Batch-targeted Exam Toast Bug Fix** | Toast on exam publish now only fires for students in the targeted batch, not all users. |
| **Notification Mark-as-Read Fix** | Fixed `is_read` not persisting on reload — fallback query now cross-references `notification_reads` table. |
| **Draggable AI/Questions Split** | On mobile, the AI panel and questions list have a draggable divider with preset buttons (AI ▲ / Split ⟺ / Questions ▼). |
| **Score-adaptive Result Screen** | Gradient changes: green ≥80%, amber 40–79%, red <40%. Animated 3-zone bar. |
| **PYQ Bookmarks** | Saved tab, persisted via SharedPreferences + Riverpod StateNotifier. |
| **Onboarding Tour** | 3-slide coach mark on first login (Bio Lab, PYQ, Notifications). |
| **Coin Rain Overlay** | 🪙 28-particle confetti on PrepCoin award. |
| **Game Answer Burst Redesign** | Glass-style card with colored border (BackdropFilter blur). No more heavy solid overlay. |
| **Chatbot 3-dot Typing Indicator** | Bouncing dots + rotating AI status during response generation. |
| **Glossary Live Highlighting** | Yellow substring highlight as you type. |
| **Bio Lab** | Taller canvas (90%), white label pills, animated flask header, process glow on select. |
| **Splash Cinematic Animation** | Letters stagger in 90ms apart; tagline reveals word-by-word with blur-focus effect. |
| **PDF Fixes** | OOM fix via `compute()` isolate + capped chapter table. Chatbot PDF uses MultiPage for long answers. |

---

## Features

### Student (12 nav items)
- **Online Exams (CBT)** — NEET scoring (+4/-1), auto-submit, resume in-progress, score-adaptive result screen, exam question import
- **PYQ Practice** — 20,000+ questions, Chapterwise / Yearwise / Custom Test / Bookmarks tabs, difficulty pills, recency colours
- **Dynamic Bio Lab** — 32 animated process diagrams, draggable canvas, Auto Play completion tracking for badges
- **Flashcards** — 500+ NEET Biology cards, works offline (Hive cache)
- **Glossary** — searchable with live substring highlighting
- **Games** — 25+ biology games (MCQ, Match, True/False, Diagnosis, Punnett Square, and more)
- **Notes & PDFs** — admin-uploaded, collapsible sections, animated empty state, Google Drive sign-in detection
- **Biology Doubt Solver** — AI chatbot, 350 q/day, 3-dot typing indicator, MultiPage PDF download
- **Offline Results** — admin-entered test marks, live updates when teacher enters marks
- **History** — full exam activity log and score trends
- **Notifications** — real-time bell, mark-as-read persisted in DB, last 10 stored
- **Badges** — 90 achievement badges across 15 categories, 6 tiers, animated unlock dialogs

### Admin (10 nav items)
- **Student Management** — CRUD, CSV import/export, ban/unban, fee tracking, live realtime updates
- **Batch Management** — create/rename/delete/promote, sync class levels, live realtime
- **Exam Engine** — AI (Gemini) + manual creator, import from existing exams, draggable mobile split, scheduling, statistics, PDF download
- **Notes Admin** — upload PDFs and links, reorder sections, visibility control
- **PYQ Upload** — CSV per year, safe chunked replacement
- **Credits** — manage student PrepCoins
- **Send Notifications** — targeted to all / batch / individual student (batch-scoped toasts)
- **Student Activity** — per-student exam history, performance, and badge grid
- **Developer Config** — maintenance mode, chatbot API settings, exam AI settings, developer profile

---

## Tech Stack

| Layer | Technology |
|:---:|:---:|
| UI | Flutter 3.x (Dart) |
| Database | Supabase (PostgreSQL + Realtime) |
| State | Riverpod 2.x |
| Navigation | GoRouter 14.x |
| Local Cache | Hive |
| PDF | pdf + printing packages |
| Chatbot AI | Groq / any OpenAI-compatible API |
| Exam AI | Google Gemini API |
| Hosting | Vercel |
| Auth | Custom SHA-256 hash |

---

## Architecture

`
FLUTTER APP
  AdminShell / StudentShell / AuthScreen
      |
  RIVERPOD PROVIDERS
  authProvider - examProvider - pyqProvider - developerProvider - ...
      |
  SupabaseService (Singleton, ~1200 lines)
  ALL database operations. Zero direct DB calls outside this class.
      |
  SUPABASE CLOUD
  PostgreSQL (13 tables) - Realtime - Storage - PostgREST API
`

No custom backend server. All logic runs in Flutter client.

---

## Project Structure

### Core
| File | Purpose |
|---|---|
| lib/main.dart | Entry point. Init Hive, Supabase. ProviderScope + ToastOverlay |
| lib/core/constants/supabase_config.dart | Supabase URL + anon key |
| lib/core/constants/routes.dart | All GoRouter route constants |
| lib/core/constants/ncert_chapters.dart | All NCERT chapters with classFor() helper |
| lib/core/theme/app_colors.dart | Full colour palette, gradients, neumorphic helpers |
| lib/router/app_router.dart | GoRouter config, shell routes, redirect logic |

### Models (14)
user_model, exam_model, question_model, exam_result_model, pyq_model, note_model, offline_test_model, lesson_plan_model, notification_model, developer_info_model, batch_model, badge_model, flashcard_model, pyq_paper_model

All follow: plain class + fromJson() + toJson() + copyWith()

### Providers (7 files, 15+ providers)
| File | Type | Key Providers |
|---|---|---|
| auth_provider.dart | StateNotifierProvider | authProvider, isAdminProvider |
| exam_provider.dart | StreamProvider | publishedExamsProvider |
| pyq_provider.dart | FutureProvider + family | allPYQProvider, pyqByChapterProvider |
| developer_provider.dart | StreamProvider | developerInfoProvider (Realtime) |
| batch_provider.dart | FutureProvider | batchesProvider |
| notification_provider.dart | FutureProvider | unreadCountProvider |
| student_provider.dart | FutureProvider | allStudentsProvider |

### Services (12)
| File | Purpose |
|---|---|
| supabase_service.dart | **Entire DB layer** (~1200 lines). All CRUD + Realtime + Storage |
| auth_service.dart | SHA-256 login, Hive session, admin trigger |
| notification_service.dart | DB notification insert + Realtime bell |
| ai_service.dart | Gemini API streaming |
| pdf_service.dart | Exam reports, question papers, batch reports |
| csv_service.dart | PYQ CSV import, student/result exports |
| storage_service.dart | Hive wrapper |
| toast_service.dart | In-app toast queue |

### Admin Screens (12)
admin_shell, admin_dashboard, database_screen, batch_management_screen, exam_creator_screen, exam_engine_screen, exam_statistics_screen, notes_admin_screen, pyq_upload_screen, developer_admin_screen, student_activity_screen, send_notification_screen

### Student Screens (25+)
student_shell, student_dashboard, cbt_portal, exam_result_screen, online_test_screen, pyq_screen, offline_results_screen, flashcard_screen, flashcard_viewer, glossary_screen, bio_lab_screen, bio_diagram_painter (16 CustomPainters), bio_diagram_painter_2 (16 CustomPainters), bio_process_data, games_screen, notes_screen, pdf_viewer_screen, chatbot_screen, lesson_planner_screen, notification_screen, history_screen, developer_modal, maintenance_screen

### Widgets (14)
adaptive_nav, glass_card, custom_button, exam_toast, notification_bell, exam_start_dialog, download_button, animated_logo, badge_widget, neu_widgets, skeleton, stat_card, iframe_viewer_web, iframe_viewer_stub

---

## Database Schema

`
TABLE          KEY COLUMNS
------         -----------
users          id, name, username, password_hash (SHA-256), student_class,
               batch, prepcoins, is_admin, is_banned,
               monthly_payments (JSONB), login_streak (JSONB)

exams          id, title, target_batches[], duration_minutes, is_published,
               allow_download, exp_required, visibility_start/end

questions      id, exam_id (FK), text, option_a-d, correct_option, chapter

exam_results   id, exam_id, student_id (FK), answers (JSONB map),
               is_in_progress, remaining_seconds, correct/incorrect count

pyq            id, year (text), chapter, question, option_a-d,
               correct_option (always uppercase A|B|C|D)

notes          id, name, link, visibility (all|11|12|neet|private),
               is_link, sort_order, is_private

offline_tests  id, name, test_date, full_marks, batch,
               student_marks (JSONB: {student_id: marks})

notifications  id, type, title, body, target_type, target_batches[]

batches        id, name, class_level, sort_order

developer_info id, is_enabled, is_maintenance, name, avatar_url,
               links (JSONB array)

app_settings   key (PK), value (JSONB)
`

---

## Workflows

**Student Login:** Login form -> SHA-256 hash -> query users -> validate -> Hive session -> /student/dashboard

**Admin Login:** Enter 4444/4444 -> trigger detected -> AdminLoginDialog -> real credentials -> /admin/dashboard

**Exam Creation:** Title + batches + questions (manual or Gemini AI) -> save -> publish toggle -> Realtime fires -> toast on all student apps -> notification inserted

**Student Exam:** Browse filtered exams -> coin-gate check -> start -> CBTPortal (live JSONB save per answer) -> timer expires or submit -> NEET score calculated -> result screen

**PYQ Upload:** Enter year name -> pick CSV -> validate (correct_option A/B/C/D only) -> chunk insert (100/batch) -> delete old year rows not in new batch -> invalidate providers

**Maintenance Mode:** Admin toggles ON -> saves to developer_info -> StreamProvider emits to all clients -> StudentShell shows MaintenanceScreen -> admin sees normal app

---

## State Management

`dart
// StreamProvider: Realtime, always live
final developerInfoProvider = StreamProvider<DeveloperInfoModel>((ref) async* {
  await for (final data in SupabaseService.instance.streamDeveloperInfo()) {
    yield data == null ? DeveloperInfoModel.defaults() : DeveloperInfoModel.fromJson(data);
  }
});

// FutureProvider.family: parameterised queries
final pyqByChapterProvider = FutureProvider.family<List<PYQModel>, String>(
  (ref, chapter) => SupabaseService.instance.getPYQByChapter(chapter),
);

// StateNotifierProvider: mutable local state
final pyqTestProvider = StateNotifierProvider<PYQTestNotifier, PYQTestState>(
  (_) => PYQTestNotifier(),
);

// Provider: derived value
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider)?.isAdmin ?? false;
});
`

---

## Routing

`
/                      SplashScreen
/login                 LoginScreen

/admin                 AdminShell
  /admin/dashboard     /admin/database   /admin/batches
  /admin/exams         /admin/exams/create
  /admin/pyq           /admin/notes      /admin/notifications
  /admin/activity      /admin/developer  /admin/credits

/student               StudentShell
  /student/dashboard   /student/tests    /student/results
  /student/pyq         /student/flashcards /student/glossary
  /student/bio-lab     /student/games    /student/notes
  /student/chat        /student/history
`

Redirect: no session -> /login | admin session -> /admin/dashboard | student -> /student/dashboard

---

## Setup and Deployment

`ash
# 1. Clone
git clone https://github.com/YOUR_USERNAME/praeparatio.git
cd praeparatio
flutter pub get

# 2. Configure Supabase in lib/core/constants/supabase_config.dart

# 3. Run supabase_schema.sql in Supabase SQL Editor

# 4. Run locally
flutter run -d chrome

# 5. Build
flutter build web --release
flutter build apk --release

# 6. Deploy (vercel.json pre-configured)
vercel --prod
`

---

## SQL Migrations

`sql
ALTER TABLE pyq ALTER COLUMN year TYPE text USING year::text;
ALTER TABLE developer_info ADD COLUMN IF NOT EXISTS is_maintenance boolean DEFAULT false;
ALTER TABLE notes ADD COLUMN IF NOT EXISTS sort_order integer DEFAULT 0;
ALTER TABLE notes ADD COLUMN IF NOT EXISTS is_private boolean DEFAULT false;
ALTER TABLE exams ADD COLUMN IF NOT EXISTS allow_download boolean DEFAULT false;
ALTER TABLE exam_results ADD COLUMN IF NOT EXISTS is_in_progress boolean DEFAULT false;
ALTER TABLE exam_results ADD COLUMN IF NOT EXISTS started_at timestamptz;
ALTER TABLE exam_results ADD COLUMN IF NOT EXISTS remaining_seconds integer DEFAULT 0;
CREATE INDEX IF NOT EXISTS idx_pyq_year_chapter ON pyq(year, chapter);
`

---

<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:06B6D4,50:7C3AED,100:4E46A8&height=140&section=footer&animation=twinkling" width="100%"/>

**Built with love by [Deepan Pramanick](https://github.com/DeepanPramanick)**

*"Examination is nothing but fine preparation."*

[![GitHub](https://img.shields.io/badge/GitHub-DeepanPramanick-181717?style=for-the-badge&logo=github)](https://github.com/DeepanPramanick)

</div>