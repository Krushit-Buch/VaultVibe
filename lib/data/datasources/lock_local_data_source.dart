import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/failures.dart';

abstract class LockLocalDataSource {
  Future<String?> readPinHash();
  Future<void> writePinHash(String rawPin);
}

class SecureLockLocalDataSource implements LockLocalDataSource {
  static const _storage = FlutterSecureStorage();

  @override
  Future<String?> readPinHash() async {
    try {
      return await _storage.read(key: AppConstants.pinKey);
    } catch (error) {
      throw LocalFailure('Unable to read secure PIN storage: $error');
    }
  }

  @override
  Future<void> writePinHash(String rawPin) async {
    try {
      final hash = sha256.convert(utf8.encode(rawPin)).toString();
      await _storage.write(key: AppConstants.pinKey, value: hash);
    } catch (error) {
      throw LocalFailure('Unable to save secure PIN storage: $error');
    }
  }
}
