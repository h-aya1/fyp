
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final FlutterTts _tts = FlutterTts();

  Future<void> init() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.1);
  }

  bool _isAmharic(String text) {
    for (int i = 0; i < text.length; i++) {
      int code = text.codeUnitAt(i);
      if (code >= 0x1200 && code <= 0x137F) return true;
    }
    return false;
  }

  Future<void> speak(String text) async {
    try {
      if (_isAmharic(text)) {
        await _tts.setLanguage("am-ET");
      } else {
        await _tts.setLanguage("en-US");
      }
      await _tts.speak(text);
    } catch (e) {
      print("TTS Error: $e");
    }
  }

  void playClick() {
    HapticFeedback.selectionClick();
    SystemSound.play(SystemSoundType.click);
  }

  void playSuccess() {
    HapticFeedback.mediumImpact();
  }

  void playError() {
    HapticFeedback.vibrate();
  }
}

final audioService = AudioService();
