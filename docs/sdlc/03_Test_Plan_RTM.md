# TEST PLAN AND REQUIREMENTS TRACEABILITY MATRIX (RTM)

**Project:** PRAEPARATIO — NEET Biology Preparation Platform
**Document Version:** 1.0
**Status:** Approved
**Author:** Deepan Pramanick
**Date:** 2026

---

## Table of Contents

1. [Test Plan Overview](#1-test-plan-overview)
2. [Test Scope](#2-test-scope)
3. [Test Strategy](#3-test-strategy)
4. [Test Environment](#4-test-environment)
5. [Test Cases — Authentication](#5-test-cases--authentication)
6. [Test Cases — Student Management](#6-test-cases--student-management)
7. [Test Cases — Exam Management](#7-test-cases--exam-management)
8. [Test Cases — Exam Execution (CBT)](#8-test-cases--exam-execution-cbt)
9. [Test Cases — PYQ System](#9-test-cases--pyq-system)
10. [Test Cases — Bio Lab](#10-test-cases--bio-lab)
11. [Test Cases — Notes System](#11-test-cases--notes-system)
12. [Test Cases — Notifications](#12-test-cases--notifications)
13. [Test Cases — Maintenance Mode](#13-test-cases--maintenance-mode)
14. [Test Cases — Non-Functional](#14-test-cases--non-functional)
15. [Requirements Traceability Matrix (RTM)](#15-requirements-traceability-matrix-rtm)
16. [Test Schedule](#16-test-schedule)
17. [Defect Classification](#17-defect-classification)

---

## 1. Test Plan Overview

### 1.1 Purpose

This Test Plan describes the approach, scope, resources, and schedule for testing PRAEPARATIO v1.0.0 before production release. It ensures that all functional and non-functional requirements defined in the SRS are verified.

### 1.2 Test Objectives

- Verify all functional requirements (FR) are correctly implemented
- Verify non-functional requirements (performance, security, reliability)
- Identify and document all defects before production deployment
- Confirm correct behavior on both Web (Chrome) and Android platforms
- Validate the NEET scoring algorithm produces correct results
- Verify no data loss during exam taking (live answer save)
- Confirm maintenance mode propagates correctly to all clients

### 1.3 Test Deliverables

| Deliverable | Description |
|---|---|
| Test Plan | This document |
| Test Cases | Detailed test cases in Sections 5–14 |
| RTM | Requirements Traceability Matrix in Section 15 |
| Test Execution Log | Manual record of pass/fail for each test case |
| Defect Report | List of found bugs with severity and status |

---

## 2. Test Scope

### 2.1 In Scope

- All features accessible by Admin user
- All features accessible by Student user
- Authentication flows (login, logout, session restore)
- Exam creation, publishing, execution, and results
- PYQ upload and practice modes
- Bio Lab animated diagrams
- Notes upload, ordering, and visibility
- Notification system
- Maintenance mode
- Responsive layout on mobile and desktop
- PDF generation
- CSV import/export

### 2.2 Out of Scope

- Google Gemini AI response quality (content accuracy)
- Supabase infrastructure reliability (third-party)
- Network-level security testing (penetration testing)
- Load/stress testing beyond 500 concurrent users
- iOS platform (not supported)

---

## 3. Test Strategy

### 3.1 Testing Types

| Type | Description | Tools |
|---|---|---|
| **Functional Testing** | Verify each feature works as specified | Manual testing |
| **UI Testing** | Verify correct rendering on multiple screen sizes | Chrome DevTools responsive mode, Android device |
| **Integration Testing** | Verify Supabase integration, Realtime events | Manual with live Supabase instance |
| **Regression Testing** | Re-test after bug fixes | Manual, re-run affected test cases |
| **Security Testing** | Verify password hashing, access controls | Manual verification |
| **Performance Testing** | Measure response times for key operations | Browser DevTools, Stopwatch |

### 3.2 Test Levels

```
Level 1: UNIT-LIKE VERIFICATION
  - Manually verify individual algorithms (NEET score, year sort, hash)
  - Verify CSV parsing logic with edge cases

Level 2: FEATURE TESTING
  - Test each feature end-to-end
  - Admin creates → student sees → student acts

Level 3: INTEGRATION TESTING
  - Verify Realtime propagation (publish exam → toast on student)
  - Verify maintenance mode toggle → all clients update

Level 4: SYSTEM TESTING
  - Full user journeys from login to result download
  - Cross-feature interactions (e.g. ban student during exam)
```

### 3.3 Test Entry and Exit Criteria

**Entry Criteria:**
- All code changes deployed to test environment
- Database schema migrations applied
- No compile errors (`flutter analyze` returns 0 errors)

**Exit Criteria:**
- All P1 (Critical) defects resolved
- All P2 (High) defects resolved or deferred with justification
- All test cases executed and results documented
- RTM shows 100% requirement coverage

---

## 4. Test Environment

| Component | Specification |
|---|---|
| Web Browser | Chrome 120+ (primary), Firefox 120+, Safari 17+ |
| Android Device | Android 10+, physical device (not emulator for Realtime testing) |
| Supabase | Live Supabase project with schema applied |
| Flutter | Release build (`flutter build web --release`) |
| Test Data | Minimum: 1 admin, 3 students, 2 batches, 5 exams, 50 PYQ questions |
| Network | Standard 4G connection (simulate with Chrome throttling for performance tests) |

### 4.1 Test Accounts

| Role | Username | Password | Batch | Class |
|---|---|---|---|---|
| Admin | admin | praeparatio@admin2024 | admin | admin |
| Student (Class 11) | test_student11 | test123 | 11 NEET 2025 | 11 |
| Student (Class 12) | test_student12 | test123 | 12 NEET 2025 | 12 |
| Student (NEET) | test_student_neet | test123 | NEET Exclusive | neet |
| Banned Student | banned_student | test123 | 11 NEET 2025 | 11 |

---

## 5. Test Cases — Authentication

### TC-AUTH-001: Student Login — Valid Credentials
**Requirement:** FR-1.1, FR-1.2
**Priority:** P1 (Critical)
```
PRECONDITION: Student account exists in database
STEPS:
  1. Navigate to /login
  2. Enter valid username
  3. Enter valid password
  4. Tap Login button
EXPECTED:
  - Password is SHA-256 hashed before comparison
  - User is redirected to /student/dashboard
  - Welcome message or dashboard content visible
PASS CRITERIA: Dashboard loads with correct student name
```

### TC-AUTH-002: Student Login — Wrong Password
**Requirement:** FR-1.1
**Priority:** P1 (Critical)
```
PRECONDITION: Student account exists
STEPS:
  1. Enter correct username
  2. Enter WRONG password
  3. Tap Login
EXPECTED:
  - Error message displayed (e.g. "Invalid username or password")
  - User NOT redirected
  - No session created
PASS CRITERIA: Error shown, user stays on login screen
```

### TC-AUTH-003: Banned Student Login
**Requirement:** FR-1.5
**Priority:** P1 (Critical)
```
PRECONDITION: Student account with is_banned = true
STEPS:
  1. Attempt login with banned student credentials
EXPECTED:
  - Error message shown ("Account suspended")
  - User NOT logged in
PASS CRITERIA: Banned user cannot log in
```

### TC-AUTH-004: Admin Trigger Login
**Requirement:** FR-1.4
**Priority:** P1 (Critical)
```
STEPS:
  1. Enter "4444" as username
  2. Enter "4444" as password
  3. Tap Login
EXPECTED:
  - AdminLoginDialog appears (not a direct login)
  4. Enter real admin credentials in dialog
EXPECTED:
  - Admin is redirected to /admin/dashboard
PASS CRITERIA: Admin trigger detected; dialog appears; admin logs in
```

### TC-AUTH-005: Session Restore After Browser Refresh
**Requirement:** FR-1.3
**Priority:** P1 (Critical)
```
PRECONDITION: Student is logged in on web browser
STEPS:
  1. Student is on /student/dashboard
  2. Press F5 (browser refresh)
EXPECTED:
  - App reloads
  - Student is automatically redirected to /student/dashboard (not /login)
  - No re-login required
PASS CRITERIA: Session persists across page refresh
```

### TC-AUTH-006: Admin Cannot Access Student Shell
**Requirement:** FR-1.7
**Priority:** P2 (High)
```
PRECONDITION: Admin is logged in
STEPS:
  1. Manually navigate to /student/dashboard in URL bar
EXPECTED:
  - GoRouter redirect fires
  - Admin is redirected to /admin/dashboard
PASS CRITERIA: Admin cannot access student routes
```

### TC-AUTH-007: Student Cannot Access Admin Shell
**Requirement:** FR-1.7
**Priority:** P2 (High)
```
PRECONDITION: Student is logged in
STEPS:
  1. Manually navigate to /admin/dashboard in URL bar
EXPECTED:
  - GoRouter redirect fires
  - Student is redirected to /student/dashboard
PASS CRITERIA: Student cannot access admin routes
```

---

## 6. Test Cases — Student Management

### TC-STU-001: Create Student Account
**Requirement:** FR-2.1, FR-2.2
**Priority:** P1
```
STEPS:
  1. Admin logs in → /admin/database
  2. Tap "+" (Create Student)
  3. Fill: name="Test Student", username="ts001", password="pass123", class="11", batch="11 NEET 2025"
  4. Tap Save
EXPECTED:
  - Student appears in student list
  - Student can log in with ts001/pass123
  - Student is in batch "11 NEET 2025"
PASS CRITERIA: Account created, login works
```

### TC-STU-002: Create Student Without Password
**Requirement:** FR-2.2
**Priority:** P1
```
STEPS:
  1. Admin → Create Student
  2. Fill name, username, class, batch (LEAVE password empty)
  3. Tap Save
EXPECTED:
  - Save does NOT create the student
  - No error or crash (silent return)
  - Password field shows validation or nothing happens
PASS CRITERIA: Student NOT created without password
```

### TC-STU-003: Edit Student (Keep Existing Password)
**Requirement:** FR-2.3
**Priority:** P2
```
STEPS:
  1. Admin edits existing student
  2. Changes name only (leaves password field blank)
  3. Saves
EXPECTED:
  - Name is updated
  - Password remains unchanged (student can still log in with old password)
PASS CRITERIA: Edit preserves password when field left blank
```

### TC-STU-004: Ban and Unban Student
**Requirement:** FR-2.5
**Priority:** P2
```
STEPS:
  1. Admin bans student "ts001"
  2. Student ts001 tries to log in
  3. Admin unbans ts001
  4. Student ts001 tries to log in again
EXPECTED:
  Step 2: Login fails with "Account suspended"
  Step 4: Login succeeds
PASS CRITERIA: Ban/unban works correctly
```

### TC-STU-005: CSV Student Import
**Requirement:** FR-2.6
**Priority:** P2
```
PRECONDITION: Valid CSV file with 5 students (columns: name,username,password,class,batch)
STEPS:
  1. Admin → Database → Import CSV
  2. Select valid CSV file
  3. Confirm import
EXPECTED:
  - All 5 students created in database
  - Students can log in with their CSV credentials
PASS CRITERIA: Bulk import works
```

---

## 7. Test Cases — Exam Management

### TC-EXAM-001: Create and Publish Exam
**Requirement:** FR-4.1, FR-4.6, FR-4.7
**Priority:** P1
```
STEPS:
  1. Admin → /admin/exams → Create Exam
  2. Fill: title, select batch "11 NEET 2025", duration 30min
  3. Add 5 manual questions (each with 4 options, correct answer, explanation)
  4. Save (unpublished)
  5. Verify exam appears in list as unpublished
  6. Tap Publish
  7. Switch to logged-in student device
EXPECTED at Step 7:
  - Toast notification appears on student device within 2 seconds
  - Exam appears in student's /student/tests list
  - Notification bell shows unread count +1
PASS CRITERIA: Publish propagates in real-time to student
```

### TC-EXAM-002: Exam Visibility Window
**Requirement:** FR-4.4
**Priority:** P2
```
STEPS:
  1. Create exam with visibilityStart = tomorrow
  2. Publish the exam
  3. Check student's exam list today
EXPECTED:
  - Exam does NOT appear in student's list
  4. Advance system date past visibilityStart (or manually set start to past)
  5. Check student's exam list
EXPECTED:
  - Exam now appears
PASS CRITERIA: Exam respects visibility window
```

### TC-EXAM-003: Exam Targeted to Wrong Batch
**Requirement:** FR-5.1
**Priority:** P1
```
PRECONDITION: Exam targeted to "12 NEET 2025" only
STEPS:
  1. Class 11 student (in "11 NEET 2025" batch) checks exam list
EXPECTED:
  - Exam does NOT appear in Class 11 student's list
  2. Class 12 student (in "12 NEET 2025" batch) checks exam list
EXPECTED:
  - Exam appears in Class 12 student's list
PASS CRITERIA: Batch filtering works correctly
```

### TC-EXAM-004: Download Question Paper PDF
**Requirement:** FR-4.8
**Priority:** P2
```
STEPS:
  1. Admin → Exam list
  2. Tap download icon on an exam
  3. Select "Questions Only" and "Questions + Answers"
EXPECTED:
  - Two PDFs download/open
  - "Questions Only" PDF has no answers marked
  - "Questions + Answers" PDF has a separate Answer Key section
  - No special characters render as boxes (⊠)
PASS CRITERIA: Both PDF types generate correctly
```

---

## 8. Test Cases — Exam Execution (CBT)

### TC-CBT-001: Take Exam and Submit
**Requirement:** FR-5.4, FR-5.5, FR-5.8, FR-5.9
**Priority:** P1
```
STEPS:
  1. Student opens an available exam
  2. ExamStartDialog shows duration and question count
  3. Student confirms → CBTPortal opens
  4. Student answers all questions
  5. Student taps Submit
EXPECTED:
  - Timer starts and counts down
  - Each answer selected saves immediately (verify in DB)
  - After submit: NEET score displayed (correct×4 - wrong×1)
  - Per-question review shows correct answers
  - Explanations visible
PASS CRITERIA: Score formula correct, results shown
```

### TC-CBT-002: Live Answer Save (No Data Loss)
**Requirement:** FR-5.5
**Priority:** P1 (Critical)
```
STEPS:
  1. Student starts exam
  2. Answers 3 questions
  3. Force-close the browser/app (do not submit)
  4. Check exam_results in database
EXPECTED:
  - answers JSONB in exam_results contains the 3 answered questions
  - is_in_progress = true
  - No answers lost
PASS CRITERIA: Answers persisted despite force-close
```

### TC-CBT-003: Resume In-Progress Exam
**Requirement:** FR-5.6, FR-5.7
**Priority:** P1
```
PRECONDITION: Student has an in-progress exam (from TC-CBT-002)
STEPS:
  1. Student opens the same exam again
EXPECTED:
  - CBTPortal loads with previously answered questions highlighted
  - Timer shows remaining time (not full duration)
  - Student can continue and submit normally
PASS CRITERIA: Resume works with correct saved state
```

### TC-CBT-004: NEET Score Calculation Accuracy
**Requirement:** FR-5.8
**Priority:** P1 (Critical)
```
TEST DATA:
  Total questions: 10
  Correct answers: 6
  Wrong answers: 3
  Unattempted: 1
EXPECTED NEET SCORE:
  (6 × 4) - (3 × 1) = 24 - 3 = 21
STEPS:
  1. Set up exam with 10 known questions and correct answers
  2. Student answers 6 correct, 3 wrong, skips 1
  3. Submit exam
  4. View result screen
EXPECTED:
  - Score shown: 21
  - Correct: 6, Wrong: 3, Unattempted: 1
PASS CRITERIA: Score = 21 exactly
```

### TC-CBT-005: Auto-Submit on Timer Expiry
**Requirement:** FR-5.6
**Priority:** P1
```
STEPS:
  1. Create exam with 1-minute duration
  2. Student starts exam
  3. Wait for timer to reach 0 without submitting
EXPECTED:
  - Exam auto-submits when timer hits 0
  - Result screen shown automatically
  - is_in_progress = false in database
PASS CRITERIA: Auto-submit fires, result shown
```

### TC-CBT-006: Download Result PDF
**Requirement:** FR-5.10
**Priority:** P2
```
STEPS:
  1. Student submits exam
  2. On result screen, tap "Download PDF"
EXPECTED:
  - PDF downloads/opens
  - PDF contains student name, exam title, score, question breakdown
  - No rendering artifacts (⊠ boxes, color-on-color issues)
PASS CRITERIA: Clean, readable PDF generated
```

---

## 9. Test Cases — PYQ System

### TC-PYQ-001: Upload PYQ CSV
**Requirement:** FR-6.1, FR-6.2, FR-6.3
**Priority:** P1
```
PRECONDITION: Valid CSV with 50 questions for year "2024"
STEPS:
  1. Admin → /admin/pyq
  2. Enter year name "2024"
  3. Select valid CSV
  4. Confirm upload
EXPECTED:
  - Progress shown during upload
  - "50 questions uploaded" success message
  - Year "2024" appears in uploaded years chips
  - Student sees new questions in yearwise mode
PASS CRITERIA: Upload succeeds, questions available to students
```

### TC-PYQ-002: Upload with Invalid Correct Options
**Requirement:** FR-6.2
**Priority:** P2
```
PRECONDITION: CSV with some rows having correct_option = "E" or "1"
STEPS:
  1. Admin uploads CSV with invalid correct options
EXPECTED:
  - Invalid rows SKIPPED (not inserted)
  - Valid rows still inserted
  - Message shows "X questions uploaded, Y skipped"
PASS CRITERIA: Invalid rows rejected, valid rows accepted
```

### TC-PYQ-003: Year Name with Text (e.g. "2025 Cancelled")
**Requirement:** FR-6.4
**Priority:** P2
```
STEPS:
  1. Admin enters year name "2025 Cancelled"
  2. Uploads valid CSV
EXPECTED:
  - Year appears as "2025 Cancelled" in student yearwise grid
  - Student can browse and test questions for this year
PASS CRITERIA: Text year names work correctly
```

### TC-PYQ-004: Correct Option Case Insensitivity
**Requirement:** FR-6.9
**Priority:** P2
```
PRECONDITION: PYQ data with correct_option = "a" (lowercase) in DB
STEPS:
  1. Student opens a question where correct_option = "a"
  2. Taps "Show Answer"
EXPECTED:
  - Option A is highlighted as correct (case-insensitive comparison)
  - NOT treated as no correct answer
PASS CRITERIA: Lowercase correct options work
```

### TC-PYQ-005: Class 11 Student PYQ Filter
**Requirement:** FR-6.8
**Priority:** P1
```
PRECONDITION: PYQ exists for both Class 11 and Class 12 chapters
STEPS:
  1. Class 11 student opens PYQ → Chapterwise tab
EXPECTED:
  - Only Class 11 chapters visible
  - Class 12 chapters NOT shown
  - Filter bar hidden for Class 11 students
PASS CRITERIA: Class filter enforced for Class 11 students
```

### TC-PYQ-006: PYQ Year Sort (Newest First)
**Requirement:** FR-6.6 (implied by getAvailablePYQYears())
**Priority:** P2
```
PRECONDITION: PYQ exists for years: "2022", "2024", "2023", "2025 Cancelled"
STEPS:
  1. Student opens PYQ → Yearwise tab
EXPECTED order:
  "2025 Cancelled", "2024", "2023", "2022"
PASS CRITERIA: Years displayed newest-first with numeric sort
```

---

## 10. Test Cases — Bio Lab

### TC-BIO-001: Animation Loads for Implemented Processes
**Requirement:** FR-7.1, FR-7.2, FR-7.3
**Priority:** P1
```
STEPS:
  1. Student → /student/bio-lab
  2. Select "Mitosis" from the list
EXPECTED:
  - Toggle pill "Animation | Steps" appears
  - Animation mode is default
  - Animated diagram renders (no black box, no overflow)
  - Diagram updates when step changes
PASS CRITERIA: Animation renders correctly, responsive
```

### TC-BIO-002: No Toggle for Unimplemented Processes
**Requirement:** FR-7.4
**Priority:** P1
```
STEPS:
  1. Student selects a process with no animation (if any exist)
     OR if all 32 are implemented: verify toggle appears for ALL
EXPECTED:
  - Toggle ONLY appears when animation is implemented
  - Processes without animation show Steps mode directly (no toggle)
PASS CRITERIA: Toggle correctly shows/hides based on implementation
```

### TC-BIO-003: Animation / Steps Toggle
**Requirement:** FR-7.3
**Priority:** P1
```
STEPS:
  1. Select "DNA Double Helix"
  2. Animation mode is shown by default
  3. Tap "Steps" in toggle
EXPECTED:
  - Step detail card appears (title, description, progress bar)
  - Animated canvas is hidden
  4. Tap "Animation" in toggle
EXPECTED:
  - Animated canvas reappears
  - Canvas is animating (not static)
PASS CRITERIA: Toggle switches between modes correctly
```

### TC-BIO-004: Bio Diagrams Responsive (No Overflow)
**Requirement:** FR-7.7
**Priority:** P1
```
STEPS:
  1. Open Bio Lab on smallest tested width (320px mobile)
  2. Open Bio Lab on largest tested width (1440px desktop)
  3. Check each diagram for overflow, text cutoff, canvas out-of-bounds
EXPECTED:
  - No RenderOverflow errors in console
  - Diagrams scale correctly at all sizes
  - Labels readable, not cut off
PASS CRITERIA: Zero overflow errors on all tested screen sizes
```

---

## 11. Test Cases — Notes System

### TC-NOTES-001: Admin Upload and Student View
**Requirement:** FR-8.1, FR-8.6
**Priority:** P1
```
STEPS:
  1. Admin → Notes → Add Note
  2. Name: "Cell Biology Notes", URL: [Google Drive link], Section: "Class 11", Visibility: All
  3. Save
  4. Class 11 student opens /student/notes
EXPECTED:
  - Note appears under "Class 11" section
  - Tapping opens PDF viewer (in-app)
PASS CRITERIA: Note visible to student, PDF opens
```

### TC-NOTES-002: Sort Order Persistence
**Requirement:** FR-8.3, FR-8.8
**Priority:** P1
```
STEPS:
  1. Admin has notes in order: A, B, C
  2. Admin taps ▲ on note C → order becomes: A, C, B
  3. Admin taps Save
  4. Wait 10 seconds (multiple Supabase stream events may fire)
EXPECTED:
  - Order remains: A, C, B (not reset to A, B, C)
  5. Student checks notes
EXPECTED:
  - Notes appear in order: A, C, B
PASS CRITERIA: Sort order persists despite Supabase stream activity
NOTE: This tests the Set equality bug fix
```

### TC-NOTES-003: Section Collapse/Expand
**Requirement:** FR-8.7
**Priority:** P2
```
STEPS:
  1. Student → /student/notes
  2. Tap on a section header
EXPECTED:
  - Section notes collapse (hidden)
  - Arrow rotates to indicate collapsed
  3. Tap header again
EXPECTED:
  - Section notes expand (visible)
  - Arrow rotates back
PASS CRITERIA: Collapse/expand works with animation
```

### TC-NOTES-004: Visibility Control
**Requirement:** FR-8.4, FR-8.6
**Priority:** P1
```
STEPS:
  1. Admin creates note with visibility = "12" (Class 12 only)
  2. Class 11 student checks notes
EXPECTED: Note NOT visible
  3. Class 12 student checks notes
EXPECTED: Note IS visible
  4. NEET student checks notes
EXPECTED: Note IS visible (NEET sees all)
PASS CRITERIA: Visibility filtering correct for all class levels
```

---

## 12. Test Cases — Notifications

### TC-NOTIF-001: Exam Published Notification
**Requirement:** FR-9.1, FR-9.5
**Priority:** P1
```
PRECONDITION: Student is logged in and app is open
STEPS:
  1. Admin publishes an exam targeted to student's batch
EXPECTED within 2 seconds:
  - Toast notification appears on student's screen
  - Bell badge increments
  - Notification appears in student's notification inbox
PASS CRITERIA: Real-time notification received
```

### TC-NOTIF-002: Targeted Batch Notification
**Requirement:** FR-9.4
**Priority:** P2
```
STEPS:
  1. Admin → Notifications → compose message
  2. Target: "11 NEET 2025" batch only
  3. Send
EXPECTED:
  - Students in "11 NEET 2025" batch receive notification
  - Students in "12 NEET 2025" batch do NOT receive notification
PASS CRITERIA: Batch targeting works
```

### TC-NOTIF-003: Mark Notification as Read
**Requirement:** FR-9.6
**Priority:** P2
```
STEPS:
  1. Student has unread notification (bell badge = 1)
  2. Opens notification inbox
  3. Notification appears unread
  4. Marks as read (tap)
EXPECTED:
  - Bell badge decrements to 0
  - Notification shows as read
PASS CRITERIA: Read tracking works
```

---

## 13. Test Cases — Maintenance Mode

### TC-MAINT-001: Toggle Maintenance ON
**Requirement:** FR-10.1, FR-10.2, FR-10.4
**Priority:** P1
```
PRECONDITION: Student is logged in, student shell visible
STEPS:
  1. Admin → /admin/developer → toggle "Maintenance Mode" ON
  2. Tap Save
EXPECTED within 2 seconds:
  - Student's screen replaces student shell with MaintenanceScreen
  - MaintenanceScreen shows animated gears and "Under Maintenance" text
  - Admin's screen is UNCHANGED (still admin shell)
PASS CRITERIA: Maintenance propagates in real-time; admin unaffected
```

### TC-MAINT-002: Toggle Maintenance OFF
**Requirement:** FR-10.1, FR-10.4
**Priority:** P1
```
PRECONDITION: Maintenance mode is ON, students see maintenance screen
STEPS:
  1. Admin toggles Maintenance Mode OFF → Save
EXPECTED within 2 seconds:
  - Student's maintenance screen is replaced by normal student shell
  - No page refresh required
PASS CRITERIA: Restoration works in real-time
```

### TC-MAINT-003: Student Can Log Out from Maintenance Screen
**Requirement:** FR-10.5
**Priority:** P1
```
PRECONDITION: Maintenance mode is ON, student is logged in
STEPS:
  1. Student is on maintenance screen
  2. Taps "Log Out" button
EXPECTED:
  - Student is logged out
  - Student is redirected to /login
  - Maintenance screen is no longer shown (user is not authenticated)
PASS CRITERIA: Logout from maintenance screen works
```

### TC-MAINT-004: Admin Access Link on Maintenance Screen
**Requirement:** FR-10.6
**Priority:** P2
```
PRECONDITION: Maintenance mode is ON, user is logged out (on /login)
STEPS:
  1. User navigates to login screen directly (not logged in)
  2. Notice: no maintenance screen (only logged-in students see it)
  3. Log in as admin
EXPECTED:
  - Admin logs in normally (not blocked by maintenance)
  - Admin is taken to /admin/dashboard
  4. Admin can toggle maintenance OFF
PASS CRITERIA: Admin can log in and turn off maintenance even when on
```

---

## 14. Test Cases — Non-Functional

### TC-NFR-001: App Load Time
**Requirement:** NFR-1.1
**Priority:** P2
```
TOOL: Chrome DevTools Network tab
CONDITION: 4G throttling (12 Mbps download)
STEPS:
  1. Clear browser cache
  2. Navigate to app URL
  3. Measure time from navigation to dashboard visible
EXPECTED: < 4 seconds
PASS CRITERIA: Load time under 4 seconds on simulated 4G
```

### TC-NFR-002: Password Not Stored in Plaintext in Session
**Requirement:** NFR-3.1
**Priority:** P1 (Security Critical)
```
STEPS:
  1. Log in as student
  2. Open Browser DevTools → Application → Local Storage / IndexDB (Hive)
  3. Find the session data
EXPECTED:
  - password_hash is a 64-character hex string (SHA-256)
  - plaintext password NOT visible in session storage
  - passwordPlain NOT in Hive session (should only be in admin DB view)
PASS CRITERIA: No plaintext password in client storage
```

### TC-NFR-003: Responsive Layout — Mobile
**Requirement:** NFR-4.1
**Priority:** P1
```
STEPS:
  1. Open app in Chrome with mobile emulation (360×800px, iPhone SE)
  2. Test: Login, Dashboard, Exam list, PYQ, Bio Lab, Notes, Admin panel
EXPECTED:
  - Bottom navigation visible (not sidebar)
  - All content fits without horizontal scrolling
  - No overflow errors
  - Tap targets are comfortable size (>44px)
PASS CRITERIA: Full functionality on mobile width
```

### TC-NFR-004: Responsive Layout — Desktop
**Requirement:** NFR-4.1
**Priority:** P1
```
STEPS:
  1. Open app in Chrome at 1440px width
  2. Test: Student shell (sidebar), Admin panel (sidebar)
EXPECTED:
  - Sidebar navigation visible (not bottom nav)
  - Content area uses available space efficiently
  - No excessive empty space or cramped content
PASS CRITERIA: Sidebar layout on desktop
```

### TC-NFR-005: Flashcards Offline
**Requirement:** NFR-2.5
**Priority:** P2
```
STEPS:
  1. Student logs in and visits Flashcards once (seeds Hive)
  2. Simulate offline (Chrome DevTools → Network → Offline)
  3. Navigate to /student/flashcards
EXPECTED:
  - Flashcards load from Hive cache
  - No error message
  - Full flashcard functionality works
PASS CRITERIA: Flashcards available offline
```

---

## 15. Requirements Traceability Matrix (RTM)

| Requirement ID | Requirement Description | Test Case(s) | Status |
|---|---|---|---|
| FR-1.1 | Student login with username + password | TC-AUTH-001, TC-AUTH-002 | ☐ |
| FR-1.2 | SHA-256 password hashing | TC-AUTH-001, TC-NFR-002 | ☐ |
| FR-1.3 | Session persistence across restart | TC-AUTH-005 | ☐ |
| FR-1.4 | Admin trigger detection (4444/4444) | TC-AUTH-004 | ☐ |
| FR-1.5 | Prevent banned student login | TC-AUTH-003 | ☐ |
| FR-1.6 | Admin cannot log in as student | TC-AUTH-001 | ☐ |
| FR-1.7 | Role-based routing | TC-AUTH-006, TC-AUTH-007 | ☐ |
| FR-1.8 | Update last_login on login | TC-AUTH-001 (verify DB) | ☐ |
| FR-2.1 | Create student account | TC-STU-001 | ☐ |
| FR-2.2 | Require password for new student | TC-STU-002 | ☐ |
| FR-2.3 | Edit preserves password when blank | TC-STU-003 | ☐ |
| FR-2.5 | Ban / Unban student | TC-STU-004 | ☐ |
| FR-2.6 | CSV student import | TC-STU-005 | ☐ |
| FR-3.1 | Create/rename/delete batches | Manual verification | ☐ |
| FR-3.3 | Promote students between batches | Manual verification | ☐ |
| FR-4.1 | Create exam with questions | TC-EXAM-001 | ☐ |
| FR-4.4 | Exam visibility window | TC-EXAM-002 | ☐ |
| FR-4.6 | Publish/unpublish exam | TC-EXAM-001 | ☐ |
| FR-4.7 | Real-time publish notification | TC-EXAM-001, TC-NOTIF-001 | ☐ |
| FR-4.8 | Download question paper PDF | TC-EXAM-004 | ☐ |
| FR-5.1 | Filter exams by batch | TC-EXAM-003 | ☐ |
| FR-5.2 | Exam visibility window for students | TC-EXAM-002 | ☐ |
| FR-5.4 | Timed exam with countdown | TC-CBT-001, TC-CBT-005 | ☐ |
| FR-5.5 | Live answer save | TC-CBT-002 | ☐ |
| FR-5.6 | Auto-submit on timer expiry | TC-CBT-005 | ☐ |
| FR-5.7 | Resume in-progress exam | TC-CBT-003 | ☐ |
| FR-5.8 | NEET score calculation | TC-CBT-004 | ☐ |
| FR-5.9 | Detailed results with review | TC-CBT-001 | ☐ |
| FR-5.10 | Download result PDF | TC-CBT-006 | ☐ |
| FR-6.1 | Upload PYQ via CSV | TC-PYQ-001 | ☐ |
| FR-6.2 | Validate CSV rows | TC-PYQ-002 | ☐ |
| FR-6.3 | Safe year replacement | TC-PYQ-001 (verify DB) | ☐ |
| FR-6.4 | Text year names | TC-PYQ-003 | ☐ |
| FR-6.6 | Yearwise PYQ (newest first) | TC-PYQ-006 | ☐ |
| FR-6.8 | Class-level PYQ filter | TC-PYQ-005 | ☐ |
| FR-6.9 | Case-insensitive correct option | TC-PYQ-004 | ☐ |
| FR-7.1 | 32 animated bio diagrams | TC-BIO-001 | ☐ |
| FR-7.2 | Animation + Steps modes | TC-BIO-001, TC-BIO-003 | ☐ |
| FR-7.3 | Toggle between modes | TC-BIO-003 | ☐ |
| FR-7.4 | Toggle only when animation exists | TC-BIO-002 | ☐ |
| FR-7.7 | Diagrams responsive, no overflow | TC-BIO-004 | ☐ |
| FR-8.1 | Admin upload notes/links | TC-NOTES-001 | ☐ |
| FR-8.3 | Sort order persisted on Save | TC-NOTES-002 | ☐ |
| FR-8.4 | Visibility per note | TC-NOTES-004 | ☐ |
| FR-8.6 | Student sees filtered notes | TC-NOTES-001, TC-NOTES-004 | ☐ |
| FR-8.7 | Collapsible sections | TC-NOTES-003 | ☐ |
| FR-8.8 | Notes in admin sort order | TC-NOTES-002 | ☐ |
| FR-9.1 | Auto-notify on exam publish | TC-NOTIF-001 | ☐ |
| FR-9.4 | Admin send targeted notification | TC-NOTIF-002 | ☐ |
| FR-9.5 | Real-time toast for notifications | TC-NOTIF-001 | ☐ |
| FR-9.6 | Notification inbox with read status | TC-NOTIF-003 | ☐ |
| FR-10.1 | Admin toggle maintenance mode | TC-MAINT-001, TC-MAINT-002 | ☐ |
| FR-10.2 | Students see maintenance screen | TC-MAINT-001 | ☐ |
| FR-10.3 | Admin bypasses maintenance | TC-MAINT-001, TC-MAINT-004 | ☐ |
| FR-10.4 | Realtime propagation | TC-MAINT-001, TC-MAINT-002 | ☐ |
| FR-10.5 | Student can log out from maintenance | TC-MAINT-003 | ☐ |
| NFR-1.1 | App load < 4 seconds | TC-NFR-001 | ☐ |
| NFR-3.1 | Passwords hashed, no plaintext in session | TC-NFR-002 | ☐ |
| NFR-4.1 | Responsive 320px to 1440px | TC-NFR-003, TC-NFR-004 | ☐ |
| NFR-2.5 | Flashcards offline | TC-NFR-005 | ☐ |

**RTM Status Key:**
- ☐ = Not yet tested
- ✓ = Pass
- ✗ = Fail (Defect raised)
- ⚠ = Blocked (dependency not available)

---

## 16. Test Schedule

| Phase | Activities | Target Completion |
|---|---|---|
| Phase 1: Setup | Configure test environment, create test accounts, seed test data | Day 1 |
| Phase 2: Smoke Test | TC-AUTH-001, TC-EXAM-001, TC-CBT-001 — basic flow works | Day 1 |
| Phase 3: Functional Testing | All P1 test cases (FR) | Day 2-3 |
| Phase 4: P2 Test Cases | All P2 test cases | Day 4 |
| Phase 5: Non-Functional | TC-NFR-001 to TC-NFR-005 | Day 4 |
| Phase 6: Regression | Re-test any test cases affected by bug fixes | Day 5 |
| Phase 7: Sign-off | RTM completed, all P1 passed, sign-off document | Day 5 |

---

## 17. Defect Classification

### Severity Levels

| Severity | Description | Examples | Resolution Required Before Release? |
|---|---|---|---|
| **P1 — Critical** | System crash, data loss, security breach, cannot complete core workflow | Login broken, answers not saved, wrong NEET score, banned student can log in | YES — must fix |
| **P2 — High** | Major feature not working, significant usability issue | Exam not appearing for correct batch, sort order resets, PDF not generating | YES — must fix |
| **P3 — Medium** | Feature partially working, workaround exists | Upload shows wrong message, minor UI misalignment | Should fix — can defer with justification |
| **P4 — Low** | Cosmetic issue, very minor bug | Font size slightly off, icon color mismatch | Can defer to next version |

### Defect Report Template

```
DEFECT ID:      DEF-001
DATE:           YYYY-MM-DD
SEVERITY:       P1 / P2 / P3 / P4
TITLE:          [Brief description]
DESCRIPTION:    [Detailed description of the bug]
STEPS TO REPRO:
  1. ...
  2. ...
EXPECTED:       [What should happen]
ACTUAL:         [What actually happened]
ENVIRONMENT:    Chrome 120 / Android 12
TEST CASE:      TC-XXX-YYY
STATUS:         Open / In Progress / Fixed / Closed
```

---

*End of Test Plan and Requirements Traceability Matrix*
*PRAEPARATIO v1.0.0 — Deepan Pramanick — 2026*
