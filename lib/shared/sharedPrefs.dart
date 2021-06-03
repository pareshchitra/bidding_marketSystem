import 'package:shared_preferences/shared_preferences.dart';

const String keyAdminId = "admin_id";

class SharedPrefs {
  static SharedPreferences _sharedPrefs;

  factory SharedPrefs() => SharedPrefs._internal();

  SharedPrefs._internal();

  Future<void> init() async {
    if (_sharedPrefs == null) {
      _sharedPrefs = await SharedPreferences.getInstance();
    }
  }

  String get adminId => _sharedPrefs.getString(keyAdminId) ?? "";

  set adminId(String value) {
    _sharedPrefs.setString(keyAdminId, value);
  }
}


