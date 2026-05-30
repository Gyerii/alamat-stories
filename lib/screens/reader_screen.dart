import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/alamat_model.dart';
import '../services/alamat_service.dart';
import '../services/prefs_service.dart';

class ReaderScreen extends StatefulWidget {
  final AlamatModel alamat;
  final ChapterModel chapter;
  final String language;

  const ReaderScreen({
    super.key,
    required this.alamat,
    required this.chapter,
    required this.language,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen>
    with SingleTickerProviderStateMixin {
  final PrefsService _prefs = PrefsService();
  final AlamatService _alamatService = AlamatService();
  double _fontSize = 16;
  String? _localCoverPath;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  static const Color _gold = Color(0xFFC9A84C);
  static const Color _goldLight = Color(0xFFE2C97E);

  Color _categoryColor(String cat) => _gold;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _prefs.markChapterRead(widget.alamat.id, widget.chapter.chapter);
    _loadCover();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadCover() async {
    final path = await _alamatService.getLocalCover(widget.alamat.id);
    if (mounted) {
      setState(() => _localCoverPath = path);
      _fadeController.forward();
    }
  }

  String get _title => widget.language == 'fil'
      ? widget.chapter.titleFil
      : widget.chapter.titleEng;

  String get _text => widget.language == 'fil'
      ? widget.chapter.textFil
      : widget.chapter.textEng;

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor(widget.alamat.category);
    final storyTitle = widget.language == 'fil'
        ? widget.alamat.titleFil
        : widget.alamat.titleEng;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF050408),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image with fade-in ──
          if (_localCoverPath != null)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Image.file(
                File(_localCoverPath!),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.3),
                  radius: 1.2,
                  colors: [
                    Color(0xFF1A1228),
                    Color(0xFF050408),
                  ],
                ),
              ),
            ),

          // Layer 1: Base darkness
          Container(color: Colors.black.withOpacity(0.72)),

          // Layer 2: Top gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.black.withOpacity(0.65),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Layer 3: Bottom gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment(0, 0.3),
                  colors: [
                    Colors.black.withOpacity(0.85),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Layer 4: Vignette
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.4,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.45),
                  ],
                ),
              ),
            ),
          ),

          // ── Scrollable content ──
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: topPadding),

                // ── Top bar — arrow at same vertical level as +/− via Stack ──
                SizedBox(
                  height: 36,
                  child: Stack(
                    children: [
                      // Back button — left, same padding as EpisodeListScreen
                      Positioned(
                        left: 16,
                        top: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      // Font size controls — right
                      Positioned(
                        right: 16,
                        top: 0,
                        bottom: 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() =>
                                  _fontSize = (_fontSize - 2).clamp(12.0, 26.0)),
                              child: const Icon(Icons.remove_rounded,
                                  color: _gold, size: 26),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${_fontSize.round()}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.55),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => setState(() =>
                                  _fontSize = (_fontSize + 2).clamp(12.0, 26.0)),
                              child: const Icon(Icons.add_rounded,
                                  color: _gold, size: 26),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Story header ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chapter badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: catColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                              color: catColor.withOpacity(0.5), width: 1),
                        ),
                        child: Text(
                          'KABANATA ${widget.chapter.chapter}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: _goldLight,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Story title (subtitle)
                      Text(
                        storyTitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.40),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Chapter title (headline)
                      Text(
                        _title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Story text ──
                Padding(
                  padding: EdgeInsets.fromLTRB(22, 0, 22, 60 + bottomPadding),
                  child: Text(
                    _text,
                    style: TextStyle(
                      fontSize: _fontSize,
                      height: 2.0,
                      color: Colors.white.withOpacity(0.88),
                      letterSpacing: 0.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}