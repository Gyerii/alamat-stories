import 'package:audioplayers/audioplayers.dart';
import 'prefs_service.dart';

/// Global singleton music service.
/// Music plays continuously across all screens.
/// Category changes fade smoothly to the new track.
class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  final AudioPlayer _player = AudioPlayer();
  final PrefsService _prefs = PrefsService();

  bool _enabled = true;
  bool _initialized = false;
  String _currentCategory = '';
  double _currentVolume = 0.0;

  static const double _targetVolume = 0.28;

  bool get isEnabled => _enabled;
  String get currentCategory => _currentCategory;

  /// True when music is actively playing (not paused/stopped).
  bool get isPlaying => _player.state == PlayerState.playing;

  /// Call once on app start (SplashScreen).
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _enabled = await _prefs.getMusicEnabled();
    // Set loop mode once here — also set again before every play() call
    // because audioplayers v6 resets ReleaseMode on each play().
    await _player.setReleaseMode(ReleaseMode.loop);
  }

  /// Play music for a category.
  /// - Same category already playing → no-op (seamless, no restart).
  /// - Different category → crossfade to new track.
  /// - Music disabled → no-op.
  Future<void> playForCategory(String category, String localPath) async {
    if (!_enabled) return;

    final isSame = _currentCategory == category &&
        _player.state == PlayerState.playing;
    if (isSame) return; // Already correct track — do nothing.

    _currentCategory = category;

    // Fade out current track before switching.
    if (_player.state == PlayerState.playing) {
      await _fadeVolume(to: 0.0, durationMs: 600);
      await _player.stop();
    }

    // IMPORTANT: set loop mode before every play() — audioplayers v6 resets
    // ReleaseMode to .release after each track completes without this.
    await _player.setReleaseMode(ReleaseMode.loop);

    // Fade in new track from silence.
    await _player.setVolume(0);
    _currentVolume = 0;
    await _player.play(DeviceFileSource(localPath));
    await _fadeVolume(to: _targetVolume, durationMs: 1500);
  }

  /// Resume the current track from where it was paused (if enabled).
  Future<void> resume() async {
    if (!_enabled) return;
    if (_player.state == PlayerState.playing) return;
    await _player.resume();
    await _fadeVolume(to: _targetVolume, durationMs: 800);
  }

  /// Pause with a gentle fade out.
  Future<void> pause() async {
    await _fadeVolume(to: 0.0, durationMs: 600);
    await _player.pause();
  }

  /// Toggle music on/off globally. Saves preference.
  Future<void> toggle() async {
    _enabled = !_enabled;
    await _prefs.setMusicEnabled(_enabled);
    if (_enabled) {
      await _player.resume();
      await _fadeVolume(to: _targetVolume, durationMs: 800);
    } else {
      await _fadeVolume(to: 0.0, durationMs: 600);
      await _player.pause();
    }
  }

  Future<void> _fadeVolume({
    required double to,
    required int durationMs,
  }) async {
    const steps = 20;
    final stepDelay = durationMs ~/ steps;
    final from = _currentVolume;
    final diff = to - from;
    for (int i = 1; i <= steps; i++) {
      _currentVolume = (from + diff * (i / steps)).clamp(0.0, 1.0);
      try {
        await _player.setVolume(_currentVolume);
      } catch (_) {}
      await Future.delayed(Duration(milliseconds: stepDelay));
    }
  }
}