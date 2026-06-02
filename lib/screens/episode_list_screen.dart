import 'dart:io';
import 'package:flutter/material.dart';
import '../models/alamat_model.dart';
import '../services/alamat_service.dart';
import '../services/music_service.dart';
import '../services/prefs_service.dart';
import 'reader_screen.dart';

class EpisodeListScreen extends StatefulWidget {
  final AlamatModel alamat;
  final String language;
  const EpisodeListScreen(
      {super.key, required this.alamat, required this.language});

  @override
  State<EpisodeListScreen> createState() => _EpisodeListScreenState();
}

class _EpisodeListScreenState extends State<EpisodeListScreen> {
  final PrefsService _prefs = PrefsService();
  final AlamatService _alamatService = AlamatService();
  final MusicService _music = MusicService();
  Set<String> _readChapters = {};
  String? _localCoverPath;

  static const Color _gold = Color(0xFFC9A84C);

  @override
  void initState() {
    super.initState();
    _loadRead();
    _loadCover();
    _switchMusic();
  }

  Future<void> _switchMusic() async {
    final localPath =
        await _alamatService.getLocalMusic(widget.alamat.category);
    if (localPath != null) {
      await _music.playForCategory(widget.alamat.category, localPath);
    }
  }

  Future<void> _loadRead() async {
    final read = await _prefs.getReadChapters();
    if (mounted) setState(() => _readChapters = read);
  }

  Future<void> _loadCover() async {
    final path = await _alamatService.getLocalCover(widget.alamat.id);
    if (mounted) setState(() => _localCoverPath = path);
  }

  bool _isRead(int chapter) =>
      _readChapters.contains('${widget.alamat.id}_$chapter');

  Color _categoryColor(String cat) => _gold;

  void _navigate(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 220),
        barrierColor: Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.language == 'fil'
        ? widget.alamat.titleFil
        : widget.alamat.titleEng;
    final readCount =
        widget.alamat.chapters.where((c) => _isRead(c.chapter)).length;
    final total = widget.alamat.chapters.length;
    final progress = total == 0 ? 0.0 : readCount / total;
    final catColor = _categoryColor(widget.alamat.category);
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Full screen background ──
          if (_localCoverPath != null)
            Image.file(
              File(_localCoverPath!),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            )
          else
            Container(color: const Color(0xFF0A0914)),

          // ── Dark overlay ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xAA000000),
                  Color(0xCC000000),
                  Color(0xF2000000),
                ],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // ── Content ──
          Column(
            children: [
              SizedBox(height: topPadding),

              // Top bar — back button only
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),

              // Story info
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: catColor.withOpacity(0.5)),
                      ),
                      child: Text(
                        widget.alamat.region.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: catColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                              color: Colors.black,
                              blurRadius: 20,
                              offset: Offset(0, 4))
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$readCount / $total kabanata',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${(progress * 100).round()}%',
                          style: TextStyle(
                            color: catColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(catColor),
                        minHeight: 3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Chapter list ──
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  itemCount: widget.alamat.chapters.length,
                  itemBuilder: (ctx, i) {
                    final chapter = widget.alamat.chapters[i];
                    final isRead = _isRead(chapter.chapter);
                    final chapterTitle = widget.language == 'fil'
                        ? chapter.titleFil
                        : chapter.titleEng;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          _navigate(ReaderScreen(
                            alamat: widget.alamat,
                            chapter: chapter,
                            language: widget.language,
                          ));
                          Future.delayed(
                              const Duration(milliseconds: 300), _loadRead);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isRead
                                ? catColor.withOpacity(0.12)
                                : Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isRead
                                  ? catColor.withOpacity(0.35)
                                  : Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isRead
                                      ? catColor.withOpacity(0.2)
                                      : Colors.white.withOpacity(0.07),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isRead
                                        ? catColor.withOpacity(0.5)
                                        : Colors.white.withOpacity(0.12),
                                  ),
                                ),
                                child: Center(
                                  child: isRead
                                      ? Icon(Icons.check_rounded,
                                          color: catColor, size: 18)
                                      : Text(
                                          '${chapter.chapter}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'KABANATA ${chapter.chapter}',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.white.withOpacity(0.35),
                                        letterSpacing: 1.2,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      chapterTitle,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isRead ? catColor : Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: isRead
                                    ? catColor
                                    : Colors.white.withOpacity(0.3),
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}