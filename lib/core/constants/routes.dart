class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String adminLogin = '/admin-login';

  // Admin routes
  static const String adminRoot = '/admin';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminExamEngine = '/admin/exam-engine';
  static const String adminExamCreate = '/admin/exam-engine/create';
  static const String adminExamEdit = '/admin/exam-engine/edit/:examId';
  static const String adminExamStats = '/admin/exam-engine/stats/:examId';
  static const String adminDatabase = '/admin/database';
  static const String adminPyqUpload = '/admin/pyq-upload';
  static const String adminNotesLinks = '/admin/notes-links';
  static const String adminStudentActivity = '/admin/student-activity';
  static const String adminStudentDetail = '/admin/student-activity/:studentId';
  static const String adminCredits = '/admin/credits';
  static const String adminBatches = '/admin/batches';
  static const String adminNotifications = '/admin/notifications';
  static const String adminDeveloper = '/admin/developer';
  static const String adminAiSettings = '/admin/ai-settings';

  // Student routes
  static const String studentRoot = '/student';
  static const String studentDashboard = '/student/dashboard';
  static const String studentOnlineTests = '/student/online-tests';
  static const String cbt = '/student/exam/:examId';
  static const String examResult = '/student/exam/:examId/result';
  static const String studentPyq = '/student/pyq';
  static const String studentFlashcards = '/student/flashcards';
  static const String studentFlashcardViewer = '/student/flashcards/:chapter';
  static const String studentLessonPlanner = '/student/lesson-planner';
  static const String studentGlossary = '/student/glossary';
  static const String studentBioLab = '/student/bio-lab';
  static const String studentGames = '/student/games';
  static const String studentHistory = '/student/history';
  static const String studentMockResults = '/student/mock-results';
  static const String studentChatbot = '/student/chatbot';
  static const String studentNotes = '/student/notes';
  static const String studentLinks = '/student/external-links';
  static const String studentNcertPdf = '/student/ncert-pdf/:class';
  static const String studentOfflineResults = '/student/offline-results';
  static const String studentBadges = '/student/badges';
}
