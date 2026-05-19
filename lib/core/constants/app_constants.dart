class AppConstants {
  // App
  static const String appName = 'PRAEPARATIO';
  static const String tagline = 'Examination is nothing but fine preparation.';
  static const String appVersion = '1.0.0';

  // Admin backdoor trigger (hardcoded as per spec — opens admin dialog)
  static const String adminTriggerUsername = '4444';
  static const String adminTriggerPassword = '4444';
  // Admin credentials now live in the Supabase `users` table (is_admin = true)
  // Seed SQL is at the bottom of supabase_schema.sql

  // Hive box names
  static const String usersBox = 'users';
  static const String batchesBox = 'batches';
  static const String examsBox = 'exams';
  static const String questionsBox = 'questions';
  static const String resultsBox = 'results';
  static const String pyqBox = 'pyq';
  static const String flashcardsBox = 'flashcards';
  static const String lessonPlansBox = 'lessonPlans';
  static const String notesBox = 'notes';
  static const String linksBox = 'links';
  static const String settingsBox = 'settings';
  static const String offlineTestsBox = 'offlineTests';
  static const String badgesBox = 'badges';
  static const String currentUserBox = 'currentUser';

  // Batches
  static const String batch11 = '11 NEET';
  static const String batch12 = '12 NEET';
  static const String batchNeet = 'NEET Exclusive';

  static const List<String> batches = [batch11, batch12, batchNeet];

  // Exam tags
  static const String tagCompulsory = 'Compulsory';
  static const String tagPractice = 'Practice';
  static const String tagRevision = 'Revision';

  // Difficulty levels
  static const String difficultyEasy = 'Easy';
  static const String difficultyMedium = 'Medium';
  static const String difficultyHard = 'Hard';
  static const String difficultyNeet = 'NEET Level';

  static const List<String> difficulties = [difficultyEasy, difficultyMedium, difficultyHard, difficultyNeet];

  // Default prepcoin amounts
  static const int defaultMonthlyPrepcoins = 80;
  static const int prepcoinsPerOnlineTest = 100;

  // PYQ years
  static const int pyqFirstYear = 2017;
  static const int pyqLastYear = 2024;

  // Time per question (seconds) - base for auto-timing
  static const Map<String, int> secondsPerQuestion = {
    'Easy': 60,
    'Medium': 75,
    'Hard': 90,
    'NEET Level': 72,  // ~180 min / 150 q NEET standard
  };

  // Test completion threshold for prepcoin reward (20% of total time)
  static const double completionThreshold = 0.2;

  // AI — Google Gemini (free tier, no credit card needed)
  // Get your free key at: https://aistudio.google.com/app/apikey
  static const String geminiModel = 'gemini-2.5-flash';  // ← change model name here
  static String geminiEndpoint(String apiKey) =>
      'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent?key=$apiKey';

  // Exam avatar count
  static const int examAvatarCount = 35;

  // Max students per page in database
  static const int studentsPerPage = 100;

  // CSV column names for student import
  static const List<String> studentCsvColumns = ['name', 'username', 'password', 'class', 'batch'];

  // CSV column names for PYQ import
  static const List<String> pyqCsvColumns = [
    'year', 'chapter', 'question', 'optionA', 'optionB', 'optionC', 'optionD',
    'correct', 'imageUrl', 'explanation'
  ];

  // Max PYQ years selectable for custom test
  static const int maxPyqYearsSelectable = 2;

  // Animation durations
  static const Duration splashDuration = Duration(seconds: 4);
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 600);
  static const Duration longAnimation = Duration(milliseconds: 1000);

  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
}
