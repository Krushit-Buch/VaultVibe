import '../entities/expense.dart';

/// Converts expenses into CSV text without filesystem coupling.
class ExportCsvUseCase {
  const ExportCsvUseCase();

  String call(List<Expense> expenses) {
    final buffer = StringBuffer()
      ..writeln(
        'id,title,amount,categoryId,date,type,paymentMethod,isRecurring,recurringType,lastGeneratedDate,splitCount,createdAt',
      );

    for (final expense in expenses) {
      buffer.writeln(
        [
          expense.id,
          expense.title,
          expense.amount.toStringAsFixed(2),
          expense.categoryId,
          expense.date.toIso8601String(),
          expense.type.name,
          expense.paymentMethod.name,
          expense.isRecurring,
          expense.recurringType.name,
          expense.lastGeneratedDate?.toIso8601String() ?? '',
          expense.splitCount,
          expense.createdAt.toIso8601String(),
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
