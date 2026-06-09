import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper around [FlutterSecureStorage] for auth secrets.
class SecureStorage {
  SecureStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> writeToken(String value) =>
      _storage.write(key: _tokenKey, value: value);

  Future<void> deleteToken() => _storage.delete(key: _tokenKey);
}
