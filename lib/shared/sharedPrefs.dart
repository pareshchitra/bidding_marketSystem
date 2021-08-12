import 'package:shared_preferences/shared_preferences.dart';

const String keyAdminId = "admin_id";
const String keyPhoneNo = "PhoneNo";
const String keyRegisterState = "RegisterState";

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
  String get phoneNo => _sharedPrefs.getString(keyPhoneNo) ?? "";
  int get registerState => _sharedPrefs.getInt(keyRegisterState) ?? "";

  set adminId(String value) {
    _sharedPrefs.setString(keyAdminId, value);
  }

  set phoneNo(String value) {
    _sharedPrefs.setString(keyPhoneNo, value);
  }

  set registerState(int value) {
    _sharedPrefs.setInt(keyRegisterState, value);
  }
}


