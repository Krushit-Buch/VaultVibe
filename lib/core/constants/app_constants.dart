/// App-wide constants used across the entire application.
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Expense Tracker';
  static const String appVersion = '1.0.0';

  // Hive Box Names
  static const String expenseBoxName = 'expenses';
  static const String categoryBoxName = 'categories';
  static const String settingsBoxName = 'settings';
  static const String budgetBoxName = 'budgets';
  static const String appSettingsKey = 'app_settings';
  static const String monthlyBudgetKey = 'monthly_budget';

  // Hive Type IDs
  static const int expenseModelTypeId = 0;
  static const int categoryModelTypeId = 1;
  static const int budgetModelTypeId = 2;
  static const int appSettingsModelTypeId = 3;
  static const int paymentMethodTypeId = 4;
  static const int recurringTypeTypeId = 5;

  // Secure Storage Keys
  static const String currencyKey = 'currency';
  static const String pinKey = 'pin';
  static const String biometricEnabledKey = 'biometric_enabled';

  // Default Values
  static const String defaultCurrency = 'USD';
  static const String defaultCurrencySymbol = '\$';
  static const int maxRecentTransactions = 50;

  // Pagination
  static const int pageSize = 20;

  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String monthYearFormat = 'MMMM yyyy';
  static const String shortDateFormat = 'dd/MM/yy';
  static const String timeFormat = 'hh:mm a';
}
