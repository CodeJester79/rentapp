class AppRoutes {
  AppRoutes._();

  // Authentication Routes
  static const String splash = '/';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';

  // Main Navigation Routes
  static const String home = '/home';
  static const String properties = '/properties';
  static const String favorites = '/favorites';
  static const String activity = '/activity';
  static const String profile = '/profile';

  // Property Routes
  static const String propertyDetail = '/property-detail';
  static const String addProperty = '/add-property';
  static const String editProperty = '/edit-property';
  static const String propertyPhotos = '/property-photos';
  static const String propertyMap = '/property-map';

  // User Management Routes (Admin only)
  static const String userList = '/users';
  static const String userDetail = '/user-detail';
  static const String createUser = '/create-user';

  // Agent Routes
  static const String agentList = '/agents';
  static const String agentDetail = '/agent-detail';
  static const String agentProfile = '/agent-profile';

  // Search and Filter Routes
  static const String search = '/search';
  static const String advancedSearch = '/advanced-search';
  static const String savedSearches = '/saved-searches';

  // Communication Routes
  static const String inquiries = '/inquiries';
  static const String comments = '/comments';
  static const String notifications = '/notifications';

  // Settings Routes
  static const String settings = '/settings';
  static const String accountSettings = '/account-settings';
  static const String privacySettings = '/privacy-settings';
  static const String notificationSettings = '/notification-settings';
  static const String helpSupport = '/help-support';

  // Get all routes as a list for navigation
  static List<String> get allRoutes => [
        splash,
        signIn,
        signUp,
        forgotPassword,
        home,
        properties,
        favorites,
        activity,
        profile,
        propertyDetail,
        addProperty,
        editProperty,
        propertyPhotos,
        propertyMap,
        userList,
        userDetail,
        createUser,
        agentList,
        agentDetail,
        agentProfile,
        search,
        advancedSearch,
        savedSearches,
        inquiries,
        comments,
        notifications,
        settings,
        accountSettings,
        privacySettings,
        notificationSettings,
        helpSupport,
      ];
}