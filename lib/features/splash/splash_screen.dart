import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.asset(
      'assets/animations/splash_animation.mp4',
    );

    await _videoPlayerController.initialize();
    _videoPlayerController.setLooping(false);
    _videoPlayerController.play();

    _videoPlayerController.addListener(() {
      if (_videoPlayerController.value.position >=
          _videoPlayerController.value.duration) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      }
    });

    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: _videoPlayerController.value.isInitialized
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: SizedBox(
                    width: _videoPlayerController.value.size.width,
                    height: _videoPlayerController.value.size.height,
                    child: VideoPlayer(_videoPlayerController),
                  ),
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      );
    }
  }
