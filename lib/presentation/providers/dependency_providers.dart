import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/datasources/category_local_data_source.dart';
import '../../data/datasources/expense_local_data_source.dart';
import '../../data/datasources/lock_local_data_source.dart';
import '../../data/datasources/settings_local_data_source.dart';
import '../../data/repositories/app_lock_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/app_lock_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/export_csv.dart';
import '../../domain/usecases/generate_recurring_expenses.dart';
import '../../domain/usecases/get_all_categories.dart';
import '../../domain/usecases/get_all_expenses.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/get_expenses_by_filter.dart';
import '../../domain/usecases/get_monthly_summary.dart';
import '../../domain/usecases/has_pin.dart';
import '../../domain/usecases/manage_categories.dart';
import '../../domain/usecases/set_budget.dart';
import '../../domain/usecases/setup_pin.dart';
import '../../domain/usecases/update_expense.dart';
import '../../domain/usecases/verify_pin.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────

final expenseLocalDataSourceProvider = Provider<ExpenseLocalDataSource>((ref) {
  return HiveExpenseLocalDataSource();
});

final categoryLocalDataSourceProvider =
    Provider<CategoryLocalDataSource>((ref) {
  return HiveCategoryLocalDataSource();
});

final settingsLocalDataSourceProvider =
    Provider<SettingsLocalDataSource>((ref) {
  return HiveSettingsLocalDataSource();
});

final lockLocalDataSourceProvider = Provider<LockLocalDataSource>((ref) {
  return SecureLockLocalDataSource();
});

final uuidProvider = Provider<Uuid>((ref) => const Uuid());

// ── Repositories ──────────────────────────────────────────────────────────────

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(ref.watch(expenseLocalDataSourceProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(categoryLocalDataSourceProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(settingsLocalDataSourceProvider));
});

final appLockRepositoryProvider = Provider<AppLockRepository>((ref) {
  return AppLockRepositoryImpl(ref.watch(lockLocalDataSourceProvider));
});

// ── Use Cases ─────────────────────────────────────────────────────────────────

final getAllExpensesUseCaseProvider = Provider<GetAllExpensesUseCase>((ref) {
  return GetAllExpensesUseCase(ref.watch(expenseRepositoryProvider));
});

final getExpensesByFilterUseCaseProvider =
    Provider<GetExpensesByFilterUseCase>((ref) {
  return GetExpensesByFilterUseCase(ref.watch(expenseRepositoryProvider));
});

final getExpensesUseCaseProvider = Provider<GetExpensesUseCase>((ref) {
  return GetExpensesUseCase(ref.watch(expenseRepositoryProvider));
});

final addExpenseUseCaseProvider = Provider<AddExpenseUseCase>((ref) {
  return AddExpenseUseCase(ref.watch(expenseRepositoryProvider));
});

final updateExpenseUseCaseProvider = Provider<UpdateExpenseUseCase>((ref) {
  return UpdateExpenseUseCase(ref.watch(expenseRepositoryProvider));
});

final deleteExpenseUseCaseProvider = Provider<DeleteExpenseUseCase>((ref) {
  return DeleteExpenseUseCase(ref.watch(expenseRepositoryProvider));
});

final getAllCategoriesUseCaseProvider =
    Provider<GetAllCategoriesUseCase>((ref) {
  return GetAllCategoriesUseCase(ref.watch(categoryRepositoryProvider));
});

final manageCategoriesUseCaseProvider =
    Provider<ManageCategoriesUseCase>((ref) {
  return ManageCategoriesUseCase(ref.watch(categoryRepositoryProvider));
});

final setBudgetUseCaseProvider = Provider<SetBudgetUseCase>((ref) {
  return SetBudgetUseCase(ref.watch(settingsRepositoryProvider));
});

final getMonthlySummaryUseCaseProvider =
    Provider<GetMonthlySummaryUseCase>((ref) {
  return GetMonthlySummaryUseCase(
    ref.watch(expenseRepositoryProvider),
    ref.watch(settingsRepositoryProvider),
  );
});

final generateRecurringExpensesUseCaseProvider =
    Provider<GenerateRecurringExpensesUseCase>((ref) {
  return GenerateRecurringExpensesUseCase(
    ref.watch(expenseRepositoryProvider),
    ref.watch(settingsRepositoryProvider),
  );
});

final exportCsvUseCaseProvider = Provider<ExportCsvUseCase>((ref) {
  return const ExportCsvUseCase();
});

final hasPinUseCaseProvider = Provider<HasPinUseCase>((ref) {
  return HasPinUseCase(ref.watch(appLockRepositoryProvider));
});

final setupPinUseCaseProvider = Provider<SetupPinUseCase>((ref) {
  return SetupPinUseCase(ref.watch(appLockRepositoryProvider));
});

final verifyPinUseCaseProvider = Provider<VerifyPinUseCase>((ref) {
  return VerifyPinUseCase(ref.watch(appLockRepositoryProvider));
});
