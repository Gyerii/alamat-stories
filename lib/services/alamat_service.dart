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

  static final Map<String, String?> _coverCache = {};
  static Map<String, String?> get coverCache => _coverCache;

  static final Map<String, String?> _musicCache = {};
  static Map<String, String?> get musicCache => _musicCache;

  static Directory? _storiesDir;
  static Directory? _coversDir;
  static Directory? _musicDir;

  static const String _baseUrl =
      'https://raw.githubusercontent.com/Gyerii/alamat-stories/main/stories';
  static const String _coversUrl =
      'https://raw.githubusercontent.com/Gyerii/alamat-stories/main/covers';

  /// Music files stored in: /music/ folder in your GitHub repo
  /// Filenames: ambient_likas.mp3, ambient_bayani.mp3, ambient_nilalang.mp3,
  ///            ambient_diyos.mp3, ambient_epiko.mp3, ambient_halaman.mp3,
  ///            ambient_hayop.mp3, ambient_lunsod.mp3, ambient_lalawigan.mp3,
  ///            ambient_tribo.mp3, ambient_kasaysayan.mp3, ambient_tauhan.mp3,
  ///            ambient_paglikha.mp3, ambient_default.mp3
  static const String _musicUrl =
      'https://raw.githubusercontent.com/Gyerii/alamat-stories/main/music';

  // ── KUMPLETONG LISTAHAN — 97 kwento ──
  static const List<Map<String, String>> _stories = [

    // ════════════════════════════════════════════
    // MINDANAO — 41 kwento
    // ════════════════════════════════════════════
    {'id': 'alamat_ng_mindanao',           'folder': 'mindanao'},
    {'id': 'indarapatra_at_sulayman',      'folder': 'mindanao'},
    {'id': 'agyu_bayani_ng_bukidnon',      'folder': 'mindanao'},
    {'id': 'tudbulul_tboli_epic',          'folder': 'mindanao'},
    {'id': 'darangen_maranao_epic',        'folder': 'mindanao'},
    {'id': 'ulahingan_livunganen_epic',    'folder': 'mindanao'},
    {'id': 'lawanen_bayani_ng_bagobo',     'folder': 'mindanao'},
    {'id': 'sandayo_ng_subanon',           'folder': 'mindanao'},
    {'id': 'mount_apo', 'folder': 'mindanao'},
    {'id': 'si_magindanao_at_maguindanao', 'folder': 'mindanao'},
    {'id': 'mga_datu_ng_lanao',            'folder': 'mindanao'},
    {'id': 'alamat_ng_davao_city',         'folder': 'mindanao'},
    {'id': 'si_rajah_muda', 'folder': 'mindanao'},
    {'id': 'alamat_ng_zamboanga',          'folder': 'mindanao'},
    {'id': 'alamat_ng_cagayan_de_oro',     'folder': 'mindanao'},
    {'id': 'alamat_ng_cotabato',           'folder': 'mindanao'},
    {'id': 'ang_tiruray_taga_bundok',      'folder': 'mindanao'},
    {'id': 'ang_blaan_at_ang_tubig',       'folder': 'mindanao'},
    {'id': 'ang_subanen_at_ang_lunsod',    'folder': 'mindanao'},
    {'id': 'ang_mandaya_at_ang_dagat',     'folder': 'mindanao'},
    {'id': 'alamat_ng_sarangani',          'folder': 'mindanao'},
    {'id': 'alamat_ng_sultan_kudarat',     'folder': 'mindanao'},
    {'id': 'alamat_ng_lanao_del_norte',    'folder': 'mindanao'},
    {'id': 'alamat_ng_lanao_del_sur',      'folder': 'mindanao'},
    {'id': 'alamat_ng_maguindanao',        'folder': 'mindanao'},
    {'id': 'alamat_ng_north_cotabato',     'folder': 'mindanao'},
    {'id': 'alamat_ng_south_cotabato',     'folder': 'mindanao'},
    {'id': 'alamat_ng_davao_del_sur',      'folder': 'mindanao'},
    {'id': 'alamat_ng_davao_oriental',     'folder': 'mindanao'},
    {'id': 'alamat_ng_davao_del_norte',    'folder': 'mindanao'},
    {'id': 'alamat_ng_compostela_valley',  'folder': 'mindanao'},
    {'id': 'alamat_ng_surigao_del_sur',    'folder': 'mindanao'},
    {'id': 'alamat_ng_agusan_del_norte',   'folder': 'mindanao'},
    {'id': 'alamat_ng_agusan_del_sur',     'folder': 'mindanao'},
    {'id': 'alamat_ng_misamis_oriental',   'folder': 'mindanao'},
    {'id': 'alamat_ng_misamis_occidental', 'folder': 'mindanao'},
    {'id': 'alamat_ng_bukidnon',           'folder': 'mindanao'},
    {'id': 'alamat_ng_camiguin',           'folder': 'mindanao'},
    {'id': 'alamat_ng_lanao',              'folder': 'mindanao'},
    {'id': 'alamat_ng_basilan',            'folder': 'mindanao'},
    {'id': 'alamat_ng_sulu',               'folder': 'mindanao'},
    {'id': 'alamat_ng_tawi_tawi',          'folder': 'mindanao'},

    // ════════════════════════════════════════════
    // PAMBANSA — 28 kwento
    // ════════════════════════════════════════════
    {'id': 'alamat_ng_paglikha_ng_mundo',    'folder': 'pambansa'},
    {'id': 'si_bathala',                     'folder': 'pambansa'},
    {'id': 'si_laho_at_ang_pagkuha_ng_araw', 'folder': 'pambansa'},
    {'id': 'alamat_ng_araw_at_buwan',        'folder': 'pambansa'},
    {'id': 'alamat_ng_mga_bituin',           'folder': 'pambansa'},
    {'id': 'kung_bakit_maalat_ang_dagat',    'folder': 'pambansa'},
    {'id': 'alamat_ng_langit_at_lupa',       'folder': 'pambansa'},
    {'id': 'ibong_adarna',                   'folder': 'pambansa'},
    {'id': 'florante_at_laura',              'folder': 'pambansa'},
    {'id': 'ang_tikbalang',                  'folder': 'pambansa'},
    {'id': 'ang_diwata_ng_kagubatan',        'folder': 'pambansa'},
    {'id': 'ang_nuno_sa_punso',              'folder': 'pambansa'},
    {'id': 'ang_manananggal',                'folder': 'pambansa'},
    {'id': 'ang_kapre',                      'folder': 'pambansa'},
    {'id': 'ang_sigbin',                     'folder': 'pambansa'},
    {'id': 'alamat_ng_sampaguita',           'folder': 'pambansa'},
    {'id': 'alamat_ng_niyog',                'folder': 'pambansa'},
    {'id': 'alamat_ng_pinya',                'folder': 'pambansa'},
    {'id': 'alamat_ng_bayabas',              'folder': 'pambansa'},
    {'id': 'alamat_ng_palay',                'folder': 'pambansa'},
    {'id': 'alamat_ng_ampalaya',             'folder': 'pambansa'},
    {'id': 'alamat_ng_santol',               'folder': 'pambansa'},
    {'id': 'alamat_ng_anahaw',               'folder': 'pambansa'},
    {'id': 'si_maria_makiling',              'folder': 'pambansa'},
    {'id': 'si_mariang_sinukuan',            'folder': 'pambansa'},
    {'id': 'si_juan_tamad',                  'folder': 'pambansa'},
    {'id': 'si_pedro_penduko',               'folder': 'pambansa'},
    {'id': 'si_malakas_at_maganda',          'folder': 'pambansa'},

    // ════════════════════════════════════════════
    // LUZON — 15 kwento
    // ════════════════════════════════════════════
    {'id': 'daragang_magayon',              'folder': 'luzon'},
    {'id': 'si_lam_ang',                    'folder': 'luzon'},
    {'id': 'alamat_ng_baguio',              'folder': 'luzon'},
    {'id': 'alamat_ng_taal',                'folder': 'luzon'},
    {'id': 'alamat_ng_mayon',               'folder': 'luzon'},
    {'id': 'alamat_ng_banahaw',             'folder': 'luzon'},
    {'id': 'alamat_ng_batangas',            'folder': 'luzon'},
    {'id': 'alamat_ng_laguna',              'folder': 'luzon'},
    {'id': 'alamat_ng_quezon',              'folder': 'luzon'},
    {'id': 'alamat_ng_bulacan',             'folder': 'luzon'},
    {'id': 'alamat_ng_pampanga',            'folder': 'luzon'},
    {'id': 'alamat_ng_pangasinan',          'folder': 'luzon'},
    {'id': 'alamat_ng_ilocos',              'folder': 'luzon'},
    {'id': 'alamat_ng_cagayan_valley',      'folder': 'luzon'},
    {'id': 'alamat_ng_bicol',               'folder': 'luzon'},
    // ════════════════════════════════════════════
// LUZON — 72 kwento — paste into _stories list
// ════════════════════════════════════════════
    {'id': 'alamat_ng_abra',                               'folder': 'luzon'},
    {'id': 'alamat_ng_aparri',                             'folder': 'luzon'},
    {'id': 'alamat_ng_apayao',                             'folder': 'luzon'},
    {'id': 'alamat_ng_aurora',                             'folder': 'luzon'},
    {'id': 'alamat_ng_baler',                              'folder': 'luzon'},
    {'id': 'alamat_ng_banaue_rice_terraces',               'folder': 'luzon'},
    {'id': 'alamat_ng_bataan',                             'folder': 'luzon'},
    {'id': 'alamat_ng_bataan_baybayin',                    'folder': 'luzon'},
    {'id': 'alamat_ng_batac',                              'folder': 'luzon'},
    {'id': 'alamat_ng_benguet',                            'folder': 'luzon'},
    {'id': 'alamat_ng_bicolandia',                         'folder': 'luzon'},
    {'id': 'alamat_ng_bulkang_mayon',                      'folder': 'luzon'},
    {'id': 'alamat_ng_bundok_arayat',                      'folder': 'luzon'},
    {'id': 'alamat_ng_bundok_banahaw',                     'folder': 'luzon'},
    {'id': 'alamat_ng_camarines_norte',                    'folder': 'luzon'},
    {'id': 'alamat_ng_camarines_sur',                      'folder': 'luzon'},
    {'id': 'alamat_ng_catanduanes',                        'folder': 'luzon'},
    {'id': 'alamat_ng_cavite',                             'folder': 'luzon'},
    {'id': 'alamat_ng_cordillera',                         'folder': 'luzon'},
    {'id': 'alamat_ng_dagupan_at_ang_bangus',              'folder': 'luzon'},
    {'id': 'alamat_ng_daragang_magayon',                   'folder': 'luzon'},
    {'id': 'alamat_ng_hundred_islands',                    'folder': 'luzon'},
    {'id': 'alamat_ng_ifugao',                             'folder': 'luzon'},
    {'id': 'alamat_ng_ilocos_norte',                       'folder': 'luzon'},
    {'id': 'alamat_ng_ilocos_sur',                         'folder': 'luzon'},
    {'id': 'alamat_ng_ilog_cagayan',                       'folder': 'luzon'},
    {'id': 'alamat_ng_isabela',                            'folder': 'luzon'},
    {'id': 'alamat_ng_kalinga',                            'folder': 'luzon'},
    {'id': 'alamat_ng_la_union',                           'folder': 'luzon'},
    {'id': 'alamat_ng_laguna_de_bay',                      'folder': 'luzon'},
    {'id': 'alamat_ng_laoag',                              'folder': 'luzon'},
    {'id': 'alamat_ng_marinduque',                         'folder': 'luzon'},
    {'id': 'alamat_ng_masbate',                            'folder': 'luzon'},
    {'id': 'alamat_ng_mindoro',                            'folder': 'luzon'},
    {'id': 'alamat_ng_mountain_province',                  'folder': 'luzon'},
    {'id': 'alamat_ng_nueva_ecija',                        'folder': 'luzon'},
    {'id': 'alamat_ng_pagsanjan_falls',                    'folder': 'luzon'},
    {'id': 'alamat_ng_pangalan_ng_maynila',                'folder': 'luzon'},
    {'id': 'alamat_ng_probinsya_ng_rizal',                 'folder': 'luzon'},
    {'id': 'alamat_ng_quezon_province',                    'folder': 'luzon'},
    {'id': 'alamat_ng_romblon',                            'folder': 'luzon'},
    {'id': 'alamat_ng_samar_luzon',                        'folder': 'luzon'},
    {'id': 'alamat_ng_sorsogon',                           'folder': 'luzon'},
    {'id': 'alamat_ng_surigao_norte',                      'folder': 'luzon'},    
    {'id': 'alamat_ng_tuguegarao',                         'folder': 'luzon'},
    {'id': 'alamat_ng_vigan',                              'folder': 'luzon'},
    {'id': 'alamat_ng_zambales',                           'folder': 'luzon'},
    {'id': 'ang_aswang',                                   'folder': 'luzon'},
    {'id': 'ang_bakunawa',                                 'folder': 'luzon'},
    {'id': 'ang_berberoka_ng_ilog',                        'folder': 'luzon'},
    {'id': 'ang_bernardo_carpio',                          'folder': 'luzon'},
    {'id': 'ang_hudhud_ng_ifugao',                         'folder': 'luzon'},
    {'id': 'ang_mga_anito_ng_pilipinas',                   'folder': 'luzon'},
    {'id': 'ang_minokawa',                                 'folder': 'luzon'},
    {'id': 'ang_multo_sa_bahay',                           'folder': 'luzon'},
    {'id': 'ang_santelmo',                                 'folder': 'luzon'},
    {'id': 'ang_wakwak',                                   'folder': 'luzon'},
    {'id': 'si_aliguyon',                                  'folder': 'luzon'},
    {'id': 'si_asuang_at_si_gugurang',                     'folder': 'luzon'},
    {'id': 'si_kabunian_diyos_ng_igorot',                  'folder': 'luzon'},
    {'id': 'si_lumawig_at_ang_mga_bontoc',                 'folder': 'luzon'},
    {'id': 'si_oryol_ng_bicol',                            'folder': 'luzon'},
    {'id': 'si_tandang_sora',                              'folder': 'luzon'},
    {'id': 'si_urduja_ng_pangasinan',                      'folder': 'luzon'},

    // ════════════════════════════════════════════
    // VISAYAS — 10 kwento
    // ════════════════════════════════════════════
    {'id': 'lapu_lapu',                     'folder': 'visayas'},
    {'id': 'chocolate_hills',               'folder': 'visayas'},
    {'id': 'bantay_araw',                   'folder': 'visayas'},
    {'id': 'alamat_ng_cebu',                'folder': 'visayas'},
    {'id': 'alamat_ng_iloilo',              'folder': 'visayas'},
    {'id': 'alamat_ng_leyte',               'folder': 'visayas'},
    {'id': 'alamat_ng_samar',               'folder': 'visayas'},
    {'id': 'alamat_ng_negros',              'folder': 'visayas'},
    {'id': 'alamat_ng_bohol',               'folder': 'visayas'},
    {'id': 'alamat_ng_siquijor',            'folder': 'visayas'},
     {'id': 'alamat_ng_aklan', 'folder': 'visayas'},
    {'id': 'alamat_ng_antique', 'folder': 'visayas'},
    {'id': 'alamat_ng_bacolod', 'folder': 'visayas'},
    {'id': 'alamat_ng_biliran', 'folder': 'visayas'},
    {'id': 'alamat_ng_bohol_island', 'folder': 'visayas'},
    {'id': 'alamat_ng_bohol_tarsier', 'folder': 'visayas'},
    {'id': 'alamat_ng_camiguin_visayas', 'folder': 'visayas'},
    {'id': 'alamat_ng_capiz', 'folder': 'visayas'},
    {'id': 'alamat_ng_cebu_city', 'folder': 'visayas'},
    {'id': 'alamat_ng_cebu_oslob', 'folder': 'visayas'},
    {'id': 'alamat_ng_cebu_sinulog', 'folder': 'visayas'},
    {'id': 'alamat_ng_cebuano_folklore', 'folder': 'visayas'},
    {'id': 'alamat_ng_dinagat_islands', 'folder': 'visayas'},
    {'id': 'alamat_ng_eastern_samar', 'folder': 'visayas'},
    {'id': 'alamat_ng_guimaras', 'folder': 'visayas'},
    {'id': 'alamat_ng_iloilo_city', 'folder': 'visayas'},
    {'id': 'alamat_ng_iloilo_heritage', 'folder': 'visayas'},
    {'id': 'alamat_ng_leyte_island', 'folder': 'visayas'},
    {'id': 'alamat_ng_negros_island', 'folder': 'visayas'},
    {'id': 'alamat_ng_northern_samar', 'folder': 'visayas'},
    {'id': 'alamat_ng_panay_island', 'folder': 'visayas'},
    {'id': 'alamat_ng_samar_island', 'folder': 'visayas'},
    {'id': 'alamat_ng_siquijor_island', 'folder': 'visayas'},
    {'id': 'alamat_ng_surigao_del_norte', 'folder': 'visayas'},
    {'id': 'alamat_ng_tacloban', 'folder': 'visayas'},
    {'id': 'alamat_ng_western_samar', 'folder': 'visayas'},
    {'id': 'ang_aginid_cebuano_epic', 'folder': 'visayas'},
    {'id': 'ang_bungisngis', 'folder': 'visayas'},
    {'id': 'ang_engkanto_ng_visayas', 'folder': 'visayas'},
    {'id': 'ang_haliya_diyosa_ng_buwan', 'folder': 'visayas'},
    {'id': 'ang_hinilawod_panay_epic', 'folder': 'visayas'},
    {'id': 'ang_magayon_visayas', 'folder': 'visayas'},
    {'id': 'ang_olimaw_ng_cebu', 'folder': 'visayas'},
    {'id': 'ang_saging_at_baboy_damo', 'folder': 'visayas'},
    {'id': 'ang_tambanokano', 'folder': 'visayas'},
    {'id': 'si_lapu_lapu_at_si_magellan', 'folder': 'visayas'},


    // ════════════════════════════════════════════
    // PALAWAN — 3 kwento
    // ════════════════════════════════════════════
    {'id': 'underground_river',             'folder': 'palawan'},
    {'id': 'el_nido',                       'folder': 'palawan'},
    {'id': 'si_manuyog',                    'folder': 'palawan'},
    {'id': 'si_ampu_diyos_ng_palawan',      'folder': 'palawan'},
{'id': 'alamat_ng_batanes',             'folder': 'palawan'},
{'id': 'alamat_ng_mga_mangyan_ng_mindoro', 'folder': 'palawan'},
{'id': 'alamat_ng_coron',               'folder': 'palawan'},
{'id': 'alamat_ng_tubbataha',           'folder': 'palawan'},
{'id': 'alamat_ng_honda_bay',           'folder': 'palawan'},
{'id': 'alamat_ng_busuanga',            'folder': 'palawan'},
{'id': 'alamat_ng_port_barton',         'folder': 'palawan'},
{'id': 'alamat_ng_balabac',             'folder': 'palawan'},
{'id': 'alamat_ng_linapacan',           'folder': 'palawan'},
{'id': 'alamat_ng_narra',               'folder': 'palawan'},
{'id': 'alamat_ng_roxas_palawan',       'folder': 'palawan'},
{'id': 'alamat_ng_san_vicente',         'folder': 'palawan'},
{'id': 'alamat_ng_aborlan',             'folder': 'palawan'},
{'id': 'alamat_ng_quezon_palawan',      'folder': 'palawan'},
{'id': 'alamat_ng_brookes_point',       'folder': 'palawan'},
{'id': 'alamat_ng_espanola',            'folder': 'palawan'},
{'id': 'alamat_ng_kalayaan_islands',    'folder': 'palawan'},
{'id': 'alamat_ng_puerto_princesa',     'folder': 'palawan'},
{'id': 'alamat_ng_tagbanua',            'folder': 'palawan'},
{'id': 'alamat_ng_batak',               'folder': 'palawan'},
{'id': 'alamat_ng_calauit',             'folder': 'palawan'},
{'id': 'alamat_ng_iwahig',              'folder': 'palawan'},

  ];

  /// Lahat ng music tracks — isa per category + default
  static const List<String> _musicFiles = [
    'ambient_bayani.mp3',
    'ambient_diyos.mp3',
    'ambient_nilalang.mp3',
    'ambient_halaman.mp3',
    'ambient_hayop.mp3',
    'ambient_likas.mp3',
    'ambient_epiko.mp3',
    'ambient_lunsod.mp3',
    'ambient_lalawigan.mp3',
    'ambient_tribo.mp3',
    'ambient_kasaysayan.mp3',
    'ambient_default.mp3',
  ];

  // ── Directory helpers ──

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

  Future<Directory> _getMusicDir() async {
    if (_musicDir != null) return _musicDir!;
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/music');
    if (!await dir.exists()) await dir.create(recursive: true);
    _musicDir = dir;
    return dir;
  }

  // ── Download check ──

  Future<bool> areStoriesDownloaded() async {
    final dir = await _getStoriesDir();
    for (final s in _stories) {
      if (!await File('${dir.path}/${s['id']}.json').exists()) return false;
    }
    return true;
  }

  // ── Main download ──
  // Total steps = stories + covers + music
  // stories = _stories.length
  // covers  = _stories.length
  // music   = _musicFiles.length

  Future<bool> downloadAll({
    required Function(int current, int total, String name) onProgress,
    required Function(String error) onError,
  }) async {
    final total = _stories.length * 2 + _musicFiles.length;
    int current = 0;

    // ── Step 1: JSON stories (sequential) ──
    final storiesDir = await _getStoriesDir();
    for (final s in _stories) {
      current++;
      final id = s['id']!;
      final folder = s['folder']!;
      onProgress(current, total, id.replaceAll('_', ' '));

      final file = File('${storiesDir.path}/$id.json');
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

    // ── Step 2: Covers (parallel) ──
    final coversDir = await _getCoversDir();
    onProgress(current, total, 'mga larawan...');

    final coversToDownload = <Map<String, String>>[];
    for (final s in _stories) {
      final file = File('${coversDir.path}/${s['id']}.png');
      if (await file.exists()) {
        _coverCache[s['id']!] = file.path;
      } else {
        coversToDownload.add(s);
      }
    }

    int coversDone = 0;
    await Future.wait(
      coversToDownload.map((s) async {
        final id = s['id']!;
        final file = File('${coversDir.path}/$id.png');
        try {
          final res = await http
              .get(Uri.parse('$_coversUrl/$id.png'))
              .timeout(const Duration(seconds: 30));
          if (res.statusCode == 200) {
            await file.writeAsBytes(res.bodyBytes);
            _coverCache[id] = file.path;
          } else {
            _coverCache[id] = null;
          }
        } catch (_) {
          _coverCache[id] = null;
        }
        coversDone++;
        current = _stories.length + coversDone;
        onProgress(
            current, total, 'larawan $coversDone / ${coversToDownload.length}');
      }),
    );

    // ── Step 3: Music (parallel) ──
    final musicDir = await _getMusicDir();
    onProgress(current, total, 'musika...');

    final musicToDownload = <String>[];
    for (final filename in _musicFiles) {
      final file = File('${musicDir.path}/$filename');
      if (await file.exists()) {
        _musicCache[filename] = file.path;
      } else {
        musicToDownload.add(filename);
      }
    }

    int musicDone = 0;
    await Future.wait(
      musicToDownload.map((filename) async {
        final file = File('${musicDir.path}/$filename');
        try {
          final res = await http
              .get(Uri.parse('$_musicUrl/$filename'))
              .timeout(const Duration(seconds: 60));
          if (res.statusCode == 200) {
            await file.writeAsBytes(res.bodyBytes);
            _musicCache[filename] = file.path;
          } else {
            _musicCache[filename] = null;
          }
        } catch (_) {
          _musicCache[filename] = null;
        }
        musicDone++;
        current = _stories.length * 2 + musicDone;
        onProgress(
            current, total, 'musika $musicDone / ${musicToDownload.length}');
      }),
    );

    return true;
  }

  // ── Loaders ──

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

  Future<String?> getLocalCover(String id) async {
    if (_coverCache.containsKey(id)) return _coverCache[id];
    final dir = await _getCoversDir();
    final file = File('${dir.path}/$id.png');
    final path = await file.exists() ? file.path : null;
    _coverCache[id] = path;
    return path;
  }

  /// Returns local path ng ambient music para sa category.
  /// Kung walang specific na music, falls back sa ambient_default.mp3.
  Future<String?> getLocalMusic(String category) async {
    final filename = _musicFilename(category);
    if (_musicCache.containsKey(filename)) return _musicCache[filename];
    final dir = await _getMusicDir();
    final file = File('${dir.path}/$filename');
    final path = await file.exists() ? file.path : null;
    _musicCache[filename] = path;
    return path;
  }

  /// Category → music filename mapping
  String _musicFilename(String category) {
    switch (category.toLowerCase().trim()) {
      case 'bayani':     return 'ambient_bayani.mp3';
      case 'diyos':      return 'ambient_diyos.mp3';
      case 'nilalang':   return 'ambient_nilalang.mp3';
      case 'halaman':    return 'ambient_halaman.mp3';
      case 'hayop':      return 'ambient_hayop.mp3';
      case 'likas':      return 'ambient_likas.mp3';
      case 'epiko':      return 'ambient_epiko.mp3';
      case 'lunsod':     return 'ambient_lunsod.mp3';
      case 'lalawigan':  return 'ambient_lalawigan.mp3';
      case 'tribo':      return 'ambient_tribo.mp3';
      case 'kasaysayan': return 'ambient_kasaysayan.mp3';
      default:           return 'ambient_default.mp3';
    }
  }

  // ── Helpers ──

  void setCoverCache(String id, String path) => _coverCache[id] = path;

  void clearCache() {
    _coverCache.clear();
    _musicCache.clear();
    _storiesDir = null;
    _coversDir = null;
    _musicDir = null;
    _allAlamat = [];
    _loaded = false;
  }

  /// Pangunahing filter — gamit sa HomeScreen (by category field ng JSON)
  List<AlamatModel> filterByCategory(List<AlamatModel> list, String category) {
    if (category == 'lahat') return list;
    return list
        .where((a) => a.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// Backward-compatible — ginagamit pa ng ilang lumang screen
  List<AlamatModel> filterByRegion(List<AlamatModel> list, String region) {
    if (region == 'lahat') return list;
    return list
        .where((a) => a.category.toLowerCase() == region.toLowerCase())
        .toList();
  }

  List<AlamatModel> search(List<AlamatModel> list, String query) {
    if (query.trim().isEmpty) return list;
    final q = query.toLowerCase();
    return list
        .where((a) =>
            a.titleFil.toLowerCase().contains(q) ||
            a.region.toLowerCase().contains(q))
        .toList();
  }

  /// Bilang ng kwento per category — for stats / badges
  Map<String, int> categoryCounts(List<AlamatModel> list) {
    final counts = <String, int>{};
    for (final a in list) {
      counts[a.category] = (counts[a.category] ?? 0) + 1;
    }
    return counts;
  }

  /// Bilang ng kwento per folder/region — for region tabs
  Map<String, int> folderCounts() {
    final counts = <String, int>{};
    for (final s in _stories) {
      final f = s['folder']!;
      counts[f] = (counts[f] ?? 0) + 1;
    }
    return counts;
  }

  int get totalStories => _stories.length;
}