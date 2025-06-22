class AppConstants {
  AppConstants._();

  // App Information
  static const String appName = 'RentApp';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'http://platform.rentem.click';
  static const String apiVersion = 'v1';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  static const String notificationsKey = 'notifications_enabled';
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Image Configuration
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  static const int imageQuality = 85;
  
  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  
  // UI Measurements
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  
  // Property Types
  static const List<String> propertyTypes = [
    'apartment',
    'house',
    'studio',
    'condo',
    'townhouse',
    'loft',
    'duplex'
  ];
  
  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleBroker = 'broker';
  static const String roleCustomer = 'customer';
  
  // Property Status
  static const String statusActive = 'active';
  static const String statusInactive = 'inactive';
  static const String statusRented = 'rented';
  static const String statusPending = 'pending';
  
  // Search and Filter
  static const double minPrice = 0.0;
  static const double maxPrice = 50000.0;
  static const int minBedrooms = 0;
  static const int maxBedrooms = 10;
  static const int minBathrooms = 0;
  static const int maxBathrooms = 10;
  
  // Map Configuration
  static const double defaultLatitude = 40.7128;
  static const double defaultLongitude = -74.0060;
  static const double defaultZoom = 12.0;
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  
  // Error Messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'Please check your internet connection and try again.';
  static const String unauthorizedErrorMessage = 'You are not authorized to perform this action.';
  static const String notFoundErrorMessage = 'The requested resource was not found.';
  static const String validationErrorMessage = 'Please check your input and try again.';
  
  // Success Messages
  static const String propertyCreatedMessage = 'Property created successfully!';
  static const String propertyUpdatedMessage = 'Property updated successfully!';
  static const String propertyDeletedMessage = 'Property deleted successfully!';
  static const String loginSuccessMessage = 'Welcome back!';
  static const String registrationSuccessMessage = 'Account created successfully!';
  static const String logoutSuccessMessage = 'You have been logged out successfully.';
  
  // Empty State Messages
  static const String noPropertiesMessage = 'No properties found';
  static const String noFavoritesMessage = 'You haven\'t added any favorites yet';
  static const String noSearchResultsMessage = 'No results found for your search';
  static const String noCommentsMessage = 'No comments yet';
  static const String noInquiriesMessage = 'No inquiries yet';
  
  // Feature Flags
  static const bool enableDarkMode = true;
  static const bool enableNotifications = true;
  static const bool enableMapView = true;
  static const bool enableOfflineMode = false;
}

// App Strings for Localization
class AppStrings {
  AppStrings._();
  
  // Navigation
  static const String home = 'Home';
  static const String properties = 'Properties';
  static const String favorites = 'Favorites';
  static const String activity = 'Activity';
  static const String profile = 'Profile';
  static const String settings = 'Settings';
  
  // Property Related
  static const String addProperty = 'Add Property';
  static const String editProperty = 'Edit Property';
  static const String deleteProperty = 'Delete Property';
  static const String propertyDetails = 'Property Details';
  static const String searchProperties = 'Search Properties';
  static const String filterProperties = 'Filter Properties';
  static const String sortBy = 'Sort By';
  static const String priceRange = 'Price Range';
  static const String bedrooms = 'Bedrooms';
  static const String bathrooms = 'Bathrooms';
  static const String squareFeet = 'Square Feet';
  static const String propertyType = 'Property Type';
  static const String location = 'Location';
  static const String amenities = 'Amenities';
  static const String description = 'Description';
  static const String contactAgent = 'Contact Agent';
  static const String scheduleViewing = 'Schedule Viewing';
  static const String addToFavorites = 'Add to Favorites';
  static const String removeFromFavorites = 'Remove from Favorites';
  
  // Authentication
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String signOut = 'Sign Out';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String firstName = 'First Name';
  static const String lastName = 'Last Name';
  static const String phoneNumber = 'Phone Number';
  
  // Common Actions
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String share = 'Share';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sort = 'Sort';
  static const String refresh = 'Refresh';
  static const String loadMore = 'Load More';
  static const String retry = 'Retry';
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String apply = 'Apply';
  static const String clear = 'Clear';
  static const String close = 'Close';
  
  // Status and States
  static const String loading = 'Loading...';
  static const String noData = 'No data available';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String warning = 'Warning';
  static const String info = 'Info';
  static const String active = 'Active';
  static const String inactive = 'Inactive';
  static const String pending = 'Pending';
  static const String available = 'Available';
  static const String rented = 'Rented';
}