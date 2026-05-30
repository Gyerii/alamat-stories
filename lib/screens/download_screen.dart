import 'package:flutter/material.dart';
import '../services/alamat_service.dart';
import 'home_screen.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  bool _downloading = false;
  bool _error = false;
  String _errorMsg = '';
  int _current = 0;
  int _total = 0;
  String _currentName = '';

  Future<void> _startDownload() async {
    setState(() {
      _downloading = true;
      _error = false;
    });

    final success = await AlamatService().downloadAll(
      onProgress: (current, total, name) {
        if (mounted) setState(() {
          _current = current;
          _total = total;
          _currentName = name;
        });
      },
      onError: (msg) {
        if (mounted) setState(() {
          _error = true;
          _errorMsg = msg;
          _downloading = false;
        });
      },
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _total == 0 ? 0.0 : _current / _total;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/alamat.png', height: 120),
              const SizedBox(height: 40),

              if (!_downloading && !_error) ...[
                const Text(
                  'I-download ang mga Kwento',
                  style: TextStyle(color: Colors.white, fontSize: 20,
                      fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Kailangan ng internet para sa unang download. Pagkatapos, offline na ang lahat.',
                  style: TextStyle(color: Colors.white.withOpacity(0.55),
                      fontSize: 14, height: 1.6),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text('~5MB lang ang laki',
                    style: TextStyle(color: Color(0xFFC9A84C), fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startDownload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC9A84C),
                      foregroundColor: const Color(0xFF0F0E1A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('I-download Ngayon',
                        style: TextStyle(fontSize: 16,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              ],

              if (_downloading) ...[
                const Text('Dino-download...',
                    style: TextStyle(color: Colors.white, fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFC9A84C)),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 12),
                Text('$_current / $_total  —  $_currentName',
                    style: TextStyle(color: Colors.white.withOpacity(0.5),
                        fontSize: 13),
                    textAlign: TextAlign.center),
              ],

              if (_error) ...[
                const Icon(Icons.wifi_off_rounded,
                    color: Color(0xFFB5451B), size: 48),
                const SizedBox(height: 16),
                Text(_errorMsg,
                    style: const TextStyle(color: Colors.white, fontSize: 15,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startDownload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC9A84C),
                      foregroundColor: const Color(0xFF0F0E1A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Subukan Ulit',
                        style: TextStyle(fontSize: 16,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}