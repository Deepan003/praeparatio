# SOFTWARE DESIGN DOCUMENT (SDD)
## High Level Design (HLD) + Low Level Design (LLD)

**Project:** PRAEPARATIO — NEET Biology Preparation Platform
**Document Version:** 1.0
**Status:** Approved
**Author:** Deepan Pramanick
**Date:** 2026

---

## Table of Contents

**PART A — HIGH LEVEL DESIGN (HLD)**
1. [System Architecture Overview](#1-system-architecture-overview)
2. [Component Diagram](#2-component-diagram)
3. [Technology Stack Architecture](#3-technology-stack-architecture)
4. [Deployment Architecture](#4-deployment-architecture)
5. [Database Architecture](#5-database-architecture)
6. [Security Architecture](#6-security-architecture)

**PART B — LOW LEVEL DESIGN (LLD)**
7. [Module Design — Core Layer](#7-module-design--core-layer)
8. [Module Design — Service Layer](#8-module-design--service-layer)
9. [Module Design — Provider Layer](#9-module-design--provider-layer)
10. [Module Design — Admin Features](#10-module-design--admin-features)
11. [Module Design — Student Features](#11-module-design--student-features)
12. [Sequence Diagrams](#12-sequence-diagrams)
13. [Class Diagrams](#13-class-diagrams)
14. [Algorithm Design](#14-algorithm-design)
15. [Error Handling Design](#15-error-handling-design)

---

# PART A — HIGH LEVEL DESIGN (HLD)

## 1. System Architecture Overview

### 1.1 Architectural Pattern

PRAEPARATIO uses a **Client-Heavy Architecture** with a Backend-as-a-Service (BaaS):

```
┌─────────────────────────────────────────────────────────────┐
│                    ARCHITECTURAL LAYERS                      │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                 PRESENTATION LAYER                   │   │
│  │    Flutter Widgets (Admin Screens + Student Screens) │   │
│  └───────────────────────┬─────────────────────────────┘   │
│                           │                                 │
│  ┌───────────────────────▼─────────────────────────────┐   │
│  │                  STATE LAYER                         │   │
│  │           Riverpod Providers                         │   │
│  │  (StreamProvider, FutureProvider, StateNotifier)    │   │
│  └───────────────────────┬─────────────────────────────┘   │
│                           │                                 │
│  ┌───────────────────────▼─────────────────────────────┐   │
│  │                  SERVICE LAYER                       │   │
│  │   SupabaseService | AuthService | NotificationService│   │
│  │   PdfService | CsvService | AiService | StorageService│  │
│  └───────────────────────┬─────────────────────────────┘   │
│                           │                                 │
│  ┌───────────────────────▼─────────────────────────────┐   │
│  │                  DATA LAYER                          │   │
│  │        supabase_flutter SDK (PostgREST + WS)        │   │
│  │        hive_flutter (Local Cache)                   │   │
│  └───────────────────────┬─────────────────────────────┘   │
└───────────────────────────┼─────────────────────────────────┘
                            │
               ┌────────────▼────────────┐
               │     SUPABASE CLOUD      │
               │  PostgreSQL + Realtime  │
               └─────────────────────────┘
```

### 1.2 Key Architectural Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Backend | Supabase BaaS | Eliminates need for custom server; provides Realtime, REST, Storage |
| State Management | Riverpod | Strong typing, testable, no Context dependency, auto-dispose |
| Navigation | GoRouter with Shell Routes | Persistent nav chrome, deep links, URL strategy for web |
| Authentication | Custom SHA-256 | Admin creates accounts; no email required; simpler for private institute |
| Local Storage | Hive | Fast key-value store; used for offline flashcards and session |
| Animations | CustomPainter | Full control over biological diagrams; 60fps on canvas |
| PDF Generation | pdf package | Client-side generation; no server required |

---

## 2. Component Diagram

```
┌───────────────────────────────────────────────────────────────────┐
│                    PRAEPARATIO APPLICATION                         │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │                      ROUTER COMPONENT                         │ │
│  │  GoRouter: /login | /admin/** | /student/**                  │ │
│  │  Shell Routes: AdminShell | StudentShell                     │ │
│  └────────────────────────────┬─────────────────────────────────┘ │
│                               │                                   │
│  ┌────────────────────────────▼─────────────────────────────────┐ │
│  │                    FEATURE COMPONENTS                         │ │
│  │                                                              │ │
│  │  ┌────────────────────┐    ┌──────────────────────────────┐ │ │
│  │  │  ADMIN FEATURES    │    │   STUDENT FEATURES           │ │ │
│  │  │                    │    │                              │ │ │
│  │  │ • Dashboard        │    │ • Dashboard                  │ │ │
│  │  │ • Database (CRUD)  │    │ • CBT Portal (Exam Engine)   │ │ │
│  │  │ • Batch Management │    │ • PYQ (3 modes)              │ │ │
│  │  │ • Exam Creator     │    │ • Bio Lab (32 diagrams)      │ │ │
│  │  │ • Exam Engine      │    │ • Flashcards                 │ │ │
│  │  │ • PYQ Upload       │    │ • Games                      │ │ │
│  │  │ • Notes Admin      │    │ • Notes (collapsible)        │ │ │
│  │  │ • Notifications    │    │ • Chatbot (Gemini AI)        │ │ │
│  │  │ • Developer Config │    │ • Lesson Planner             │ │ │
│  │  │ • Statistics       │    │ • History + Results          │ │ │
│  │  └────────────────────┘    │ • Developer Modal            │ │ │
│  │                            │ • Maintenance Screen         │ │ │
│  │  ┌────────────────────┐    └──────────────────────────────┘ │ │
│  │  │  SHARED FEATURES   │                                      │ │
│  │  │ • Auth (Login)     │                                      │ │
│  │  │ • Splash Screen    │                                      │ │
│  │  └────────────────────┘                                      │ │
│  └──────────────────────────────────────────────────────────────┘ │
│                               │                                   │
│  ┌────────────────────────────▼─────────────────────────────────┐ │
│  │                  STATE MANAGEMENT (Riverpod)                   │ │
│  │                                                              │ │
│  │  authProvider       examProvider       pyqProvider           │ │
│  │  batchesProvider    developerProvider  notificationProvider  │ │
│  │  studentProvider                                             │ │
│  └────────────────────────────┬─────────────────────────────────┘ │
│                               │                                   │
│  ┌────────────────────────────▼─────────────────────────────────┐ │
│  │                    SERVICE LAYER                               │ │
│  │                                                              │ │
│  │  SupabaseService   AuthService       NotificationService     │ │
│  │  PdfService        CsvService        AiService               │ │
│  │  StorageService    ToastService      DownloadHelper          │ │
│  └────────────────────────────┬─────────────────────────────────┘ │
│                               │                                   │
│  ┌────────────────────────────▼─────────────────────────────────┐ │
│  │                    SHARED WIDGETS                              │ │
│  │                                                              │ │
│  │  AdaptiveNav    GlassCard    CustomButton    ExamToast       │ │
│  │  NotificationBell  ExamStartDialog  DownloadButton          │ │
│  │  Skeleton      StatCard    AnimatedLogo   BadgeWidget        │ │
│  └──────────────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────────────┘
```

---

## 3. Technology Stack Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                  TECHNOLOGY STACK                             │
│                                                             │
│  FRONTEND                                                   │
│  ─────────                                                  │
│  Language:      Dart 3.x (null-safe)                       │
│  Framework:     Flutter 3.x                                 │
│  State:         flutter_riverpod ^2.5.1                    │
│  Navigation:    go_router ^14.2.7                          │
│  UI Extra:      flutter_animate ^4.5.0                     │
│  Charts:        fl_chart ^0.69.0                           │
│  Calendar:      table_calendar ^3.1.2                      │
│  Markdown:      flutter_markdown ^0.7.4                    │
│                                                             │
│  BACKEND (BaaS)                                             │
│  ──────────────                                             │
│  Provider:      Supabase                                   │
│  Database:      PostgreSQL (via Supabase)                  │
│  Realtime:      Supabase Realtime (WebSockets)             │
│  API:           PostgREST (auto-generated REST)            │
│  Storage:       Supabase Storage (future)                  │
│  SDK:           supabase_flutter ^2.5.0                    │
│                                                             │
│  LOCAL STORAGE                                              │
│  ─────────────                                              │
│  Cache:         Hive + hive_flutter                        │
│  Preferences:   shared_preferences ^2.3.2                  │
│                                                             │
│  UTILITIES                                                  │
│  ──────────                                                 │
│  PDF:           pdf ^3.11.1 + printing ^5.13.1            │
│  CSV:           csv ^6.0.0                                 │
│  Files:         file_picker ^8.1.2                         │
│  Network:       http ^1.2.2                                │
│  Images:        cached_network_image ^3.4.1               │
│  WebView:       webview_flutter ^4.10.0                    │
│  Hash:          crypto ^3.0.5                              │
│  UUID:          uuid ^4.5.1                                │
│  URLs:          url_launcher ^6.3.1                        │
│                                                             │
│  DEPLOYMENT                                                 │
│  ──────────                                                 │
│  Web Host:      Vercel                                     │
│  Web Config:    vercel.json (Flutter build + SPA rewrite)  │
│  Android:       APK (flutter build apk --release)          │
│  Web Strategy:  usePathUrlStrategy() (no # in URLs)        │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Deployment Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    DEPLOYMENT DIAGRAM                             │
└─────────────────────────────────────────────────────────────────┘

  ┌────────────────────────────────────────────────────────────┐
  │                      INTERNET                               │
  └────────────────────────────────────────────────────────────┘
         │                          │                    │
         ▼                          ▼                    ▼
  ┌─────────────┐           ┌──────────────┐    ┌──────────────┐
  │   VERCEL    │           │  SUPABASE    │    │   GOOGLE     │
  │   (Web CDN) │           │   CLOUD      │    │   GEMINI API │
  │             │           │              │    │              │
  │ build/web/  │           │ PostgreSQL   │    │ /v1/         │
  │  ├index.html│           │ Realtime WS  │    │ generateConten│
  │  ├main.dart │           │ PostgREST    │    │              │
  │  │  .js     │           │ Auth (unused)│    │ User provides│
  │  └assets/   │           │ Storage      │    │ own API key  │
  │             │           │              │    └──────────────┘
  │ vercel.json │           │ Region:      │
  │  buildCmd:  │           │ Closest to   │
  │  flutter    │           │ India        │
  │  build web  │           └──────────────┘
  └─────────────┘                  ▲
         │                         │
         │  HTTPS                  │ HTTPS/WSS
         ▼                         │
  ┌──────────────────────────────────────────────────────────┐
  │                    CLIENT DEVICES                          │
  │                                                          │
  │  ┌────────────────────┐    ┌────────────────────────┐   │
  │  │   WEB BROWSER      │    │   ANDROID DEVICE       │   │
  │  │   (Chrome/Firefox/ │    │   (APK installed)      │   │
  │  │    Safari/Edge)    │    │                        │   │
  │  │                    │    │ Flutter Engine         │   │
  │  │ Flutter Web        │    │ + Dart VM              │   │
  │  │ (JS compiled)      │    │ + Native Bridge        │   │
  │  │                    │    │                        │   │
  │  │ Local: Hive (IndexDB│   │ Local: Hive (SQLite)   │   │
  │  └────────────────────┘    └────────────────────────┘   │
  └──────────────────────────────────────────────────────────┘
```

### 4.1 Vercel Configuration

```json
{
  "buildCommand": "flutter build web --release",
  "outputDirectory": "build/web",
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
```

The SPA rewrite ensures all routes (e.g. `/student/dashboard`) serve `index.html`, allowing GoRouter to handle client-side routing.

---

## 5. Database Architecture

### 5.1 Table Relationships (Schema Design)

```
┌─────────────────────────────────────────────────────────────────┐
│                   DATABASE SCHEMA ARCHITECTURE                   │
└─────────────────────────────────────────────────────────────────┘

CORE TABLES (Student data)
───────────────────────────
users               ← Central table. All students + admin
exam_results        ← FK: student_id → users.id
lesson_plans        ← FK: student_id → users.id
lesson_tasks        ← FK: plan_id → lesson_plans.id

EXAM TABLES
────────────
exams               ← Independent. Linked to batches via text array
questions           ← FK: exam_id → exams.id (CASCADE DELETE)
exam_results        ← Links users to exams (no FK on exam_id — exam may be deleted)

CONTENT TABLES (Admin-managed)
───────────────────────────────
pyq                 ← Independent. Year (text), chapter, question data
notes               ← Independent. Section-organized links/PDFs
offline_tests       ← Batch-scoped. Student marks in JSONB
batches             ← Batch definitions with class_level

SYSTEM TABLES
──────────────
notifications       ← Admin sends; students receive
notification_reads  ← Tracks which student read which notification
developer_info      ← Single row. Controls dev button + maintenance
app_settings        ← Key-value config store

RELATIONSHIPS SUMMARY:
  users (1)     ─────────────────── (N) exam_results
  users (1)     ─────────────────── (N) lesson_plans
  lesson_plans (1) ────────────── (N) lesson_tasks
  exams (1)     ─────────────────── (N) questions [CASCADE DELETE]
  notifications (1) ────────────── (N) notification_reads
  exams.target_batches[] ↔ users.batch  [array match, application-level]
```

### 5.2 Key Design Decisions

| Decision | Rationale |
|---|---|
| No FK from exam_results to exams | Exams can be deleted; results are historical records and must persist |
| target_batches as text[] in exams | Allows many-to-many without junction table; simple array contains check |
| student_marks as JSONB in offline_tests | Variable number of students per test; flexible without per-student rows |
| answers as JSONB in exam_results | Allows partial save (resume); single row per attempt |
| developer_info as a single-row table | Only one developer profile needed; Realtime stream on this table |
| year as TEXT in pyq table | Supports "2025 Cancelled", "2025 Retest" — pure integer was too restrictive |

---

## 6. Security Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                    SECURITY LAYERS                             │
│                                                              │
│  LAYER 1: Transport Security                                 │
│  ─────────────────────────────                               │
│  All communication over HTTPS / WSS (TLS 1.3)               │
│  Vercel provides SSL for web, Supabase for all API calls     │
│                                                              │
│  LAYER 2: Authentication                                     │
│  ─────────────────────────                                   │
│  • Passwords hashed with SHA-256 before storage             │
│  • plaintext password stored ONLY in users.password_plain   │
│    for admin visibility (admin can reset forgotten passwords)│
│  • Sessions persisted to Hive (device-local, not server)    │
│  • No JWT tokens (custom session model)                     │
│                                                              │
│  LAYER 3: Authorization                                      │
│  ────────────────────────                                    │
│  • Role check: isAdmin flag in session                      │
│  • GoRouter redirects admin/student to correct shell        │
│  • Exam visibility: target_batches filter in query          │
│  • Content visibility: notes.visibility field check         │
│  • Maintenance bypass: isAdmin check in StudentShell        │
│                                                              │
│  LAYER 4: API Security                                       │
│  ───────────────────────                                     │
│  • Supabase anon key used (designed to be public)           │
│  • Row Level Security (RLS): disabled for simplicity        │
│    (single-institution private app; admin creates all accts)│
│  • Service role key: NEVER in client code                   │
│                                                              │
│  LAYER 5: Data Security                                      │
│  ────────────────────────                                    │
│  • AI API key: stored in SharedPreferences (device-local)   │
│  • Never transmitted to any server except Google Gemini     │
│  • PDF generation: client-side (no server touch)           │
│  • CSV files: processed entirely in client memory          │
└──────────────────────────────────────────────────────────────┘
```

---

# PART B — LOW LEVEL DESIGN (LLD)

## 7. Module Design — Core Layer

### 7.1 AppColors — Colour System Design

```
AppColors (abstract class — no instances)
│
├── Neumorphic System
│   ├── neuBackground: Color(0xFFF0F2F8)  ← page background
│   ├── neuSurface: Color(0xFFF6F8FD)     ← card surface
│   ├── neuPressedColor: Color(0xFFE8EAF0) ← pressed state
│   └── neuRaisedSoft: List<BoxShadow>    ← standard card shadow
│
├── Brand System
│   ├── primary: Color(0xFF4E46A8)
│   ├── accent: Color(0xFF7C3AED)
│   ├── primaryGradient: LinearGradient(primary → accent)
│   └── primarySurface: primary.withOpacity(0.08)
│
├── Semantic System
│   ├── success/successSurface
│   ├── error/errorSurface
│   ├── warning/warningSurface
│   ├── info/infoSurface
│   └── border, textPrimary, textSecondary, textHint
│
└── Batch Coding
    ├── batch11: Color for Class 11
    ├── batch12: Color for Class 12
    └── batchNeet: Color for NEET Exclusive
```

### 7.2 GoRouter Design

```
routerProvider (Provider<GoRouter>)
│
├── Redirect Logic (runs on every navigation)
│   ├── if !authenticated → /login
│   ├── if admin + /student → /admin/dashboard
│   └── if student + /admin → /student/dashboard
│
├── Routes
│   ├── / → SplashScreen (auto-redirect)
│   ├── /login → LoginScreen
│   ├── ShellRoute (/admin) → AdminShell
│   │   ├── /admin/dashboard
│   │   ├── /admin/database
│   │   ├── /admin/batches
│   │   ├── /admin/exams → /admin/exams/create, /admin/exams/:id
│   │   ├── /admin/pyq
│   │   ├── /admin/notes
│   │   ├── /admin/notifications
│   │   ├── /admin/activity
│   │   ├── /admin/credits
│   │   └── /admin/developer (maintenance, chatbot AI, exam AI, dev profile)
│   └── ShellRoute (/student) → StudentShell
│       ├── /student/dashboard      (Home)
│       ├── /student/tests          (Online Exams)
│       ├── /student/results        (Offline Results)
│       ├── /student/pyq            (PYQs)
│       ├── /student/flashcards     (Cards)
│       ├── /student/glossary       (Glossary)
│       ├── /student/bio-lab        (Bio Lab)
│       ├── /student/games          (Games)
│       ├── /student/notes          (Notes)
│       ├── /student/chat           (Biology Doubt Solver)
│       ├── /student/history        (History)
│       └── /student/lesson-planner (Lesson Planner — routed but NOT in nav bar)
```

---

## 8. Module Design — Service Layer

### 8.1 SupabaseService — Internal Architecture

```
SupabaseService (Singleton)
│
├── _db: SupabaseClient (from Supabase.instance.client)
│
├── USERS SECTION
│   ├── getStudents() → List<UserModel>
│   ├── getStudentById(id) → UserModel?
│   ├── upsertUser(UserModel) → void
│   ├── deleteUser(id) → void
│   ├── banUser(id) / unbanUser(id) → void
│   ├── updatePrepcoins(id, amount) → void
│   ├── updateLoginStreak(id, streakData) → void
│   ├── updateMonthlyPayment(id, month, paid) → void
│   └── searchStudents(query) → List<UserModel>
│
├── BATCHES SECTION
│   ├── getBatches() → List<BatchModel>
│   ├── upsertBatch(BatchModel) → void
│   ├── deleteBatch(id) → void
│   ├── promoteStudents(studentIds, newBatch) → void
│   │   └── [migrates offline_tests.student_marks, exam target_batches]
│   ├── syncStudentClassForBatch(batchName, classLevel) → void
│   └── syncAllStudentClasses() → void
│
├── EXAMS SECTION
│   ├── streamPublishedExams() → Stream<List<ExamModel>>  [Realtime]
│   ├── streamAllExams() → Stream<List<ExamModel>>        [Realtime]
│   ├── getExamWithQuestions(examId) → ExamModel
│   ├── upsertExam(ExamModel) → String [returns exam id]
│   ├── deleteExam(id) → void
│   ├── publishExam(id) / unpublishExam(id) → void
│   └── getExamsForBatch(batch) → List<ExamModel>
│
├── QUESTIONS SECTION
│   ├── upsertQuestions(examId, questions) → void
│   └── deleteQuestionsForExam(examId) → void
│
├── EXAM RESULTS SECTION
│   ├── submitResult(ExamResultModel) → void
│   ├── getResultsForStudent(studentId) → List<ExamResultModel>
│   ├── getResultsForExam(examId) → List<ExamResultModel>
│   ├── getFirstAttemptResults(examId) → List<ExamResultModel>
│   ├── saveInProgressResult(resultId, answers, remaining) → void
│   │   └── [JSONB patch: answers || newAnswers]
│   └── getInProgressForExam(examId, studentId) → ExamResultModel?
│
├── PYQ SECTION
│   ├── getAllPYQ() → List<PYQModel>          [limit 20,000]
│   ├── getPYQByChapter(chapter) → List<PYQModel>
│   ├── getPYQByYears(years) → List<PYQModel>
│   ├── getPYQByChapters(chapters) → List<PYQModel>
│   ├── getAvailablePYQYears() → List<String>  [numeric sort, newest first]
│   ├── getAvailablePYQChapters() → List<String>
│   ├── replacePYQForYear(yearName, questions) → void
│   │   ├── chunked INSERT (100 per chunk)
│   │   ├── collect inserted IDs
│   │   └── DELETE old rows WHERE year=yearName AND id NOT IN insertedIds
│   └── replacePYQ(questions) → void  [full replace, legacy]
│
├── NOTES SECTION
│   ├── streamAllNotes() → Stream<List<NoteModel>>  [Realtime]
│   ├── upsertNote(NoteModel) → void
│   └── deleteNote(id) → void
│
├── OFFLINE TESTS SECTION
│   ├── getOfflineTestsForBatch(batch) → List<OfflineTestModel>
│   ├── upsertOfflineTest(OfflineTestModel) → void
│   ├── deleteOfflineTest(id) → void
│   └── enterMarks(testId, studentId, marks) → void
│
├── LESSON PLANS SECTION
│   ├── getLessonPlansForStudent(studentId) → List<LessonPlanModel>
│   ├── upsertLessonPlan(LessonPlanModel) → void
│   ├── deleteLessonPlan(id) → void
│   ├── upsertLessonTask(LessonTask) → void
│   └── deleteLessonTask(id) → void
│
├── NOTIFICATIONS SECTION
│   ├── streamNotificationsForStudent(studentId, batch) → Stream
│   ├── getNotificationsForStudent(studentId, batch) → List<NotificationModel>
│   │   └── [uses Supabase RPC function 'get_notifications_for_student']
│   ├── getUnreadCount(studentId, batch) → int
│   │   └── [uses Supabase RPC function 'get_unread_count']
│   ├── insertNotification(data) → void
│   ├── markRead(notificationId, studentId) → void
│   └── markAllRead(notificationIds, studentId) → void
│
├── DEVELOPER INFO SECTION
│   ├── streamDeveloperInfo() → Stream<Map<String,dynamic>?>  [Realtime]
│   ├── getDeveloperInfo() → Map<String,dynamic>?
│   └── upsertDeveloperInfo(data) → void
│       └── [checks if record exists: update if yes, insert if no]
│
└── APP SETTINGS SECTION
    ├── getSetting(key) → dynamic
    └── setSetting(key, value) → void
```

### 8.2 AuthService Design

```
AuthService (Singleton)
│
├── hashPassword(String password) → String
│   └── sha256.convert(utf8.encode(password)).toString()
│
├── login(String username, String password) → UserModel
│   ├── hash = hashPassword(password)
│   ├── query: SELECT * FROM users WHERE username = ?
│   ├── if null → throw 'Username not found'
│   ├── if hash != user.password_hash → throw 'Wrong password'
│   ├── if user.is_banned → throw 'Account suspended'
│   └── return UserModel
│
├── logout() → void
│   └── StorageService.instance.clearSession()
│
├── saveSession(UserModel user) → void
│   └── Hive box.put('session', user.toJson())
│
├── loadSession() → UserModel?
│   └── Hive box.get('session') → UserModel.fromJson()
│
└── isAdminTrigger(String username, String password) → bool
    └── username == AppConstants.adminTriggerUsername &&
        password == AppConstants.adminTriggerPassword
```

### 8.3 NotificationService Design

```
NotificationService (Singleton)
│
├── send({type, title, body, targetType, targetBatches,
│         targetStudentId, data, createdBy}) → Future<void>
│   ├── INSERT INTO notifications (all fields)
│   └── _cleanup() → keep only 50 most recent
│
├── notifyExamPublished(examTitle, createdBy) → Future<void>
│   ├── ToastService.instance.show(ToastData(type: examPublished))
│   └── send(type: examPublished, targetType: 'all')
│
├── notifyNotesUploaded(noteName, createdBy, visibility) → Future<void>
│   ├── ToastService.instance.show(...)
│   └── send(type: notesUploaded, targetType: based on visibility)
│
├── notifyPyqAdded(paperTitle, createdBy) → Future<void>
│   ├── ToastService.instance.show(...)
│   └── send(type: pyqAdded, targetType: 'all')
│
└── notifyWelcome(studentId, studentName) → Future<void>
    └── send(type: welcome, targetType: 'student', targetStudentId: id)
```

---

## 9. Module Design — Provider Layer

### 9.1 Provider Dependency Graph

```
                    ┌─────────────────┐
                    │   authProvider   │
                    │ (StateNotifier)  │
                    └────────┬────────┘
                             │ derives
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
  ┌─────────────────┐ ┌───────────┐ ┌─────────────────┐
  │currentUserProvider│ │isAdminProv│ │ (used in router) │
  └─────────────────┘ └───────────┘ └─────────────────┘

  ┌─────────────────┐     independent (all watch SupabaseService directly)
  │ examProvider    │
  │ (StreamProvider)│     ← streams Supabase Realtime
  └─────────────────┘

  ┌─────────────────┐
  │ developerProv   │     ← streams Supabase Realtime (developer_info table)
  │ (StreamProvider)│
  └─────────────────┘

  ┌─────────────────┐
  │ pyqProvider     │     ← FutureProvider, invalidated after PYQ upload
  └─────────────────┘

  ┌─────────────────┐
  │ pyqTestProvider │     ← StateNotifier managing in-progress PYQ session
  └─────────────────┘
```

### 9.2 Auth State Machine

```
                ┌──────────────┐
         ┌─────►│  LOADING     │
         │      │ (AsyncLoading)│
         │      └──────┬───────┘
         │             │ Session loaded from Hive
         │             ▼
         │      ┌──────────────┐
  App    │      │   NULL       │◄──────────────────────┐
  Start  │      │ (No session) │                       │
         │      └──────┬───────┘                       │
         │             │ login() called                 │
         │             ▼                               │ logout() called
         │      ┌──────────────┐                       │
         │      │  VALIDATING  │                       │
         │      │ (checking DB)│                       │
         │      └──────┬───────┘                       │
         │             │                               │
         │     ┌───────┴────────┐                      │
         │     ▼                ▼                      │
         │ ┌──────────┐  ┌──────────┐                  │
         │ │  ERROR   │  │ LOGGED   │──────────────────┘
         │ │(bad creds│  │   IN     │
         │ │ banned)  │  │AsyncData │
         │ └──────────┘  └──────────┘
         │                    │
         │                    │ is_admin?
         │             ┌──────┴──────┐
         │             ▼             ▼
         │      ┌──────────┐  ┌──────────┐
         └──────│  ADMIN   │  │ STUDENT  │
                │  SHELL   │  │  SHELL   │
                └──────────┘  └──────────┘
```

---

## 10. Module Design — Admin Features

### 10.1 Exam Creator — State Flow

```
ExamCreatorScreen State Machine
│
├── Step 1: METADATA
│   State: {title, description, targetBatches[], duration,
│           difficulty, expRequired, allowDownload,
│           visibilityStart, visibilityEnd}
│   Validation: title not empty, at least 1 batch selected
│
├── Step 2: QUESTIONS
│   State: {questions: List<QuestionModel>}
│   Sub-modes:
│   ├── MANUAL: QuestionFormWidget per question
│   │   State per form: {text, optA, optB, optC, optD, correct, chapter, explanation}
│   └── AI_GENERATION:
│       ├── Input: topicPrompt, questionCount
│       ├── Call: AiService.generateExamQuestions(prompt)
│       ├── Parse: JSON response → List<QuestionModel>
│       └── Allow: edit generated questions before saving
│
├── Step 3: SCHEDULE
│   State: {visibilityStart?, visibilityEnd?}
│   (Optional — null means always visible when published)
│
└── Step 4: SAVE
    ├── SupabaseService.upsertExam(examModel) → examId
    ├── SupabaseService.upsertQuestions(examId, questions)
    └── Navigate to /admin/exams
```

### 10.2 PYQ Upload — Algorithm

```
ALGORITHM: replacePYQForYear(yearName, questions)

INPUT: yearName (String), questions (List<PYQModel>)

STEP 1: Map questions to insert data
  data = questions.map(q => {
    year: yearName,  ← OVERRIDE year from model with yearName parameter
    chapter: q.chapter, question: q.question,
    option_a: q.optionA, ..., correct_option: q.correctOption
  })

STEP 2: Chunked insert
  chunkSize = 100
  insertedIds = []
  FOR i = 0 TO data.length STEP chunkSize:
    chunk = data[i : i+chunkSize]
    result = INSERT INTO pyq (chunk) RETURNING id
    insertedIds.addAll(result.ids)

STEP 3: Safe deletion
  IF insertedIds.isNotEmpty:
    DELETE FROM pyq
    WHERE year = yearName
    AND id NOT IN (insertedIds)
  ELSE:
    // Nothing was inserted — skip deletion (don't delete everything)

OUTPUT: void (throws on error)

WHY THIS APPROACH:
- Inserting before deleting means NO DATA LOSS if insert fails partway
- Only deletes OLD rows for THIS YEAR — other years are never touched
- Chunks of 100 avoid Supabase request size limits
```

### 10.3 Notes Admin — Sort Order Bug Fix

```
PROBLEM (Before Fix):
  structureChanged = currentIds != _lastLoadedIds
  → Set != Set in Dart compares OBJECT REFERENCES, not VALUES
  → {1,2,3} != {1,2,3} is always TRUE (different Set instances)
  → _initFrom() ran on EVERY Supabase stream emit
  → This reset the local sort order back to DB order every time
  → Admin's reordering was lost every few seconds

FIX (Implemented):
  sameIds = currentIds.length == _lastLoadedIds.length &&
            currentIds.containsAll(_lastLoadedIds)
  structureChanged = !sameIds || allNotes.length != _lastLoadedCount
  → Now uses VALUE comparison — only re-initialises when actual IDs change
  → Local sort order persists until admin adds/removes a note
```

---

## 11. Module Design — Student Features

### 11.1 CBT Portal (Exam Engine) — Detailed Design

```
CBTPortalState:
  currentQuestionIndex: int
  answers: Map<String, String>  ← {questionId: selectedOption}
  remainingSeconds: int
  isSubmitted: bool
  timer: AnimationController

ON MOUNT:
  1. Call getInProgressForExam(examId, studentId)
  2. IF found:
     - answers = savedResult.answers
     - remainingSeconds = savedResult.remainingSeconds
     - Set timer to remainingSeconds
  3. ELSE:
     - answers = {}
     - remainingSeconds = exam.durationMinutes * 60
     - Create new in-progress result in DB

ON ANSWER SELECT (questionId, option):
  1. answers[questionId] = option
  2. setState()
  3. saveInProgressResult(resultId, answers, remainingSeconds)
     [JSONB PATCH: answers = answers || '{"qid": "A"}'::jsonb]
     [This is non-blocking — UI doesn't wait]

ON TIMER TICK:
  1. remainingSeconds--
  2. IF remainingSeconds == 0: autoSubmit()

ON SUBMIT (manual or timer):
  1. correctCount = answers where answer == question.correctOption
  2. incorrectCount = answers where answer != correctOption (and answered)
  3. unattemptedCount = totalQuestions - answered
  4. neetScore = correctCount * 4 - incorrectCount
  5. UPDATE exam_results:
     is_in_progress = false, score = neetScore,
     correct_count, incorrect_count, unattempted_count,
     time_taken_seconds, submitted_at = now()
  6. Navigate to ExamResultScreen

RESUME LOGIC:
  - is_in_progress = true in DB marks it as resumable
  - If student re-opens exam and result exists with is_in_progress=true,
    load it and continue from saved state
  - Only one in-progress attempt per student per exam
```

### 11.2 Bio Lab Diagram System — Architecture

```
REGISTRY PATTERN:

buildBioDiagram(String id, int step, double t) → Widget?
│
├── Switch on id:
│   ├── 'mitosis' → _DiagramCanvas(_MitosisPainter(step, t))
│   ├── 'meiosis' → _DiagramCanvas(_MeiosisPainter(step, t))
│   ├── ... (16 painters in bio_diagram_painter.dart)
│   ├── ... (16 painters in bio_diagram_painter_2.dart via part)
│   └── default → null  ← SAFE FALLBACK: show Steps mode

_DiagramCanvas (StatelessWidget):
  └── LayoutBuilder → compute height = min(width * 0.62, 340)
      └── CustomPaint(painter: painter, size: Size(w, h))

Each CustomPainter:
  ├── Fields: step (int), t (double 0→1 looping)
  ├── paint(Canvas, Size):
  │   ├── canvas.translate(width/2, height/2) ← center origin
  │   ├── switch(step): draw appropriate stage
  │   └── animate using t (sin/cos for smooth motion)
  └── shouldRepaint: step != old.step || t != old.t

PART FILE SYSTEM:
  bio_diagram_painter.dart:
    import 'dart:math' as math;
    part 'bio_diagram_painter_2.dart';  ← includes part file
    [Registry + 16 painters + shared helpers]

  bio_diagram_painter_2.dart:
    part of 'bio_diagram_painter.dart';  ← access all private symbols
    [16 more painters — use _fill, _stroke, _label, _arrow, _dashedLine]

WHY PART DIRECTIVE:
  - Shares private helpers (_fill, _stroke, etc.) without making them public
  - Keeps file sizes manageable (~1500 lines each)
  - Single logical compilation unit for the dart compiler
```

### 11.3 Developer Modal — Animation Design

```
_TravelingBorderPainter:
  INPUT: t (double, 0→1, continuously repeating at 4s period)
  
  COLORS (9 stops, seamless loop):
    [indigo, violet, pink, red, orange, yellow, green, cyan, blue, indigo]
  
  ALGORITHM:
    rect = element bounding box
    rRect = RRect.fromRectXY(rect.deflate(strokeWidth/2), 16, 16)
    
    shader = SweepGradient(
      colors: _colors,
      transform: GradientRotation(t * 2π)  ← KEY: rotates with time
    ).createShader(rect)
    
    // Layer 1: Glow
    canvas.drawRRect(rRect, Paint()
      ..shader = shader
      ..strokeWidth = 9
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5))
    
    // Layer 2: Sharp stroke
    canvas.drawRRect(rRect, Paint()
      ..shader = shader
      ..strokeWidth = 2.5)
  
  VISUAL RESULT:
    As t goes 0→1 (one full period = 4 seconds):
    → GradientRotation goes 0 → 2π (full 360°)
    → ALL rainbow colors rotate around the border
    → Creates the illusion of colors traveling around the perimeter
    → Two layers: blurred glow + sharp line = professional "lit border" look

_CodeParticles (Floating background):
  - 22 particles with fixed random positions (seeded Random(42))
  - Each particle: char, x, y, speed, opacity, size
  - In paint(): y = (particle.y + t * particle.speed) % 1.0
  - Draws text at (x * width, y * height)
  - Low opacity (0.04-0.11) — decorative, not distracting
  - Characters: 0 1 { } < > / ; ( ) = +
```

---

## 12. Sequence Diagrams

### 12.1 Student Login Sequence

```
  Student    LoginScreen    AuthNotifier    AuthService    SupabaseService    Hive
     │            │               │              │               │             │
     │ enter un+pw│               │              │               │             │
     │───────────►│               │              │               │             │
     │            │ login(un,pw)  │              │               │             │
     │            │──────────────►│              │               │             │
     │            │               │ hashPassword │               │             │
     │            │               │─────────────►│               │             │
     │            │               │◄─────────────│ SHA256 hash   │             │
     │            │               │ queryUser    │               │             │
     │            │               │──────────────────────────────►│             │
     │            │               │◄──────────────────────────────│ UserModel   │
     │            │               │ validate     │               │             │
     │            │               │─────────────►│               │             │
     │            │               │◄─────────────│ valid/invalid │             │
     │            │               │ saveSession  │               │             │
     │            │               │─────────────────────────────────────────►│ │
     │            │               │◄────────────────────────────────────────│ │ saved
     │            │               │ state=user   │               │             │
     │            │ user model    │              │               │             │
     │◄───────────│               │              │               │             │
     │ GoRouter → /student/dash   │              │               │             │
```

### 12.2 Exam Publish Sequence

```
  Admin    ExamEngineScreen    SupabaseService    Supabase DB    NotifService    Students
    │             │                  │                │               │              │
    │ tap Publish │                  │                │               │              │
    │────────────►│                  │                │               │              │
    │             │  publishExam(id) │                │               │              │
    │             │─────────────────►│                │               │              │
    │             │                  │ UPDATE exams   │               │              │
    │             │                  │────────────────►               │              │
    │             │                  │◄────────────────               │              │
    │             │◄─────────────────│ success        │               │              │
    │             │                  │                │               │              │
    │             │                  │    Realtime PostgresChangeEvent fires          │
    │             │                  │◄──────────────────────────────────────────────│
    │             │                  │                │               │              │
    │             │  notifyExamPublished()            │               │              │
    │             │──────────────────────────────────────────────────►│              │
    │             │                  │  INSERT INTO notifications     │              │
    │             │                  │────────────────────────────────►              │
    │             │                  │                │               │              │
    │             │                  │  StreamProvider emits new exam list           │
    │             │                  │◄──────────────────────────────────────────────│
    │             │                  │  Toast appears on all student screens         │
    │             │                  │───────────────────────────────────────────────►
```

### 12.3 Maintenance Mode Toggle Sequence

```
  Admin    DevAdminScreen    SupabaseService    Supabase    developerProvider    StudentShell
    │            │                 │              │               │                   │
    │ toggle ON  │                 │              │               │                   │
    │ + Save     │                 │              │               │                   │
    │───────────►│                 │              │               │                   │
    │            │ upsertDevInfo   │              │               │                   │
    │            │({isMaint: true})│              │               │                   │
    │            │────────────────►│              │               │                   │
    │            │                 │ UPDATE/INSERT│               │                   │
    │            │                 │ developer_info│              │                   │
    │            │                 │─────────────►│               │                   │
    │            │                 │◄─────────────│               │                   │
    │            │◄────────────────│ success      │               │                   │
    │            │                 │              │               │                   │
    │            │                 │  Realtime update event        │                   │
    │            │                 │◄─────────────────────────────│                   │
    │            │                 │  Stream emits DeveloperInfoModel(isMaint: true)  │
    │            │                 │───────────────────────────────►                   │
    │            │                 │                               │  isMaintenance=true
    │            │                 │                               │──────────────────►│
    │            │                 │                               │  return MaintenanceScreen
    │ (Admin sees normal app)       │                               │◄──────────────────│
```

---

## 13. Class Diagrams

### 13.1 Model Classes (Simplified)

```
┌────────────────────────────────────────────────────────────────┐
│                       MODEL HIERARCHY                           │
└────────────────────────────────────────────────────────────────┘

UserModel                    ExamModel
─────────                    ─────────
+ id: String                 + id: String
+ name: String               + title: String
+ username: String           + questions: List<QuestionModel>
+ passwordHash: String       + targetBatches: List<String>
+ studentClass: String       + durationMinutes: int
+ batch: String              + isPublished: bool
+ prepcoins: int             + allowDownload: bool
+ isAdmin: bool              + expRequired: int
+ isBanned: bool             + visibilityStart: DateTime?
+ monthlyPayments: Map       + visibilityEnd: DateTime?
─────────────────────        ─────────────────────────────
+ fromJson(json)             + fromJson(json)
+ toJson()                   + toJson()
+ copyWith()                 + copyWith()
                             + neetScore: int  [computed]

QuestionModel                ExamResultModel
─────────────                ───────────────
+ id: String                 + id: String
+ examId: String             + examId: String
+ text: String               + studentId: String
+ optionA: String            + score: int
+ optionB: String            + answers: Map<String,String>
+ optionC: String            + isFirstAttempt: bool
+ optionD: String            + isInProgress: bool
+ correctOption: String      + remainingSeconds: int
+ explanation: String?       + correctCount: int
+ chapter: String            + incorrectCount: int
────────────────────         ─────────────────────────────
+ optionText(opt) → String   + fromJson(json)
+ fromJson(json)             + neetScore: int  [computed]
+ toJson()                   + percentage: double  [computed]
+ copyWith()

PYQModel                     NoteModel
────────                     ─────────
+ id: String                 + id: String
+ year: String               + name: String
+ chapter: String            + link: String
+ question: String           + visibility: String
+ optionA-D: String          + sectionName: String
+ correctOption: String      + isLink: bool
+ imageUrl: String?          + sortOrder: int
+ explanation: String?       + isPrivate: bool
────────────────             ─────────────────────
+ fromJson(json)             + fromJson(json)
+ toJson()                   + toJson()
+ copyWith()                 + copyWith()

DeveloperInfoModel
──────────────────
+ isEnabled: bool
+ isMaintenance: bool
+ name: String
+ avatarUrl: String?
+ showAvatar: bool
+ links: List<DeveloperLink>
─────────────────────────────
+ fromJson(json)
+ toJson()
+ copyWith()

DeveloperLink
─────────────
+ platform: String
+ url: String
─────────────────
+ fromJson(json)
+ toJson()
```

### 13.2 Service Layer Class Relations

```
┌─────────────────────────────────────────────────────────────────┐
│                   SERVICE LAYER DEPENDENCIES                     │
└─────────────────────────────────────────────────────────────────┘

                    ┌──────────────────────┐
                    │    SupabaseService    │
                    │      (Singleton)      │
                    │  uses: supabase_flutter│
                    └──────────────────────┘
                              ▲
                              │ calls
              ┌───────────────┴───────────────┐
              │                               │
   ┌──────────┴──────────┐       ┌────────────┴──────────┐
   │   AuthNotifier      │       │  NotificationService  │
   │   uses: AuthService │       │  uses: SupabaseService│
   │         StorageSvc  │       │        ToastService   │
   └─────────────────────┘       └───────────────────────┘
              ▲                               ▲
              │ watches                       │ called by
   ┌──────────┴──────────┐       ┌────────────┴──────────┐
   │   authProvider      │       │  Admin Feature Screens │
   │   (Riverpod)        │       │  (publish exam, etc.)  │
   └─────────────────────┘       └───────────────────────┘

   ┌─────────────────────┐       ┌───────────────────────┐
   │    PdfService       │       │     CsvService        │
   │  uses: pdf package  │       │  uses: csv package    │
   │  pure static methods│       │  pure static methods  │
   └─────────────────────┘       └───────────────────────┘
              ▲                               ▲
              │ called by                     │ called by
   ExamResultScreen          PYQUploadScreen, DatabaseScreen
   ExamEngineScreen          StudentManagement
```

---

## 14. Algorithm Design

### 14.1 NEET Score Calculation

```
ALGORITHM: calculateNEETScore(questions, answers)

INPUT:
  questions: List<QuestionModel>
  answers: Map<questionId, selectedOption>

PROCESS:
  correct = 0
  incorrect = 0
  unattempted = 0

  FOR EACH question IN questions:
    selected = answers[question.id]
    IF selected == null:
      unattempted++
    ELSE IF selected.toUpperCase() == question.correctOption.toUpperCase():
      correct++
    ELSE:
      incorrect++

  neetScore = (correct * 4) - (incorrect * 1)

OUTPUT:
  {neetScore, correct, incorrect, unattempted}
```

### 14.2 PYQ Year Sort Algorithm

```
ALGORITHM: sortYearsNewestFirst(years: List<String>)

For years like: ["2023", "2024", "2025 Cancelled", "2022"]

STEP 1: For each year string, extract numeric part:
  numericPart = int.tryParse(year.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0
  "2025 Cancelled" → replaceAll → "2025" → parseInt → 2025
  "2024" → "2024" → 2024

STEP 2: Sort comparator:
  sort((a, b) {
    na = numericPart(a)
    nb = numericPart(b)
    cmp = nb.compareTo(na)  ← DESCENDING (newest first)
    if cmp != 0: return cmp
    else: return a.compareTo(b)  ← secondary: alphabetical for same year
  })

RESULT: ["2025 Cancelled", "2024", "2023", "2022"]
```

### 14.3 Notes Section Order Algorithm

```
ALGORITHM: _initFrom(allNotes)

PROBLEM BEING SOLVED:
  - Supabase stream emits on ANY change (even unrelated)
  - Must NOT re-init (reset local order) on every emission
  - Must re-init ONLY when notes are actually added or deleted

STEP 1: Get current IDs
  currentIds = allNotes.map(n => n.id).toSet()

STEP 2: Compare with last known IDs (VALUE comparison, not reference)
  sameIds = currentIds.length == lastLoadedIds.length &&
            currentIds.containsAll(lastLoadedIds)
  structureChanged = !sameIds || allNotes.length != lastLoadedCount

STEP 3: Only re-init if structure changed
  IF NOT initialized OR structureChanged:
    sort notes by sortOrder
    group by sectionName (preserving sort order)
    update _sections, _sectionOrder
    update lastLoadedCount, lastLoadedIds

STEP 4: Local reordering
  Admin uses ▲▼ buttons → updates local _sections in memory
  hasUnsavedChanges = true (shows Save button)
  On Save: write all sortOrder values to DB
  On next stream emit: sameIds = true → no re-init → order preserved
```

---

## 15. Error Handling Design

### 15.1 Error Handling Strategy

```
┌─────────────────────────────────────────────────────────────┐
│                   ERROR HANDLING LAYERS                       │
└─────────────────────────────────────────────────────────────┘

LAYER 1: Service Layer (SupabaseService)
  - All database calls wrapped in try/catch
  - Silent catch with debugPrint for non-critical operations
  - Throws descriptive exceptions for critical operations (login fails)

LAYER 2: Provider Layer (Riverpod)
  - FutureProvider: AsyncError state displayed in UI with .when()
  - StreamProvider: error state shown, retries on reconnect
  - AsyncNotifier: error propagated to UI via state

LAYER 3: UI Layer (Widgets)
  - provider.when(
      loading: () => CircularProgressIndicator(),
      error: (e, _) => ErrorWidget(message: friendlyMessage(e)),
      data: (data) => ContentWidget(data)
    )
  - Snackbars for non-fatal operation results
  - Dialogs for confirmations with failure paths

LAYER 4: Graceful Degradation
  - Chatbot API unavailable → shows "Service unavailable. Try again shortly." — does not crash
  - Chatbot API key not set in DB → shows "Chatbot not configured. Ask your admin to set up the API key."
  - Daily limit reached → friendly dialog, input field disabled, no API call made
  - Gemini AI unavailable → exam creator shows clear error, rest of app unaffected
  - Supabase Realtime disconnected → UI still works (FutureProvider data cached)
  - Flashcards: always available from Hive cache
  - Bio Lab diagram not implemented → falls back to Steps mode (null check)
```

### 15.2 Specific Error Scenarios

| Scenario | Detection | Handling |
|---|---|---|
| Wrong login credentials | hashPassword mismatch in query | Show "Invalid username or password" (no specifics for security) |
| Student is banned | is_banned == true in DB | Show "Account suspended. Contact your admin" |
| Exam expired visibility | visibilityEnd < now | Exam not shown in list (client-side filter) |
| PYQ CSV invalid format | < 8 columns or no valid rows | Show "No valid questions found. Check encoding and column format." |
| Supabase timeout | PostgrestException caught | Show "Connection error. Please check your internet." |
| Gemini API error | HTTP non-200 response | Show "AI unavailable. Check your API key." |
| Bio diagram not implemented | buildBioDiagram returns null | Show Steps mode only (silent fallback, no error shown) |
| PDF generation fails | Exception in pdf package | Show "Could not generate PDF. Try again." |

---

*End of Software Design Document*
*PRAEPARATIO v1.0.0 — Deepan Pramanick — 2026*
