import 'package:get_storage/get_storage.dart';

class StorageService {
  StorageService({GetStorage? box}) : _box = box ?? GetStorage();

  final GetStorage _box;

  static const String loginRoleKey = 'login_role';
  static const String sessionTokenKey = 'session_token';
  static const String sessionExpiresAtKey = 'session_expires_at';
  static const String userNameKey = 'user_name';
  static const String userEmailKey = 'user_email';

  String? get loginRole => _box.read<String>(loginRoleKey);
  String? get sessionToken => _box.read<String>(sessionTokenKey);
  String? get sessionExpiresAt => _box.read<String>(sessionExpiresAtKey);

  Future<void> saveSession({
    required String role,
    required String token,
    required String expiresAt,
    required String userName,
    required String userEmail,
  }) async {
    await _box.write(loginRoleKey, role);
    await _box.write(sessionTokenKey, token);
    await _box.write(sessionExpiresAtKey, expiresAt);
    await _box.write(userNameKey, userName);
    await _box.write(userEmailKey, userEmail);
  }

  Future<void> clearSession() async {
    await _box.remove(loginRoleKey);
    await _box.remove(sessionTokenKey);
    await _box.remove(sessionExpiresAtKey);
    await _box.remove(userNameKey);
    await _box.remove(userEmailKey);
  }
}
