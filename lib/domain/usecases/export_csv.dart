import '../entities/expense.dart';

/// Converts expenses into CSV text without filesystem coupling.
class ExportCsvUseCase {
  const ExportCsvUseCase();

  String call(
    List<Expense> expenses, {
    Map<String, String> categoryNamesById = const {},
  }) {
    final buffer = StringBuffer()
      ..writeln(
        'Title,Category_name,Date,Payment method,Amount,Type,Recurring,Recurring_type',
      );

    for (final expense in expenses) {
      buffer.writeln(
        [
          expense.title,
          categoryNamesById[expense.categoryId] ?? expense.categoryId,
          expense.date.toIso8601String(),
          expense.paymentMethod.name,
          expense.amount.toStringAsFixed(2),
          expense.type.name,
          expense.isRecurring ? 'Yes' : 'No',
          expense.recurringType.name,
        ].map(_escape).join(','),
      );
    }

    return buffer.toString();
  }

  String _escape(Object? value) {
    final raw = '$value';
    final escaped = raw.replaceAll('"', '""');
    return '"$escaped"';
  }
}
