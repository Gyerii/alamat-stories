import 'dart:io';
import 'package:flutter/material.dart';
import '../models/alamat_model.dart';
import '../screens/image_viewer_screen.dart';
import '../services/alamat_service.dart';

class AlamatCard extends StatefulWidget {
  final AlamatModel alamat;
  final String language;
  final VoidCallback onTap;

  const AlamatCard({
    super.key,
    required this.alamat,
    required this.language,
    required this.onTap,
  });

  @override
  State<AlamatCard> createState() => _AlamatCardState();
}

class _AlamatCardState extends State<AlamatCard> {
  String? _localCoverPath;

  @override
  void initState() {
    super.initState();
    _localCoverPath = AlamatService.coverCache[widget.alamat.id];
    if (_localCoverPath == null) _loadCover();
  }

  // ── Key fix: pag nagbago ang alamat (grid reuse), i-reset agad ──
  @override
  void didUpdateWidget(covariant AlamatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.alamat.id != widget.alamat.id) {
      // Check cache synchronously first — no flash if already cached
      final cached = AlamatService.coverCache[widget.alamat.id];
      if (cached != null) {
        setState(() => _localCoverPath = cached);
      } else {
        setState(() => _localCoverPath = null);
        _loadCover();
      }
    }
  }

  Future<void> _loadCover() async {
    final path = await AlamatService().getLocalCover(widget.alamat.id);
    if (mounted) setState(() => _localCoverPath = path);
  }

  Color _categoryColor(String cat) => const Color(0xFFC9A84C);

  void _openImageViewer(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ImageViewerScreen(
          alamat: widget.alamat,
          language: widget.language,
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 200),
        barrierColor: Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.language == 'fil'
        ? widget.alamat.titleFil
        : widget.alamat.titleEng;
    final catColor = _categoryColor(widget.alamat.category);

    return GestureDetector(
      onTap: () => _openImageViewer(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image or placeholder
            _localCoverPath != null
                ? Image.file(
                    File(_localCoverPath!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),

            // Bottom gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.5, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.80),
                    ],
                  ),
                ),
              ),
            ),

            // Title at bottom
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.3,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF1B1A2E),
    );
  }
}