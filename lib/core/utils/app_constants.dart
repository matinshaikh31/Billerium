class AppConstants {
  // App Info
  static const String appName = 'Billing & Inventory';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String adminsCollection = 'admins';
  static const String productsCollection = 'products';
  static const String categoriesCollection = 'categories';
  static const String billsCollection = 'bills';
  static const String transactionsCollection = 'transactions';
  static const String stockHistoryCollection = 'stockHistory';

  // Shared Preferences Keys
  static const String isLoggedInKey = 'isLoggedIn';
  static const String userIdKey = 'userId';

  // Responsive Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Pagination
  static const int itemsPerPage = 20;

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy hh:mm a';
  static const String timeFormat = 'hh:mm a';

  // Payment Modes
  static const List<String> paymentModes = ['Cash', 'UPI', 'Card', 'Other'];

  // Bill Status
  static const String billStatusPaid = 'Paid';
  static const String billStatusPartiallyPaid = 'PartiallyPaid';
  static const String billStatusUnpaid = 'Unpaid';

  // Stock Change Reasons
  static const String stockReasonBilling = 'Billing';
  static const String stockReasonReturn = 'Return';
  static const String stockReasonAdjustment = 'Adjustment';
  static const String stockReasonDamage = 'Damage';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxProductNameLength = 100;
  static const int maxCategoryNameLength = 50;
}

