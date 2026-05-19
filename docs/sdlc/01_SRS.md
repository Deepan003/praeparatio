# SOFTWARE REQUIREMENTS SPECIFICATION (SRS)

**Project:** PRAEPARATIO — NEET Biology Preparation Platform
**Document Version:** 1.0
**Status:** Approved
**Author:** Deepan Pramanick
**Date:** 2026

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Overall Description](#2-overall-description)
3. [Stakeholders and User Classes](#3-stakeholders-and-user-classes)
4. [System Context Diagram (Level 0 DFD)](#4-system-context-diagram)
5. [Level 1 DFD — Main Processes](#5-level-1-dfd)
6. [Level 2 DFDs — Detailed Sub-processes](#6-level-2-dfds)
7. [Use Case Diagrams](#7-use-case-diagrams)
8. [Entity Relationship Diagram](#8-entity-relationship-diagram)
9. [Functional Requirements](#9-functional-requirements)
10. [Non-Functional Requirements](#10-non-functional-requirements)
11. [External Interface Requirements](#11-external-interface-requirements)
12. [Constraints and Assumptions](#12-constraints-and-assumptions)
13. [Glossary](#13-glossary)

---

## 1. Introduction

### 1.1 Purpose

This Software Requirements Specification (SRS) describes the complete requirements for PRAEPARATIO, a full-scale EdTech coaching management platform designed for NEET Biology preparation. It covers what the system must do, how it must behave, and the constraints under which it operates.

### 1.2 Scope

PRAEPARATIO is a private, invite-only EdTech platform serving:
- One institute administrator (the teacher/coaching owner)
- Multiple enrolled students across different class levels and batches

The system provides:
- Online computer-based testing (CBT) with NEET-style scoring
- Previous Year Question (PYQ) practice with 20,000+ questions
- 32 animated biological process diagrams
- AI-powered biology doubt solver chatbot (Groq/universal OpenAI-compatible API, admin-configurable, rate-limited 350 q/day per student)
- Admin management of students, batches, exams, notes, and notifications
- Maintenance mode for scheduled downtime

**Out of scope:** Public registration, payment gateway integration, live video classes, peer-to-peer interaction.

### 1.3 Definitions and Acronyms

| Term | Definition |
|---|---|
| NEET | National Eligibility cum Entrance Test (medical entrance exam in India) |
| PYQ | Previous Year Questions — past NEET exam questions |
| CBT | Computer Based Test — digital exam format |
| NEET Score | Marks calculated as: (+4) per correct answer, (-1) per wrong, (0) per skipped |
| Batch | A named group of students (e.g. "11 NEET 2025 Morning") |
| Class Level | Academic year: Class 11, Class 12, or NEET Exclusive |
| Prepcoins | In-app virtual currency used to unlock premium exams |
| Admin | The single teacher/institute owner who manages the entire platform |
| Student | An enrolled learner with a username/password created by admin |
| Maintenance Mode | A system state where students see a "We'll be back" screen |
| SHA-256 | Secure Hash Algorithm — used for password hashing |
| Supabase | Backend-as-a-Service providing PostgreSQL + Realtime + Storage |
| Riverpod | Flutter state management library |
| GoRouter | Flutter navigation library with deep link support |

### 1.4 References

- NCERT Biology Class 11 and Class 12 textbooks
- NTA (National Testing Agency) NEET exam pattern
- Supabase documentation
- Flutter framework documentation
- Google Gemini API documentation

---

## 2. Overall Description

### 2.1 Product Perspective

PRAEPARATIO is a standalone EdTech platform. It does not integrate with external coaching management systems. It consists of:

```
+-----------------------------------------------+
|              PRAEPARATIO SYSTEM               |
|                                               |
|  +-------------------+  +------------------+  |
|  |  Flutter Web App  |  | Flutter Android  |  |
|  |  (Vercel hosted)  |  |   (APK direct)   |  |
|  +--------+----------+  +--------+---------+  |
|           |                      |             |
|  +--------v----------------------v-----------+  |
|  |          Flutter Application Layer         |  |
|  |   Admin Shell  |  Student Shell  |  Auth   |  |
|  +--------+----------------------------+-----+  |
|           |                            |        |
|  +--------v----------------------------v------+  |
|  |            Supabase Cloud Backend           |  |
|  |  PostgreSQL | Realtime | PostgREST | Store  |  |
|  +--------------------------------------------+  |
|                                               |
|  External: Google Gemini AI API               |
+-----------------------------------------------+
```

### 2.2 Product Functions Summary

| Category | Functions |
|---|---|
| Authentication | Login, logout, session management, admin trigger |
| Exam Management | Create, publish, schedule, take, auto-submit, resume, grade |
| PYQ Practice | Chapterwise, Yearwise, Custom Test modes |
| Biology Learning | 32 animated diagrams, 500+ flashcards, glossary |
| Admin Management | Students, batches, promotions, fee tracking |
| Content Management | Notes/PDFs upload, reorder, visibility control |
| Notifications | Targeted real-time in-app notifications |
| Reporting | PDF reports for exams, batches, and students |
| AI Chatbot | Groq/OpenAI-compatible biology doubt solver. Rate limited 350 q/day. Admin-managed key in DB. |
| Exam AI | Gemini-powered question generator. Key and model stored in Supabase. |
| Maintenance | Admin-controlled maintenance mode |

### 2.3 User Classes and Characteristics

**Administrator (1 user)**
- Technical proficiency: Moderate (comfortable with file uploads, form filling)
- Frequency: Daily
- Primary tasks: Create exams, manage students, upload content, monitor progress

**Students (Multiple users)**
- Technical proficiency: Basic to Moderate (comfortable with mobile/web apps)
- Age range: 16–22 years
- Frequency: Daily (practice) to weekly (exams)
- Primary tasks: Take exams, practice PYQ, watch animations, study flashcards

### 2.4 Operating Environment

| Component | Specification |
|---|---|
| Web Browser | Chrome 90+, Firefox 88+, Safari 14+, Edge 90+ |
| Android | Android 5.0 (API 21) and above |
| Internet | Required for all features except offline flashcards |
| Screen | Responsive: 320px (mobile) to 2560px (4K desktop) |

### 2.5 Design and Implementation Constraints

1. **No custom backend server** — all logic runs in Flutter client via Supabase SDK
2. **No public registration** — admin creates all student accounts
3. **Custom authentication** — SHA-256 hashing, not Supabase Auth
4. **No native iOS app** — only Web and Android
5. **Single admin account** — the system is designed for one teaching institution
6. **Chatbot API key** — admin provides one key stored in Supabase; students need no key
7. **Exam AI (Gemini) key** — admin provides key stored in Supabase DB, not device-local

---

## 3. Stakeholders and User Classes

```
+------------------------------------------------------------------+
|                      STAKEHOLDER MAP                              |
|                                                                  |
|  PRIMARY STAKEHOLDERS              SECONDARY STAKEHOLDERS         |
|  ─────────────────────             ──────────────────────         |
|                                                                  |
|  +──────────────────+             +──────────────────+           |
|  │  ADMINISTRATOR   │             │   PARENTS /      │           |
|  │  (Teacher/Owner) │             │   GUARDIANS      │           |
|  │                  │             │                  │           |
|  │ - Creates exams  │             │ - View fee status │           |
|  │ - Manages students│            │ - Monitor progress│           |
|  │ - Uploads content│             +──────────────────+           |
|  │ - Controls system│                                            |
|  +──────────────────+             +──────────────────+           |
|                                   │   DEVELOPERS     │           |
|  +──────────────────+             │                  │           |
|  │    STUDENTS      │             │ - Maintain code  │           |
|  │                  │             │ - Fix bugs       │           |
|  │ - Take exams     │             │ - Add features   │           |
|  │ - Practice PYQ   │             +──────────────────+           |
|  │ - Study content  │                                            |
|  │ - Use AI chatbot │                                            |
|  +──────────────────+                                            |
+------------------------------------------------------------------+
```

---

## 4. System Context Diagram

### Level 0 DFD — System Context Diagram

```
                    ┌─────────────────────────────────────────────┐
                    │                                             │
  ┌─────────┐       │          ┌─────────────────────┐           │       ┌──────────────┐
  │         │ Login │          │                     │           │       │              │
  │  ADMIN  │──────►│          │                     │ Data      │       │  SUPABASE    │
  │ (Teacher│       │          │   PRAEPARATIO       │◄─────────►│       │  CLOUD DB    │
  │         │◄──────│          │   PLATFORM          │           │       │  (PostgreSQL │
  │         │ Mgmt  │          │   (0.0)             │           │       │  + Realtime) │
  │         │ Data  │          │                     │ Queries   │       │              │
  └─────────┘       │          │                     │──────────►│       └──────────────┘
                    │          └─────────────────────┘           │
  ┌─────────┐       │                   ▲  │                     │       ┌──────────────┐
  │         │ Login │                   │  │ AI Response         │       │              │
  │STUDENTS │──────►│                   │  │                     │       │  GOOGLE      │
  │         │       │          ┌────────┘  ▼                     │       │  GEMINI AI   │
  │         │◄──────│          │    AI Request                   │◄─────►│  API         │
  │         │ Study │          └────────────────────────────────►│       │              │
  │         │ Data  │                                             │       └──────────────┘
  └─────────┘       │                                             │
                    └─────────────────────────────────────────────┘

  LEGEND:
  ──────►  Data Flow
  ◄──────  Return Data
  (0.0)    Context Process (entire system)
```

**External Entities:**
| Entity | Description | Data In | Data Out |
|---|---|---|---|
| Admin | Teacher/institute owner | Login credentials, exam content, student data, settings | Management dashboards, reports, confirmations |
| Students | Enrolled learners | Login credentials, exam answers, PYQ responses | Exam results, content, notifications |
| Supabase Cloud | Database + Realtime service | SQL queries, real-time subscriptions | Query results, real-time events |
| Google Gemini AI | AI language model API | Biology questions + context prompts | AI-generated answers and questions |

---

## 5. Level 1 DFD — Main Processes

```
  ┌────────────┐                                                    ┌────────────┐
  │            │  Credentials    ┌──────────────────┐              │            │
  │   ADMIN    │────────────────►│  1.0             │  Session     │  D1: USERS │
  │            │                 │  AUTHENTICATION  │◄────────────►│   TABLE    │
  │   STUDENT  │────────────────►│  & SESSION       │              │            │
  │            │  Credentials    │  MANAGEMENT      │              └────────────┘
  └────────────┘                 └──────────────────┘
         │                                │
         │                                │ Auth Token
         │                                ▼
         │                    ┌──────────────────────┐
         │                    │  2.0                 │
         │───────────────────►│  EXAM                │◄────────────► D2: EXAMS
         │  Exam Actions      │  MANAGEMENT          │◄────────────► D3: QUESTIONS
         │                    │                      │◄────────────► D4: RESULTS
         │                    └──────────────────────┘
         │                                │
         │                                │ Results / Content
         │                                ▼
         │                    ┌──────────────────────┐
         │───────────────────►│  3.0                 │
         │  PYQ Actions       │  PYQ                 │◄────────────► D5: PYQ TABLE
         │                    │  MANAGEMENT          │
         │                    └──────────────────────┘
         │                                │
         │                                ▼
         │                    ┌──────────────────────┐
         │───────────────────►│  4.0                 │
         │  Content Requests  │  CONTENT             │◄────────────► D6: NOTES
         │                    │  MANAGEMENT          │◄────────────► D7: FLASHCARDS
         │                    │                      │◄────────────► D8: GLOSSARY
         │                    └──────────────────────┘
         │                                │
         │                                ▼
         │                    ┌──────────────────────┐
         │───────────────────►│  5.0                 │
         │  Notification      │  NOTIFICATION        │◄────────────► D9: NOTIFICATIONS
         │  Actions           │  SYSTEM              │
         │                    └──────────────────────┘
         │                                │
         │                                ▼
         │                    ┌──────────────────────┐
         │───────────────────►│  6.0                 │
         │  AI Queries        │  AI CHATBOT          │◄────────────► Google Gemini API
         │                    │  INTEGRATION         │
         │                    └──────────────────────┘
         │                                │
         │                                ▼
         │                    ┌──────────────────────┐
         │───────────────────►│  7.0                 │
                              │  SYSTEM              │◄────────────► D10: APP_SETTINGS
         (Admin Only)         │  CONFIGURATION       │◄────────────► D11: DEVELOPER_INFO
                              └──────────────────────┘

  LEGEND:
  ────► Data Flow         D1-D11: Data Stores (Supabase Tables)
  ◄──► Bidirectional      (Admin Only): Only admin can access
```

---

## 6. Level 2 DFDs — Detailed Sub-processes

### 6.1 Process 1.0 — Authentication & Session Management

```
  ┌──────────┐    Username+     ┌───────────────────┐
  │  USER    │    Password      │  1.1              │   Query    ┌──────────┐
  │ (Admin / │─────────────────►│  CREDENTIAL       │──────────►│ D1:USERS │
  │  Student)│                  │  VALIDATION       │◄──────────│          │
  └──────────┘                  │                   │  User Rec  └──────────┘
       ▲                        └────────┬──────────┘
       │                                 │
       │                        ┌────────▼──────────┐
       │                        │  1.2              │
       │                        │  SHA-256          │
       │                        │  PASSWORD         │
       │                        │  HASHING          │
       │                        └────────┬──────────┘
       │                                 │
       │                        ┌────────▼──────────┐    Save     ┌──────────────┐
       │  Session Token         │  1.3              │────────────►│ D12: HIVE    │
       │◄───────────────────────│  SESSION          │             │ LOCAL CACHE  │
       │                        │  MANAGEMENT       │◄────────────│              │
       │                        │                   │  Load        └──────────────┘
       │                        └────────┬──────────┘
       │                                 │
       │                        ┌────────▼──────────┐
       │                        │  1.4              │
       │  Auth Result           │  ADMIN TRIGGER    │
       │◄───────────────────────│  DETECTION        │
                                │  (4444/4444 check)│
                                └───────────────────┘
```

### 6.2 Process 2.0 — Exam Management

```
  ┌──────────┐                 ┌───────────────────┐    Store    ┌──────────────┐
  │  ADMIN   │  Exam Data      │  2.1              │────────────►│ D2: EXAMS    │
  │          │────────────────►│  EXAM             │             │              │
  │          │                 │  CREATION &       │◄────────────│              │
  │          │◄────────────────│  PUBLISHING       │  Confirm    └──────────────┘
  └──────────┘  Publish Status │                   │    Store    ┌──────────────┐
                               └──────┬────────────┘────────────►│D3: QUESTIONS│
                                      │                           └──────────────┘
                                      │ Publish Event
                                      ▼
  ┌──────────┐                 ┌───────────────────┐
  │ STUDENTS │  Exam List      │  2.2              │    Query    ┌──────────────┐
  │          │◄────────────────│  EXAM             │────────────►│ D2: EXAMS    │
  │          │                 │  DISCOVERY &      │             │              │
  │          │                 │  FILTERING        │◄────────────│              │
  └──────────┘                 └──────┬────────────┘             └──────────────┘
       │                              │
       │  Start Exam                  │ Filtered List
       ▼                              ▼
  ┌──────────┐                 ┌───────────────────┐    Read     ┌──────────────┐
  │          │  Answers        │  2.3              │────────────►│D3: QUESTIONS │
  │  STUDENT │────────────────►│  EXAM EXECUTION   │             │              │
  │          │                 │  (CBT Portal)     │    Save     ┌──────────────┐
  │          │◄────────────────│  - Timer          │────────────►│D4: RESULTS   │
  │          │  Result         │  - Live Save      │             │  (JSONB      │
  └──────────┘                 │  - Auto-submit    │             │   answers)   │
                               └──────┬────────────┘             └──────────────┘
                                      │
                                      ▼
                               ┌───────────────────┐
                               │  2.4              │    Read     ┌──────────────┐
                               │  RESULT           │────────────►│D4: RESULTS   │
                               │  CALCULATION &    │             └──────────────┘
                               │  DISPLAY          │
                               │  - NEET Scoring   │    PDF      ┌──────────────┐
                               │  - Per Q Review   │────────────►│ PDF Service  │
                               └───────────────────┘             └──────────────┘
```

### 6.3 Process 3.0 — PYQ Management

```
  ┌──────────┐  CSV File       ┌───────────────────┐
  │  ADMIN   │────────────────►│  3.1              │   Validate  ┌──────────────┐
  │          │  + Year Name    │  PYQ CSV          │────────────►│ CSV Parser   │
  │          │                 │  UPLOAD &         │             │ (Validates   │
  │          │◄────────────────│  VALIDATION       │             │  A/B/C/D)    │
  │          │  Upload Status  │                   │             └──────────────┘
  └──────────┘                 └──────┬────────────┘
                                      │ Valid Questions
                                      ▼
                               ┌───────────────────┐
                               │  3.2              │  Chunk      ┌──────────────┐
                               │  SAFE YEAR        │────────────►│ D5: PYQ      │
                               │  REPLACEMENT      │  INSERT     │   TABLE      │
                               │  - Chunk insert   │  DELETE     │              │
                               │  - Delete old     │  old rows   └──────────────┘
                               └───────────────────┘

  ┌──────────┐  Filter/Mode    ┌───────────────────┐    Query    ┌──────────────┐
  │ STUDENT  │────────────────►│  3.3              │────────────►│ D5: PYQ      │
  │          │  (Chapter /     │  PYQ              │             │   TABLE      │
  │          │   Year /        │  RETRIEVAL &      │◄────────────│              │
  │          │   Custom)       │  FILTERING        │  Questions  └──────────────┘
  │          │                 └──────┬────────────┘
  │          │◄─────────────────────── Questions
  │          │  Questions
  │          │
  │          │  Answers        ┌───────────────────┐
  │          │────────────────►│  3.4              │
  │          │                 │  PYQ TEST         │
  │          │◄────────────────│  EXECUTION        │
  │          │  Score/Results  │  (via CBT Portal) │
  └──────────┘                 └───────────────────┘
```

### 6.4 Process 5.0 — Notification System

```
  ┌──────────┐  Trigger        ┌───────────────────┐
  │  ADMIN   │  (exam publish, │  5.1              │   Insert   ┌──────────────┐
  │  SYSTEM  │  notes upload,  │  NOTIFICATION     │───────────►│D9:NOTIFICATI │
  │  EVENT   │  PYQ add, etc.) │  CREATION         │            │  ONS TABLE   │
  └──────────┘────────────────►│                   │            └──────────────┘
                               └──────┬────────────┘
                                      │
                                      │ Supabase Realtime Event
                                      ▼
                               ┌───────────────────┐
                               │  5.2              │
                               │  REALTIME         │   Broadcast ┌───────────┐
                               │  DISTRIBUTION     │────────────►│ All       │
                               │  (WebSocket)      │             │ Connected │
                               │                   │             │ Clients   │
                               └──────┬────────────┘             └───────────┘
                                      │
                                      ▼
  ┌──────────┐  Bell Badge     ┌───────────────────┐    Read    ┌──────────────┐
  │ STUDENT  │◄────────────────│  5.3              │───────────►│D9:NOTIFICATI │
  │          │  Toast Pop-up   │  NOTIFICATION     │            │  ONS TABLE   │
  │          │  In-app Inbox   │  DISPLAY &        │            └──────────────┘
  │          │                 │  READ TRACKING    │   Write    ┌──────────────┐
  │          │  Mark Read      │                   │───────────►│D13: NOTIF_   │
  │          │────────────────►│                   │            │    READS     │
  └──────────┘                 └───────────────────┘            └──────────────┘
```

### 6.5 Process 7.0 — System Configuration & Maintenance

```
  ┌──────────┐  Config Data    ┌───────────────────┐   Update   ┌──────────────┐
  │  ADMIN   │────────────────►│  7.1              │───────────►│D11:DEVELOPER │
  │          │  (maintenance   │  DEVELOPER        │            │    _INFO     │
  │          │   toggle,       │  CONFIG           │            └──────────────┘
  │          │   dev profile,  │  MANAGEMENT       │
  │          │   links)        │                   │
  └──────────┘                 └──────┬────────────┘
                                      │ Supabase Realtime
                                      ▼
                               ┌───────────────────┐
                               │  7.2              │
                               │  MAINTENANCE      │  Broadcast ┌───────────────┐
                               │  MODE BROADCAST   │───────────►│ ALL Student   │
                               │                   │            │ Apps (Stream) │
                               └──────┬────────────┘            └───────────────┘
                                      │
                                      ▼
  ┌──────────┐  Maintenance    ┌───────────────────┐
  │ STUDENT  │◄────────────────│  7.3              │
  │ (sees    │  Screen         │  STUDENT          │
  │ overlay) │  OR             │  SHELL GUARD      │
  │          │  Normal App     │  (isMaintenance   │
  └──────────┘                 │   check)          │
                               └───────────────────┘
```

---

## 7. Use Case Diagrams

### 7.1 Authentication Use Cases

```
+------------------------------------------------------------------+
|                    <<System: PRAEPARATIO>>                        |
|                                                                  |
|    ┌──────────┐                                                  |
|    │  ADMIN   │─────────────────────────────┐                   |
|    └──────────┘      ┌──────────────────────▼──────────────┐    |
|                      │  UC-A01: Admin Login                 │    |
|    ┌──────────┐       │  (via Admin Trigger 4444/4444)       │    |
|    │ STUDENT  │──┐    └─────────────────────────────────────┘    |
|    └──────────┘  │                                               |
|                  │    ┌─────────────────────────────────────┐    |
|                  ├───►│  UC-S01: Student Login              │    |
|                  │    └─────────────────────────────────────┘    |
|                  │                                               |
|                  │    ┌─────────────────────────────────────┐    |
|                  └───►│  UC-S02: Student Logout             │    |
|                       └─────────────────────────────────────┘    |
|                                                                  |
|                       ┌─────────────────────────────────────┐    |
|   (System)           │  UC-SYS01: Session Restore           │    |
|                       │  (auto-login from local cache)      │    |
|                       └─────────────────────────────────────┘    |
+------------------------------------------------------------------+
```

### 7.2 Admin Use Cases

```
+------------------------------------------------------------------+
|                    ADMIN USE CASES                               |
|                                                                  |
|   ┌─────────┐                                                    |
|   │         │──►  UC-A02: Create/Edit/Delete Student Account     |
|   │         │──►  UC-A03: Import Students via CSV                |
|   │         │──►  UC-A04: Assign Student to Batch                |
|   │  ADMIN  │──►  UC-A05: Ban / Unban Student                   |
|   │         │──►  UC-A06: Track Monthly Fee Payment              |
|   │         │──►  UC-A07: Create Batch                          |
|   │         │──►  UC-A08: Promote Students Between Batches       |
|   │         │──►  UC-A09: Create Exam (Manual)                  |
|   │         │──►  UC-A10: Create Exam (AI-Generated via Gemini)  |
|   │         │──►  UC-A11: Publish / Unpublish Exam               |
|   │         │──►  UC-A12: Schedule Exam Visibility Window        |
|   │         │──►  UC-A13: View Exam Statistics & Leaderboard     |
|   │         │──►  UC-A14: Download Question Paper PDF            |
|   │         │──►  UC-A15: Upload PYQ via CSV                    |
|   │         │──►  UC-A16: Upload Notes / External Links          |
|   │         │──►  UC-A17: Reorder Notes Sections                 |
|   │         │──►  UC-A18: Set Note Visibility                   |
|   │         │──►  UC-A19: Enter Offline Test Marks               |
|   │         │──►  UC-A20: Send Targeted Notification             |
|   │         │──►  UC-A21: Toggle Maintenance Mode                |
|   │         │──►  UC-A22: Configure Developer Profile            |
|   │         │──►  UC-A23: View Student Activity History          |
|   └─────────┘                                                    |
+------------------------------------------------------------------+
```

### 7.3 Student Use Cases

```
+------------------------------------------------------------------+
|                    STUDENT USE CASES                             |
|                                                                  |
|   ┌─────────┐                                                    |
|   │         │──►  UC-S03: View Dashboard (coins, streak, exams)  |
|   │         │──►  UC-S04: Browse Available Exams                 |
|   │         │──►  UC-S05: Take Online Exam (CBT)                 |
|   │         │──►  UC-S06: Resume In-Progress Exam                |
|   │         │──►  UC-S07: View Exam Results with Review          |
|   │         │──►  UC-S08: Download Result PDF                    |
|   │ STUDENT │──►  UC-S09: Practice PYQ — Chapterwise Mode        |
|   │         │──►  UC-S10: Practice PYQ — Yearwise Mode           |
|   │         │──►  UC-S11: Take Custom PYQ Test                   |
|   │         │──►  UC-S12: View Animated Biology Diagram          |
|   │         │──►  UC-S13: Toggle Animation / Steps View          |
|   │         │──►  UC-S14: Study Flashcards                       |
|   │         │──►  UC-S15: Search Glossary                        |
|   │         │──►  UC-S16: Play Biology Games                     |
|   │         │──►  UC-S17: View Notes & PDFs                      |
|   │         │──►  UC-S18: Chat with AI Biology Tutor             |
|   │         │──►  UC-S19: Create Lesson Plan                     |
|   │         │──►  UC-S20: View Notifications                     |
|   │         │──►  UC-S21: View Performance History               |
|   │         │──►  UC-S22: View Offline Test Results              |
|   │         │──►  UC-S23: View Developer Modal                   |
|   └─────────┘                                                    |
+------------------------------------------------------------------+
```

---

## 8. Entity Relationship Diagram

```
┌──────────────────────────────────────────────────────────────────────┐
│                    PRAEPARATIO — ER DIAGRAM                           │
└──────────────────────────────────────────────────────────────────────┘

 ┌──────────────┐         ┌──────────────┐         ┌──────────────┐
 │    USERS     │         │    EXAMS     │         │  QUESTIONS   │
 │──────────────│         │──────────────│         │──────────────│
 │ id (PK)      │         │ id (PK)      │  1      │ id (PK)      │
 │ name         │         │ title        ├────────►│ exam_id (FK) │
 │ username     │         │ target_      │         │ text         │
 │ password_hash│         │   batches[]  │  N      │ option_a     │
 │ student_class│         │ duration_min │         │ option_b     │
 │ batch        │         │ is_published │         │ option_c     │
 │ prepcoins    │         │ allow_dl     │         │ option_d     │
 │ is_admin     │         │ exp_required │         │ correct_opt  │
 │ is_banned    │         │ visibility_  │         │ explanation  │
 │ earned_badge │         │   start/end  │         │ chapter      │
 │ monthly_pmts │         └──────────────┘         └──────────────┘
 │ login_streak │
 └──────┬───────┘
        │ 1
        │
        │ N                                         ┌──────────────┐
 ┌──────▼───────┐         ┌──────────────┐          │   BATCHES    │
 │ EXAM_RESULTS │         │     PYQ      │          │──────────────│
 │──────────────│         │──────────────│          │ id (PK)      │
 │ id (PK)      │         │ id (PK)      │          │ name         │
 │ exam_id      │         │ year (text)  │          │ class_level  │
 │ student_id   │         │ chapter      │          │ sort_order   │
 │   (FK→users) │         │ question     │          └──────────────┘
 │ score        │         │ option_a-d   │
 │ answers (JSON│         │ correct_opt  │          ┌──────────────┐
 │ is_first_att │         │ explanation  │          │ LESSON_PLANS │
 │ is_in_prog   │         └──────────────┘          │──────────────│
 │ remaining_s  │                                   │ id (PK)      │
 │ correct_cnt  │         ┌──────────────┐          │ student_id FK│
 └──────────────┘         │    NOTES     │     1    │ title        │
                          │──────────────│     │    │ plan_date    │
                          │ id (PK)      │     │    │ is_completed │
 ┌──────────────┐         │ name         │     │ N  └──────┬───────┘
 │NOTIFICATIONS │         │ link         │          ┌──────▼───────┐
 │──────────────│         │ visibility   │          │LESSON_TASKS  │
 │ id (PK)      │         │ section_name │          │──────────────│
 │ type         │         │ is_link      │          │ id (PK)      │
 │ title        │         │ sort_order   │          │ plan_id (FK) │
 │ body         │         │ is_private   │          │ title        │
 │ target_type  │         └──────────────┘          │ is_done      │
 │ target_btchs │                                   │ chapter      │
 │ target_sid   │         ┌──────────────┐          └──────────────┘
 └──────┬───────┘         │OFFLINE_TESTS │
        │ 1               │──────────────│          ┌──────────────┐
        │ N               │ id (PK)      │          │DEVELOPER_INFO│
 ┌──────▼───────┐         │ name         │          │──────────────│
 │NOTIF_READS   │         │ test_date    │          │ id (PK)      │
 │──────────────│         │ full_marks   │          │ is_enabled   │
 │ id (PK)      │         │ batch        │          │ is_maintenan │
 │ notif_id (FK)│         │ student_marks│          │ name         │
 │ student_id FK│         │   (JSONB)    │          │ avatar_url   │
 │ read_at      │         └──────────────┘          │ links (JSON) │
 └──────────────┘                                   └──────────────┘

 ┌──────────────┐
 │ APP_SETTINGS │
 │──────────────│
 │ key (PK)     │
 │ value (JSONB)│
 └──────────────┘

 Relationships:
 users (1) ──── (N) exam_results       [student_id FK]
 users (1) ──── (N) lesson_plans       [student_id FK]
 lesson_plans (1) ── (N) lesson_tasks  [plan_id FK]
 exams (1) ─────── (N) questions       [exam_id FK]
 notifications (1) ─ (N) notif_reads   [notification_id FK]
 exams.target_batches[] ↔ users.batch  [array match, no hard FK]
```

---

## 9. Functional Requirements

### FR-1: Authentication and Session Management

| ID | Requirement | Priority |
|---|---|---|
| FR-1.1 | System shall allow students to log in with username and password | High |
| FR-1.2 | System shall hash all passwords using SHA-256 before storage | High |
| FR-1.3 | System shall persist login sessions locally so users don't re-login on app restart | High |
| FR-1.4 | System shall detect the admin trigger shortcut (4444/4444) and open the admin login dialog | High |
| FR-1.5 | System shall prevent banned students from logging in | High |
| FR-1.6 | System shall prevent admin accounts from logging in as students | High |
| FR-1.7 | System shall redirect users to appropriate shells based on role (admin vs student) | High |
| FR-1.8 | System shall update the student's last_login timestamp on successful login | Medium |

### FR-2: Student Management (Admin)

| ID | Requirement | Priority |
|---|---|---|
| FR-2.1 | Admin shall be able to create student accounts with name, username, password, class, batch | High |
| FR-2.2 | System shall require a non-empty password when creating a new student | High |
| FR-2.3 | Admin shall be able to edit student details (password field blank = keep existing) | High |
| FR-2.4 | Admin shall be able to delete student accounts | High |
| FR-2.5 | Admin shall be able to ban and unban students | High |
| FR-2.6 | Admin shall be able to import students via CSV file | Medium |
| FR-2.7 | Admin shall be able to export student data to CSV | Medium |
| FR-2.8 | Admin shall be able to track monthly fee payment status per student | Medium |
| FR-2.9 | Admin shall be able to search and filter students | Medium |

### FR-3: Batch Management (Admin)

| ID | Requirement | Priority |
|---|---|---|
| FR-3.1 | Admin shall be able to create, rename, and delete batches | High |
| FR-3.2 | Each batch shall have a name and a class level (11/12/neet) | High |
| FR-3.3 | Admin shall be able to promote students from one batch to another | High |
| FR-3.4 | When promoting, system shall migrate student's offline test records to the new batch | High |
| FR-3.5 | When promoting, system shall update exam target_batches arrays to include the new batch | Medium |
| FR-3.6 | Admin shall be able to synchronize all students in a batch to the batch's class level | Medium |

### FR-4: Exam Management (Admin)

| ID | Requirement | Priority |
|---|---|---|
| FR-4.1 | Admin shall be able to create exams with title, target batches, duration, and questions | High |
| FR-4.2 | Admin shall be able to add questions manually (text, 4 options, correct option, explanation) | High |
| FR-4.3 | Admin shall be able to generate questions using Gemini AI by providing a topic prompt | Medium |
| FR-4.4 | Admin shall be able to set optional visibility start and end datetimes for scheduled exams | Medium |
| FR-4.5 | Admin shall be able to require a prepcoins payment to unlock an exam | Medium |
| FR-4.6 | Admin shall be able to publish and unpublish exams | High |
| FR-4.7 | When an exam is published, all connected student apps shall receive a toast notification in real-time | High |
| FR-4.8 | Admin shall be able to download question papers as PDF (with and without answer key) | Medium |
| FR-4.9 | Admin shall be able to view per-exam statistics including leaderboard and score distribution | Medium |

### FR-5: Exam Execution (Student)

| ID | Requirement | Priority |
|---|---|---|
| FR-5.1 | Student shall see only exams targeting their batch | High |
| FR-5.2 | Student shall see only exams within their scheduled visibility window | High |
| FR-5.3 | System shall enforce prepcoins payment before allowing access to gated exams | Medium |
| FR-5.4 | Student shall be able to start a timed exam (countdown timer from duration_minutes) | High |
| FR-5.5 | Every answer selection shall be saved immediately to the database | High |
| FR-5.6 | System shall auto-submit the exam when the timer expires | High |
| FR-5.7 | Student shall be able to resume an in-progress exam with saved answers and remaining time | High |
| FR-5.8 | System shall calculate NEET score (+4 correct, -1 wrong, 0 unattempted) | High |
| FR-5.9 | Student shall be able to view detailed results with per-question review and explanations | High |
| FR-5.10 | Student shall be able to download their result as a PDF | Medium |

### FR-6: PYQ System

| ID | Requirement | Priority |
|---|---|---|
| FR-6.1 | Admin shall be able to upload PYQ questions via CSV for a specific year | High |
| FR-6.2 | System shall validate each CSV row (8+ columns, correct_option in A/B/C/D) | High |
| FR-6.3 | Upload shall replace existing questions for that year only (safe replacement) | High |
| FR-6.4 | System shall support year names including text like "2025 Cancelled" | High |
| FR-6.5 | Student shall be able to browse PYQ by chapter (chapterwise mode) | High |
| FR-6.6 | Student shall be able to browse PYQ by year (yearwise mode, newest-first) | High |
| FR-6.7 | Student shall be able to build a custom test by selecting chapters/years and question count | High |
| FR-6.8 | System shall filter PYQ by class level (Class 11 students see only Class 11 chapters) | High |
| FR-6.9 | Correct option comparison shall be case-insensitive | High |

### FR-7: Biology Lab (Animated Diagrams)

| ID | Requirement | Priority |
|---|---|---|
| FR-7.1 | System shall provide 32 animated biological process diagrams | High |
| FR-7.2 | Each process shall have both Animation mode and Steps mode | High |
| FR-7.3 | Student shall be able to toggle between Animation and Steps using a pill button | High |
| FR-7.4 | Animation toggle shall only appear when an animation is implemented for that process | High |
| FR-7.5 | Student shall be able to navigate through steps (previous/next) | High |
| FR-7.6 | System shall provide an auto-play mode that advances steps automatically | Medium |
| FR-7.7 | Diagrams shall be responsive and not overflow on any screen size | High |
| FR-7.8 | Each process shall display NEET key points and an overview below the animation | Medium |

### FR-8: Content Management

| ID | Requirement | Priority |
|---|---|---|
| FR-8.1 | Admin shall be able to upload notes (PDF links) and external links organized in sections | High |
| FR-8.2 | Admin shall be able to reorder notes and sections using up/down buttons | High |
| FR-8.3 | Reordering shall be persisted to the database only when admin explicitly saves | High |
| FR-8.4 | Admin shall be able to set visibility per note (All / Class 11 / Class 12 / NEET / Private) | High |
| FR-8.5 | Admin shall be able to hide/unhide individual notes without changing visibility setting | Medium |
| FR-8.6 | Student shall see notes filtered to their class level | High |
| FR-8.7 | Student shall be able to collapse/expand note sections | Medium |
| FR-8.8 | Notes shall be displayed in the admin-set sort order | High |

### FR-9: Notifications

| ID | Requirement | Priority |
|---|---|---|
| FR-9.1 | System shall automatically send notifications when exams are published | High |
| FR-9.2 | System shall automatically send notifications when notes are uploaded | Medium |
| FR-9.3 | System shall automatically send notifications when PYQ is added | Medium |
| FR-9.4 | Admin shall be able to manually send targeted notifications (all / batch / individual) | Medium |
| FR-9.5 | Notifications shall appear as real-time toasts if the app is open | High |
| FR-9.6 | Students shall have a notification inbox with read/unread status | Medium |
| FR-9.7 | Unread notification count shall appear as a badge on the bell icon | Medium |

### FR-10: Maintenance Mode

| ID | Requirement | Priority |
|---|---|---|
| FR-10.1 | Admin shall be able to toggle maintenance mode on/off from the admin panel | High |
| FR-10.2 | When maintenance mode is on, logged-in students shall see a full-screen maintenance overlay | High |
| FR-10.3 | Admin shall NOT be affected by maintenance mode (full access retained) | High |
| FR-10.4 | Maintenance mode changes shall propagate to all connected clients in real-time | High |
| FR-10.5 | Students shall be able to log out from the maintenance screen | High |
| FR-10.6 | Maintenance screen shall provide an Admin Access link for admin login | Medium |

### FR-11: Additional Features

| ID | Requirement | Priority |
|---|---|---|
| FR-11.1 | System shall provide 500+ NEET Biology flashcards accessible offline | Medium |
| FR-11.2 | System shall provide a searchable biology glossary | Medium |
| FR-11.3 | System shall provide multiple interactive biology quiz games | Medium |
| FR-11.4 | System shall integrate with Google Gemini API for an AI biology chatbot | Medium |
| FR-11.5 | A lesson planner screen exists (`/student/lesson-planner`) but is not accessible via the main navigation bar. Route is defined and functional but hidden from the primary student UI. | Low |
| FR-11.6 | System shall track and display student login streaks | Low |
| FR-11.7 | System shall display a developer profile modal when the Dev button is enabled | Low |

---

## 10. Non-Functional Requirements

### NFR-1: Performance

| ID | Requirement | Metric |
|---|---|---|
| NFR-1.1 | App initial load time on web | < 4 seconds on 4G connection |
| NFR-1.2 | Exam question navigation response time | < 200ms |
| NFR-1.3 | PYQ search and filter response time | < 500ms |
| NFR-1.4 | Realtime event propagation (publish exam → student toast) | < 2 seconds |
| NFR-1.5 | PDF generation time for standard exam result | < 3 seconds |
| NFR-1.6 | Database query response time (95th percentile) | < 1 second |

### NFR-2: Reliability

| ID | Requirement |
|---|---|
| NFR-2.1 | Exam answers shall be saved to database within 1 second of each selection (no data loss on crash) |
| NFR-2.2 | Session shall persist across browser refresh and app restart without requiring re-login |
| NFR-2.3 | System shall gracefully degrade if Gemini AI API is unavailable (chatbot shows error, rest of app works) |
| NFR-2.4 | System shall function for content browsing if Realtime connection is temporarily lost |
| NFR-2.5 | Flashcard data shall be accessible offline (Hive local cache) |

### NFR-3: Security

| ID | Requirement |
|---|---|
| NFR-3.1 | All passwords shall be hashed with SHA-256 before storage; plaintext never stored in sessions |
| NFR-3.2 | The Supabase anon key shall be the only credential in client code (service role key never in client) |
| NFR-3.3 | Students shall only see exams targeting their batch; server-side filtering enforced |
| NFR-3.4 | Admin endpoints shall verify isAdmin == true before executing admin operations |
| NFR-3.5 | Gemini API keys shall be stored in device SharedPreferences, never transmitted to any server other than Google |

### NFR-4: Usability

| ID | Requirement |
|---|---|
| NFR-4.1 | UI shall be responsive and functional from 320px (mobile) to 2560px (4K) screen width |
| NFR-4.2 | All interactive elements shall have minimum 44×44px tap target on mobile |
| NFR-4.3 | Loading states shall be shown (shimmer/spinner) for all async operations > 200ms |
| NFR-4.4 | Error messages shall be user-friendly (not raw error stack traces) |
| NFR-4.5 | Navigation between major sections shall complete within 300ms (no full reloads) |

### NFR-5: Scalability

| ID | Requirement |
|---|---|
| NFR-5.1 | System shall support up to 500 concurrent student sessions |
| NFR-5.2 | PYQ database shall support up to 50,000 questions without performance degradation |
| NFR-5.3 | System shall support up to 50 batches and unlimited students per batch |
| NFR-5.4 | Exam results shall be retained indefinitely per student |

### NFR-6: Maintainability

| ID | Requirement |
|---|---|
| NFR-6.1 | All database operations shall be centralised in SupabaseService (single point of change) |
| NFR-6.2 | All route strings shall be defined in Routes constants file (no magic strings in navigation) |
| NFR-6.3 | All colours shall be defined in AppColors (no inline Color() in UI code) |
| NFR-6.4 | Each feature shall be in its own directory under lib/features/ |

---

## 11. External Interface Requirements

### 11.1 Supabase Interface

| Attribute | Detail |
|---|---|
| Protocol | HTTPS (REST/PostgREST) + WebSocket (Realtime) |
| Authentication | Anon key in request headers |
| Data Format | JSON |
| Real-time | WebSocket channel subscriptions for exam and developer_info tables |
| Error Handling | All Supabase exceptions caught and logged; UI shows friendly error messages |

### 11.2 Google Gemini API Interface

| Attribute | Detail |
|---|---|
| Protocol | HTTPS REST |
| Authentication | User-provided API key (stored in SharedPreferences) |
| Request Format | JSON with role/parts message structure |
| Response | Streamed text (displayed incrementally in chatbot) |
| Error Handling | If API key invalid or quota exceeded, show user-friendly error message |

### 11.3 User Interface

| Platform | Interface Type |
|---|---|
| Web | Flutter Web app in browser (Chrome, Firefox, Safari, Edge) |
| Android | Flutter Android app |
| Responsive Layout | Bottom navigation (< 600px), Sidebar (≥ 1000px) |

---

## 12. Constraints and Assumptions

### Constraints

1. **No custom backend** — all logic must work within Flutter client + Supabase SDK
2. **Single admin** — the system is designed for one institution with one admin user
3. **No iOS app** — only web and Android are targeted
4. **No offline exam-taking** — internet connection required for exams (answers saved to DB)
5. **CSV-only PYQ import** — no direct database GUI for bulk question entry
6. **Gemini API cost** — user bears the cost of their own Gemini API key usage

### Assumptions

1. All students have access to a smartphone or computer with internet access
2. The admin has basic computer literacy (file uploads, form filling)
3. Supabase free tier or paid tier will be used (project URL and anon key configured)
4. The PYQ CSV files are UTF-8 encoded and follow the standard column format
5. Google Drive is used for hosting PDF notes (share links used in the notes system)

---

## 13. Glossary

| Term | Definition |
|---|---|
| NEET | National Eligibility cum Entrance Test — India's medical entrance examination |
| PYQ | Previous Year Questions — actual questions from past NEET exams |
| CBT | Computer Based Test — the exam-taking interface |
| NEET Score | Scoring formula: correct × 4 + wrong × (−1) + unattempted × 0 |
| Batch | A named group of students at the same class level within the institute |
| Prepcoins | Virtual currency earned by login streak; spent to unlock gated exams |
| SHA-256 | Cryptographic hash function producing a 256-bit digest; used for passwords |
| Realtime | Supabase's WebSocket service; pushes database changes to all connected clients |
| JSONB | PostgreSQL's binary JSON column type; used for flexible data like exam answers |
| StreamProvider | Riverpod provider type that wraps an async stream; rebuilds UI on each new value |
| FutureProvider | Riverpod provider type that fetches data once and caches the result |
| GoRouter Shell Route | Navigation pattern that keeps outer UI (nav bar) while swapping inner content |
| CustomPainter | Flutter class for drawing custom graphics on a Canvas (used for bio diagrams) |
| Hive | Lightweight key-value database for Flutter; stores flashcards and session locally |
| Supabase Anon Key | Public API key safe to include in client code; protected by RLS policies |
| Maintenance Mode | System state controlled by admin where students see a "back soon" overlay |
| DFD | Data Flow Diagram — a diagram showing how data moves through a system |
| ER Diagram | Entity-Relationship Diagram — shows database tables and their relationships |
| HLD | High Level Design — architectural overview of the system |
| LLD | Low Level Design — detailed design of individual components |
| RTM | Requirements Traceability Matrix — maps requirements to test cases |

---

*End of Software Requirements Specification*
*PRAEPARATIO v1.0.0 — Deepan Pramanick — 2026*
