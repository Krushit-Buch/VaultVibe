import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/failures.dart';
import '../models/app_settings_model.dart';
import '../models/budget_model.dart';

abstract class SettingsLocalDataSource {
  Future<AppSettingsModel> getSettings();
  Future<void> saveSettings(AppSettingsModel settings);
  Future<void> updateLastRecurringCheck(DateTime value);
  Future<BudgetModel?> getBudget();
  Future<void> saveBudget(BudgetModel budget);
  Future<void> clearBudget();
}

class HiveSettingsLocalDataSource implements SettingsLocalDataSource {
  Box<AppSettingsModel> get _settingsBox =>
      Hive.box<AppSettingsModel>(AppConstants.settingsBoxName);

  Box<BudgetModel> get _budgetBox =>
      Hive.box<BudgetModel>(AppConstants.budgetBoxName);

  @override
  Future<AppSettingsModel> getSettings() async {
    try {
      return _settingsBox.get(
            AppConstants.appSettingsKey,
            defaultValue: AppSettingsModel(isPinSet: false),
          ) ??
          AppSettingsModel(isPinSet: false);
    } catch (e) {
      throw LocalFailure('Failed to fetch app settings: $e');
    }
  }

  @override
  Future<void> saveSettings(AppSettingsModel settings) async {
    try {
      await _settingsBox.put(AppConstants.appSettingsKey, settings);
    } catch (e) {
      throw LocalFailure('Failed to save app settings: $e');
    }
  }

  @override
  Future<void> updateLastRecurringCheck(DateTime value) async {
    try {
      final current = await getSettings();
      await saveSettings(current.copyWith(lastRecurringCheck: value));
    } catch (e) {
      throw LocalFailure('Failed to update recurring check time: $e');
    }
  }

  @override
  Future<BudgetModel?> getBudget() async {
    try {
      return _budgetBox.get(AppConstants.monthlyBudgetKey);
    } catch (e) {
      throw LocalFailure('Failed to fetch budget: $e');
    }
  }

  @override
  Future<void> saveBudget(BudgetModel budget) async {
    try {
      await _budgetBox.put(AppConstants.monthlyBudgetKey, budget);
    } catch (e) {
      throw LocalFailure('Failed to save budget: $e');
    }
  }

  @override
  Future<void> clearBudget() async {
    try {
      await _budgetBox.delete(AppConstants.monthlyBudgetKey);
    } catch (e) {
      throw LocalFailure('Failed to delete budget: $e');
    }
  }
}
