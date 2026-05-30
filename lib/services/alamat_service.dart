import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/alamat_model.dart';

class AlamatService {
  static final AlamatService _instance = AlamatService._internal();
  factory AlamatService() => _instance;
  AlamatService._internal();

  List<AlamatModel> _allAlamat = [];
  bool _loaded = false;

  // ── In-memory cache: id → local file path (or null if not found) ──
  static final Map<String, String?> _coverCache = {};

  /// Public read-only access to the cover cache for synchronous lookups.
  static Map<String, String?> get coverCache => _coverCache;

  // ── Cached directory paths so we don't call getApplicationDocumentsDirectory() repeatedly ──
  static Directory? _storiesDir;
  static Directory? _coversDir;

  static const String _baseUrl =
      'https://raw.githubusercontent.com/Gyerii/alamat-stories/main/stories';
  static const String _coversUrl =
      'https://raw.githubusercontent.com/Gyerii/alamat-stories/main/covers';

  static const List<Map<String, String>> _stories = [
    {'id': 'alamat_ng_pinya',      'folder': 'pambansa'},
    {'id': 'si_bathala',           'folder': 'pambansa'},
    {'id': 'alamat_ng_sampaguita', 'folder': 'pambansa'},
    {'id': 'ang_tikbalang',        'folder': 'pambansa'},
    {'id': 'daragang_magayon',     'folder': 'luzon'},
    {'id': 'si_lam_ang',           'folder': 'luzon'},
    {'id': 'alamat_ng_baguio',     'folder': 'luzon'},
    {'id': 'alamat_ng_taal',       'folder': 'luzon'},
    {'id': 'lapu_lapu',            'folder': 'visayas'},
    {'id': 'chocolate_hills',      'folder': 'visayas'},
    {'id': 'bantay_araw',          'folder': 'visayas'},
    {'id': 'mount_apo',            'folder': 'mindanao'},
    {'id': 'si_diwata',            'folder': 'mindanao'},
    {'id': 'si_rajah_muda',        'folder': 'mindanao'},
    {'id': 'underground_river',    'folder': 'palawan'},
    {'id': 'el_nido',              'folder': 'palawan'},
    {'id': 'si_manuyog',           'folder': 'palawan'},
  ];

  Future<Directory> _getStoriesDir() async {
    if (_storiesDir != null) return _storiesDir!;
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/stories');
    if (!await dir.exists()) await dir.create(recursive: true);
    _storiesDir = dir;
    return dir;
  }

  Future<Directory> _getCoversDir() async {
    if (_coversDir != null) return _coversDir!;
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/covers');
    if (!await dir.exists()) await dir.create(recursive: true);
    _coversDir = dir;
    return dir;
  }

  Future<bool> areStoriesDownloaded() async {
    final dir = await _getStoriesDir();
    for (final s in _stories) {
      if (!await File('${dir.path}/${s['id']}.json').exists()) return false;
    }
    return true;
  }

  Future<bool> downloadAll({
    required Function(int current, int total, String name) onProgress,
    required Function(String error) onError,
  }) async {
    final dir = await _getStoriesDir();
    int current = 0;

    for (final s in _stories) {
      current++;
      final id = s['id']!;
      final folder = s['folder']!;
      onProgress(current, _stories.length, id.replaceAll('_', ' '));

      final file = File('${dir.path}/$id.json');
      if (await file.exists()) continue;

      try {
        final res = await http
            .get(Uri.parse('$_baseUrl/$folder/$id.json'))
            .timeout(const Duration(seconds: 15));

        if (res.statusCode == 200) {
          await file.writeAsString(res.body);
        } else {
          onError('Hindi ma-download: $id (${res.statusCode})');
          return false;
        }
      } catch (_) {
        onError('Walang internet. Subukan ulit.');
        return false;
      }
    }

    // Download covers
    final coversDir = await _getCoversDir();
    int coverIdx = 0;
    for (final s in _stories) {
      coverIdx++;
      onProgress(coverIdx, _stories.length, 'mga larawan...');
      final id = s['id']!;
      final file = File('${coversDir.path}/$id.png');
      if (await file.exists()) {
        // Already on disk — warm the cache immediately
        _coverCache[id] = file.path;
        continue;
      }
      try {
        final res = await http
            .get(Uri.parse('$_coversUrl/$id.png'))
            .timeout(const Duration(seconds: 30));
        if (res.statusCode == 200) {
          await file.writeAsBytes(res.bodyBytes);
          _coverCache[id] = file.path; // Cache after successful download
        } else {
          _coverCache[id] = null;
        }
      } catch (_) {
        _coverCache[id] = null;
      }
    }

    return true;
  }

  Future<List<AlamatModel>> loadAll() async {
    if (_loaded) return _allAlamat;
    final dir = await _getStoriesDir();

    for (final s in _stories) {
      try {
        final file = File('${dir.path}/${s['id']}.json');
        if (!await file.exists()) continue;
        final data = json.decode(await file.readAsString());
        _allAlamat.add(AlamatModel.fromJson(data));
      } catch (_) {}
    }

    _loaded = true;
    return _allAlamat;
  }

  /// Returns the local file path for a cover image.
  /// - First call: checks disk and stores result in [_coverCache]
  /// - Subsequent calls: returns instantly from cache — no disk I/O
  Future<String?> getLocalCover(String id) async {
    // Cache hit — return immediately, no async work needed
    if (_coverCache.containsKey(id)) return _coverCache[id];

    // Cache miss — check disk once and store result
    final dir = await _getCoversDir();
    final file = File('${dir.path}/$id.png');
    final path = await file.exists() ? file.path : null;
    _coverCache[id] = path; // Store even null so we never re-check
    return path;
  }

  /// Call this after a new cover is downloaded to update the cache.
  void setCoverCache(String id, String path) {
    _coverCache[id] = path;
  }

  /// Clears the cover cache (useful if covers are re-downloaded).
  void clearCoverCache() {
    _coverCache.clear();
    _storiesDir = null;
    _coversDir = null;
  }

  List<AlamatModel> filterByRegion(List<AlamatModel> list, String region) {
    if (region == 'lahat') return list;
    return list.where((a) => a.category == region).toList();
  }

  List<AlamatModel> search(List<AlamatModel> list, String query) {
    if (query.isEmpty) return list;
    final q = query.toLowerCase();
    return list
        .where((a) =>
            a.titleFil.toLowerCase().contains(q) ||
            a.titleEng.toLowerCase().contains(q) ||
            a.region.toLowerCase().contains(q))
        .toList();
  }
}