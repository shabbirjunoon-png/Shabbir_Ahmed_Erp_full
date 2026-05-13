import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  static final LocaleService _instance = LocaleService._();
  static LocaleService get instance => _instance;
  LocaleService._();

  bool _isUrdu = false;
  bool get isUrdu => _isUrdu;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isUrdu = prefs.getBool('lang_urdu') ?? false;
    notifyListeners();
  }

  Future<void> toggle() async {
    _isUrdu = !_isUrdu;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lang_urdu', _isUrdu);
    notifyListeners();
  }

  String t(String en, String ur) => _isUrdu ? ur : en;
}
