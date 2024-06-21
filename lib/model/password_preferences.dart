import 'package:shared_preferences/shared_preferences.dart';

class PasswordSharedPreferences {
  static late SharedPreferences _preferences;

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Set<String> getAllKeys() {
    Set<String> keys = _preferences.getKeys();
    return keys;
  }

  static dynamic getKeyValue(String key) {
    dynamic value = _preferences.get(key);
    return value;
  }

  static removeKey(String key) {
    _preferences.remove(key);
  }

  static Future setRootPassword(String password) async {
    await _preferences.setString("rootPassword", password);
  }

  static String? getRootPassword() {
    return _preferences.getString("rootPassword");
  }

  static Future setHasRegistered(bool hasRegistered) async {
    await _preferences.setBool("hasRegistered", hasRegistered);
  }

  static bool? getHasRegistered() {
    return _preferences.getBool("hasRegistered");
  }

  static Future setServicesList(List<String> nameOfServices) async {
    await _preferences.setStringList("services", nameOfServices);
  }

  static List<String>? getServicesList() {
    return _preferences.getStringList("services");
  }

  static Future setUsername(String nameOfService, String username) async {
    _preferences.setString(nameOfService + "Username", username);
  }

  static String? getUsername(String nameOfService) {
    return _preferences.getString(nameOfService + "Username");
  }

  static Future setPassword(String nameOfService, String password) async {
    _preferences.setString(nameOfService + "Password", password);
  }

  static String? getPassword(String nameOfService) {
    return _preferences.getString(nameOfService + "Password");
  }

  static Future setWebsite(String nameOfService, String website) async {
    _preferences.setString(nameOfService + "Website", website);
  }

  static String? getWebsite(String nameOfService) {
    return _preferences.getString(nameOfService + "Website");
  }

  static Future setEmail(String nameOfService, String email) async {
    _preferences.setString(nameOfService + "Email", email);
  }

  static String? getEmail(String nameOfService) {
    return _preferences.getString(nameOfService + "Email");
  }

  static Future setAdditionalInfo(String nameOfService, String additionalInfo) async {
    _preferences.setString(nameOfService + "AdditionalInfo", additionalInfo);
  }

  static String? getAdditionalInfo(String nameOfService) {
    return _preferences.getString(nameOfService + "AdditionalInfo");
  }

  static Future importKeysFromJson(Map<String, dynamic> jsonMap) async {
    for(String key in jsonMap.keys) {
      dynamic value = jsonMap[key];
      if(value is String) {
        _preferences.setString(key, value);
      } else if(value is bool) {
        _preferences.setBool(key, value);
      } else if (value is List<dynamic> && value.isNotEmpty && value.every((e) => e is String)) {
        List<String> stringList = value.map((e) => e.toString()).toList();
        _preferences.setStringList(key, stringList);
      } else if(value is int) {
        _preferences.setInt(key, value);
      } else if(value is double) {
        _preferences.setDouble(key, value);
      }
    }
  }
  static clearSharedPreferences() async {
    await _preferences.clear();
  }
}
