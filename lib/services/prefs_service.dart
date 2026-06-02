import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static final PrefsService _instance = PrefsService._internal();
  factory PrefsService() => _instance;
  PrefsService._internal();

  static const _langKey = 'language';
  static const _readKey = 'read_chapters';

  // Language: 'fil' o 'eng'
  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_langKey) ?? 'fil';
  }

  Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, lang);
  }

  // Track kung anong chapters na nabasa
  Future<Set<String>> getReadChapters() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_readKey) ?? [];
    return list.toSet();
  }

  Future<void> markChapterRead(String alamatId, int chapter) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_readKey) ?? [];
    final key = '${alamatId}_$chapter';
    if (!list.contains(key)) {
      list.add(key);
      await prefs.setStringList(_readKey, list);
    }
  }

  Future<bool> isChapterRead(String alamatId, int chapter) async {
    final read = await getReadChapters();
    return read.contains('${alamatId}_$chapter');
  }

  // ── Background music preference ──
  Future<bool> getMusicEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('music_enabled') ?? true;
  }

  Future<void> setMusicEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_enabled', value);
  }
}