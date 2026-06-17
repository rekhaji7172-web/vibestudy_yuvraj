class AppConstants {
  static const String appName = 'VibeStudy';
  static const String version = '1.0.0';

  // SharedPreferences keys
  static const String keyUserName = 'user_name';
  static const String keyUserXP = 'user_xp';
  static const String keyStreak = 'streak_count';
  static const String keyLastStudyDate = 'last_study_date';
  static const String keyTotalFocusMinutes = 'total_focus_minutes';
  static const String keySubjects = 'subjects';
  static const String keyNotes = 'notes';
  static const String keyFlashcards = 'flashcards';
  static const String keyTasks = 'tasks';
  static const String keyLevel = 'user_level';
  static const String keyBadges = 'badges';
  static const String keyMindMaps = 'mind_maps';
  static const String keyOnboarded = 'onboarded';

  // XP system
  static const int xpPerFocusSession = 50;
  static const int xpPerNote = 20;
  static const int xpPerFlashcard = 10;
  static const int xpPerTask = 30;
  static const int xpPerStreak = 100;
  static const int xpPerLevel = 500;

  // Timer defaults
  static const int defaultFocusMinutes = 25;
  static const int defaultBreakMinutes = 5;
  static const int defaultLongBreakMinutes = 15;

  // Subject colors (hex strings)
  static const List<String> subjectColors = [
    '#6366F1',
    '#8B5CF6',
    '#EC4899',
    '#F43F5E',
    '#F97316',
    '#F59E0B',
    '#10B981',
    '#22D3EE',
    '#4F8EF7',
    '#A78BFA',
  ];

  // Motivational quotes
  static const List<String> quotes = [
    'Small steps every day add up to massive results.',
    'The secret of getting ahead is getting started.',
    'Focus on progress, not perfection.',
    'Your future self will thank you.',
    'Every expert was once a beginner.',
    'Study now, shine later.',
    'Discipline is choosing between what you want now and what you want most.',
    'The more you learn, the more you earn.',
    'Push yourself, because no one else is going to do it for you.',
    'Great things never come from comfort zones.',
  ];
}

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String timer = '/timer';
  static const String noteDetail = '/note-detail';
  static const String flashcardStudy = '/flashcard-study';
  static const String mindMapDetail = '/mindmap-detail';
}
