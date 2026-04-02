import '../entities/app_settings.dart';
import '../entities/budget.dart';

/// Abstract contract for settings and budget operations.
abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> saveSettings(AppSettings settings);
  Future<void> updateLastRecurringCheck(DateTime value);
  Future<Budget?> getBudget();
  Future<void> saveBudget(Budget budget);
  Future<void> deleteBudget();
}
