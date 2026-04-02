import '../constants/app_colors.dart';
import 'transaction_type.dart';

/// Default expense categories.
enum CategoryType {
  food,
  transport,
  shopping,
  entertainment,
  health,
  education,
  utilities,
  rent,
  salary,
  investment,
  other;

  String get label {
    switch (this) {
      case CategoryType.food:
        return 'Food & Dining';
      case CategoryType.transport:
        return 'Transport';
      case CategoryType.shopping:
        return 'Shopping';
      case CategoryType.entertainment:
        return 'Entertainment';
      case CategoryType.health:
        return 'Health';
      case CategoryType.education:
        return 'Education';
      case CategoryType.utilities:
        return 'Utilities';
      case CategoryType.rent:
        return 'Rent';
      case CategoryType.salary:
        return 'Salary';
      case CategoryType.investment:
        return 'Investment';
      case CategoryType.other:
        return 'Other';
    }
  }

  TransactionType get transactionType {
    switch (this) {
      case CategoryType.salary:
      case CategoryType.investment:
        return TransactionType.income;
      case CategoryType.other:
        return TransactionType.expense;
      default:
        return TransactionType.expense;
    }
  }

  bool get supportsBoth => this == CategoryType.other;

  bool supports(TransactionType type) {
    return supportsBoth || transactionType == type;
  }

  int get colorIndex => index % AppColors.categoryColors.length;

  static CategoryType? fromLabel(String label) {
    for (final value in CategoryType.values) {
      if (value.label.toLowerCase() == label.trim().toLowerCase()) {
        return value;
      }
    }
    return null;
  }

  String get icon {
    switch (this) {
      case CategoryType.food:
        return '🍔';
      case CategoryType.transport:
        return '🚗';
      case CategoryType.shopping:
        return '🛍️';
      case CategoryType.entertainment:
        return '🎬';
      case CategoryType.health:
        return '🏥';
      case CategoryType.education:
        return '📚';
      case CategoryType.utilities:
        return '💡';
      case CategoryType.rent:
        return '🏠';
      case CategoryType.salary:
        return '💼';
      case CategoryType.investment:
        return '📈';
      case CategoryType.other:
        return '📌';
    }
  }
}
