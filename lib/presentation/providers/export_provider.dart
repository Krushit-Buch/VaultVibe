import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/utils/failures.dart';
import 'dependency_providers.dart';

final exportControllerProvider =
    AsyncNotifierProvider<ExportController, String?>(ExportController.new);

class ExportController extends AsyncNotifier<String?> {
  static const _exportDirectoryName = 'exports';
  static const _retentionDays = 15;

  @override
  Future<String?> build() async => null;

  Future<String> exportAllExpenses() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final expenses = await ref.read(getAllExpensesUseCaseProvider).call();
      if (expenses.isEmpty) {
        throw const ValidationFailure('There are no expenses to export.');
      }
      final csv = ref.read(exportCsvUseCaseProvider).call(expenses);
      final exportsDir = await _ensureExportsDirectory();

      await _cleanupOldExportsBestEffort(exportsDir);

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${exportsDir.path}/expenses_$timestamp.csv');
      try {
        await file.writeAsString(csv, flush: true);
      } on FileSystemException catch (error) {
        throw LocalFailure('Unable to save CSV export: ${error.message}');
      } catch (error) {
        throw LocalFailure('Unable to save CSV export: $error');
      }
      return file.path;
    });

    final result = state.valueOrNull;
    if (result == null) {
      throw const UnexpectedFailure('Export failed unexpectedly.');
    }
    return result;
  }

  Future<Directory> _ensureExportsDirectory() async {
    try {
      final root = await getApplicationDocumentsDirectory();
      final exportsDir = Directory('${root.path}/$_exportDirectoryName');
      if (!await exportsDir.exists()) {
        await exportsDir.create(recursive: true);
      }
      return exportsDir;
    } on FileSystemException catch (error) {
      throw LocalFailure('Unable to access local storage: ${error.message}');
    } catch (_) {
      throw const LocalFailure('Unable to access local storage for export.');
    }
  }

  Future<void> _cleanupOldExportsBestEffort(Directory exportsDir) async {
    final cutoff =
        DateTime.now().subtract(const Duration(days: _retentionDays));

    try {
      await for (final entity in exportsDir.list()) {
        if (entity is! File || !entity.path.endsWith('.csv')) {
          continue;
        }

        final stat = await entity.stat();
        final modifiedAt = stat.modified;
        if (modifiedAt.isBefore(cutoff)) {
          try {
            await entity.delete();
          } on FileSystemException {
            // Best effort cleanup: keep export flow working even if one file fails.
          }
        }
      }
    } on FileSystemException {
      // Best effort cleanup only.
    } catch (_) {
      // Best effort cleanup only.
    }
  }
}
