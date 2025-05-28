import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static final PreferencesManager _instance = PreferencesManager._internal();
  late SharedPreferences _prefs;

  factory PreferencesManager() {
    return _instance;
  }

  PreferencesManager._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // String operations
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  // Int operations
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  // Double operations
  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  // Bool operations
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  // Object operations
  Future<bool> setObject(String key, Map<String, dynamic> value) async {
    return await _prefs.setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? getObject(String key) {
    final String? jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  // List operations
  Future<bool> setList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  List<String>? getList(String key) {
    return _prefs.getStringList(key);
  }

  // Object list operations
  Future<bool> setObjectList(String key, List<Map<String, dynamic>> value) async {
    final List<String> jsonStringList = value.map((item) => jsonEncode(item)).toList();
    return await _prefs.setStringList(key, jsonStringList);
  }

  List<Map<String, dynamic>>? getObjectList(String key) {
    final List<String>? jsonStringList = _prefs.getStringList(key);
    if (jsonStringList == null) return null;
    return jsonStringList.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
  }

  // Remove and clear operations
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  Future<bool> clear() async {
    return await _prefs.clear();
  }

  // Check if key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  // Get all keys
  Set<String> getKeys() {
    return _prefs.getKeys();
  }

  // App specific methods
  static const String _firstTimeKey = 'first_time';

  Future<bool> isFirstTime() async {
    return _prefs.getBool(_firstTimeKey) ?? true;
  }

  Future<bool> setFirstTime(bool value) async {
    return await _prefs.setBool(_firstTimeKey, value);
  }
}
