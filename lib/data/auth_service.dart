import 'package:hive/hive.dart';

class AuthService {
  static const _boxName = 'authBox';
  static const _keyLoggedIn = 'logged_in';

  static Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email == 'navin@test.com' && password == 'Navin@123') {
      var box = Hive.box(_boxName);
      await box.put(_keyLoggedIn, true);
      return true;
    }
    return false;
  }

  static Future<void> logout() async {
    var box = Hive.box(_boxName);
    await box.put(_keyLoggedIn, false);
  }

  static Future<bool> isLoggedIn() async {
    var box = Hive.box(_boxName);
    return box.get(_keyLoggedIn, defaultValue: false);
  }
}
