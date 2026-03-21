import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  String _endpoint = 'https://api.openai.com/v1';
  String _model = 'gpt-4';
  String _apiKey = '';
  bool _isDarkMode = true;

  String get endpoint => _endpoint;
  String get model => _model;
  String get apiKey => _apiKey;
  bool get isDarkMode => _isDarkMode;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _endpoint = prefs.getString('endpoint') ?? 'https://api.openai.com/v1';
    _model = prefs.getString('model') ?? 'gpt-4';
    _apiKey = prefs.getString('api_key') ?? '';
    _isDarkMode = prefs.getBool('dark_mode') ?? true;
    notifyListeners();
  }

  Future<void> setEndpoint(String value) async {
    _endpoint = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('endpoint', value);
    notifyListeners();
  }

  Future<void> setModel(String value) async {
    _model = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('model', value);
    notifyListeners();
  }

  Future<void> setApiKey(String value) async {
    _apiKey = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_key', value);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _endpoint = 'https://api.openai.com/v1';
    _model = 'gpt-4';
    _apiKey = '';
    _isDarkMode = true;
    notifyListeners();
  }
}
