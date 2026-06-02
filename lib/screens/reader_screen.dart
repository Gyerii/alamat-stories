import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/alamat_model.dart';
import '../services/alamat_service.dart';
import '../services/music_service.dart';
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
  final MusicService _music = MusicService();

  double _fontSize = 16;
  String? _localCoverPath;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  static const Color _gold = Color(0xFFC9A84C);
  static const Color _goldLight = Color(0xFFE2C97E);

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
    _ensureMusic();
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

  Future<void> _ensureMusic() async {
    final localPath =
        await _alamatService.getLocalMusic(widget.alamat.category);
    if (localPath != null) {
      await _music.playForCategory(widget.alamat.category, localPath);
    }
  }

  Future<void> _goBack() async {
    if (mounted) Navigator.pop(context);
  }

  String get _title => widget.language == 'fil'
      ? widget.chapter.titleFil
      : widget.chapter.titleEng;

  String get _text => widget.language == 'fil'
      ? widget.chapter.textFil
      : widget.chapter.textEng;

  @override
  Widget build(BuildContext context) {
    final storyTitle = widget.language == 'fil'
        ? widget.alamat.titleFil
        : widget.alamat.titleEng;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF050408),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── Background image ──
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
                    colors: [Color(0xFF1A1228), Color(0xFF050408)],
                  ),
                ),
              ),

            // ── Overlays ──
            Container(color: Colors.black.withOpacity(0.72)),
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
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: const Alignment(0, 0.3),
                    colors: [
                      Colors.black.withOpacity(0.85),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
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
                  // Reserved space para sa fixed top bar
                  SizedBox(height: topPadding + 56),

                  // ── Story header ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: _gold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: _gold.withOpacity(0.5), width: 1),
                          ),
                          child: Text(
                            'KABANATA ${widget.chapter.chapter}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: _goldLight,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
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
                    padding:
                        EdgeInsets.fromLTRB(22, 0, 22, 60 + bottomPadding),
                    child: SelectableText(
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

            // ── Fixed top bar — hindi gumagalaw kahit mag-scroll ──
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.only(top: topPadding),
                child: SizedBox(
                  height: 36,
                  child: Stack(
                    children: [
                      // Back button
                      Positioned(
                        left: 16,
                        top: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _goBack,
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),

                      // Right controls: minus + font size + plus + music
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
                            const SizedBox(width: 20),
                            // Music toggle — pinaka-right
                            StatefulBuilder(
                              builder: (ctx, localSet) => GestureDetector(
                                onTap: () async {
                                  await _music.toggle();
                                  localSet(() {});
                                  setState(() {});
                                },
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    _music.isEnabled
                                        ? Icons.music_note_rounded
                                        : Icons.music_off_rounded,
                                    key: ValueKey(_music.isEnabled),
                                    color: _music.isEnabled
                                        ? _gold
                                        : Colors.white.withOpacity(0.30),
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}