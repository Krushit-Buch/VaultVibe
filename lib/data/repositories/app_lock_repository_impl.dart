import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../data/datasources/lock_local_data_source.dart';
import '../../domain/repositories/app_lock_repository.dart';

class AppLockRepositoryImpl implements AppLockRepository {
  final LockLocalDataSource _localDataSource;

  const AppLockRepositoryImpl(this._localDataSource);

  @override
  Future<bool> hasPin() async {
    final hash = await _localDataSource.readPinHash();
    return hash != null && hash.isNotEmpty;
  }

  @override
  Future<void> setPin(String pin) {
    return _localDataSource.writePinHash(pin);
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final storedHash = await _localDataSource.readPinHash();
    if (storedHash == null || storedHash.isEmpty) {
      return false;
    }
    final incomingHash = sha256.convert(utf8.encode(pin)).toString();
    return incomingHash == storedHash;
  }
}
