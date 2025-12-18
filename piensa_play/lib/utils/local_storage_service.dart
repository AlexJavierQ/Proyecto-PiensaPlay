import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userAvatarKey = 'user_avatar';
  static const String _isLoggedInKey = 'is_logged_in';

  // Guardar datos del usuario
  static Future<void> saveUserData({
    required String userId,
    required String userName,
    required String userAvatar,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userNameKey, userName);
    await prefs.setString(_userAvatarKey, userAvatar);
    await prefs.setBool(_isLoggedInKey, true);
  }

  // Verificar si hay usuario guardado
  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Obtener datos del usuario guardado
  static Future<Map<String, String>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

    if (!isLoggedIn) return null;

    final userId = prefs.getString(_userIdKey);
    final userName = prefs.getString(_userNameKey);
    final userAvatar = prefs.getString(_userAvatarKey);

    if (userId != null && userName != null && userAvatar != null) {
      return {'userId': userId, 'userName': userName, 'userAvatar': userAvatar};
    }
    return null;
  }

  // Cerrar sesión (limpiar datos)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userAvatarKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Limpiar todos los datos
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
