import 'dart:io';
import 'package:flutter/material.dart';
import '../models/alamat_model.dart';
import '../screens/episode_list_screen.dart';
import '../services/alamat_service.dart';

class AlamatCard extends StatefulWidget {
  final AlamatModel alamat;
  final String language;

  const AlamatCard({
    super.key,
    required this.alamat,
    required this.language,
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

  @override
  void didUpdateWidget(covariant AlamatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.alamat.id != widget.alamat.id) {
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

  void _handleTap(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => EpisodeListScreen(
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

    return GestureDetector(
      onTap: () => _handleTap(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _localCoverPath != null
                ? Image.file(
                    File(_localCoverPath!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),

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

  Widget _placeholder() => Container(color: const Color(0xFF1B1A2E));
}