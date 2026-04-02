import '../../domain/entities/app_settings.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';
import '../models/app_settings_model.dart';
import '../models/budget_model.dart';

/// Concrete implementation of [SettingsRepository].
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _localDataSource;

  const SettingsRepositoryImpl(this._localDataSource);

  @override
  Future<AppSettings> getSettings() async {
    final model = await _localDataSource.getSettings();
    return AppSettings(
      pinHash: model.pinHash,
      isPinSet: model.isPinSet,
      lastRecurringCheck: model.lastRecurringCheck,
    );
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    await _localDataSource.saveSettings(
      AppSettingsModel(
        pinHash: settings.pinHash,
        isPinSet: settings.isPinSet,
        lastRecurringCheck: settings.lastRecurringCheck,
      ),
    );
  }

  @override
  Future<void> updateLastRecurringCheck(DateTime value) async {
    await _localDataSource.updateLastRecurringCheck(value);
  }

  @override
  Future<Budget?> getBudget() async {
    final model = await _localDataSource.getBudget();
    if (model == null) return null;
    return Budget(monthlyLimit: model.monthlyLimit);
  }

  @override
  Future<void> saveBudget(Budget budget) async {
    await _localDataSource.saveBudget(
      BudgetModel(monthlyLimit: budget.monthlyLimit),
    );
  }

  @override
  Future<void> deleteBudget() async {
    await _localDataSource.clearBudget();
  }
}
