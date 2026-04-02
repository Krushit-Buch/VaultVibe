import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/utils/failures.dart';
import 'dependency_providers.dart';

final exportControllerProvider =
    AsyncNotifierProvider<ExportController, String?>(ExportController.new);

class ExportController extends AsyncNotifier<String?> {
  static const _exportDirectoryName = 'vaultvibe_exports';
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
      final categories = await ref.read(getAllCategoriesUseCaseProvider).call();
      final categoryNamesById = {
        for (final category in categories) category.id: category.name,
      };
      final csv = ref.read(exportCsvUseCaseProvider).call(
            expenses,
            categoryNamesById: categoryNamesById,
          );
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
      await _ensureExportPermissions();
      final root = await _resolveExportRootDirectory();
      final exportsDir = Directory('${root.path}/$_exportDirectoryName');
      if (!await exportsDir.exists()) {
        await exportsDir.create(recursive: true);
      }
      return exportsDir;
    } on Failure {
      rethrow;
    } on FileSystemException catch (error) {
      throw LocalFailure(
        'Unable to access export storage. Please allow storage access and try again. ${error.message}',
      );
    } catch (_) {
      throw const LocalFailure(
        'Unable to access export storage on this device.',
      );
    }
  }

  Future<Directory> _resolveExportRootDirectory() async {
    if (Platform.isAndroid) {
      final publicDownloadsDirectory =
          await _resolveAndroidDownloadsDirectory();
      if (publicDownloadsDirectory != null) {
        return publicDownloadsDirectory;
      }

      final directories = await getExternalStorageDirectories(
        type: StorageDirectory.downloads,
      );
      final downloadsDirectory = directories != null && directories.isNotEmpty
          ? directories.first
          : null;
      if (downloadsDirectory != null) {
        return downloadsDirectory;
      }

      final externalDirectory = await getExternalStorageDirectory();
      if (externalDirectory != null) {
        return externalDirectory;
      }
    }

    return getApplicationDocumentsDirectory();
  }

  Future<void> _ensureExportPermissions() async {
    if (!Platform.isAndroid) {
      return;
    }

    final manageStorageStatus = await Permission.manageExternalStorage.status;
    if (manageStorageStatus.isGranted) {
      return;
    }

    final storageStatus = await Permission.storage.status;
    if (storageStatus.isGranted) {
      return;
    }

    final requestedManageStorage =
        await Permission.manageExternalStorage.request();
    if (requestedManageStorage.isGranted) {
      return;
    }

    final requestedStorage = await Permission.storage.request();
    if (requestedStorage.isGranted) {
      return;
    }

    if (requestedManageStorage.isPermanentlyDenied ||
        requestedStorage.isPermanentlyDenied) {
      throw const LocalFailure(
        'Storage permission is permanently denied. Please enable file access in Settings to export CSV files.',
      );
    }

    throw const LocalFailure(
      'Storage permission is required to save CSV files to Downloads.',
    );
  }

  Future<Directory?> _resolveAndroidDownloadsDirectory() async {
    const fallbackPaths = <String>[
      '/storage/emulated/0/Download',
      '/sdcard/Download',
    ];

    for (final path in fallbackPaths) {
      final directory = Directory(path);
      if (await directory.exists()) {
        return directory;
      }
    }

    final scopedDirectories = await getExternalStorageDirectories(
      type: StorageDirectory.downloads,
    );
    final scopedDirectory =
        scopedDirectories != null && scopedDirectories.isNotEmpty
            ? scopedDirectories.first
            : null;
    if (scopedDirectory == null) {
      return null;
    }

    final publicPath = _derivePublicDownloadsPath(scopedDirectory.path);
    if (publicPath == null) {
      return null;
    }

    final publicDirectory = Directory(publicPath);
    if (await publicDirectory.exists()) {
      return publicDirectory;
    }

    return null;
  }

  String? _derivePublicDownloadsPath(String scopedPath) {
    final androidFolderIndex = scopedPath.indexOf('/Android/');
    if (androidFolderIndex == -1) {
      return null;
    }

    final storageRoot = scopedPath.substring(0, androidFolderIndex);
    if (storageRoot.isEmpty) {
      return null;
    }

    return '$storageRoot/Download';
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
