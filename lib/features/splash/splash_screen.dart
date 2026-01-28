import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../onboarding/onboarding_screen.dart';
// Import the service to access providers
import '../learning/letter_trace/digital_ink_service.dart';
import '../learning/letter_trace/download_model_dialog.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _checkedModel = false;

  @override
  void initState() {
    super.initState();
    // Enable fullscreen/immersive mode for splash screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset('assets/animations/splash_animation.mp4');
    
    try {
      await _controller.initialize();
      if (!mounted) return;
      
      setState(() {
        _initialized = true;
      });
      
      _controller.play();
      _controller.setLooping(false);
      
      _controller.addListener(_videoListener);
    } catch (e) {
      debugPrint('Error initializing video: $e');
      _checkAndNavigate(); // Fallback if video fails
    }
  }

  void _videoListener() {
    if (_controller.value.position >= _controller.value.duration && !_checkedModel) {
      _checkedModel = true; // Prevent multiple calls
      _checkAndNavigate();
    }
  }

  Future<void> _checkAndNavigate() async {
    if (!mounted) return;

    // Check if BOTH main models are downloaded
    final service = ref.read(digitalInkServiceProvider);
    final am = await service.isModelDownloaded('am'); 
    final en = await service.isModelDownloaded('en');

    if (!mounted) return;

    if (am && en) {
      _navigateToOnboarding();
    } else {
      // Show download popup if EITHER is missing
      _showDownloadDialog();
    }
  }

  void _showDownloadDialog() {
    // Show non-blocking dialog (users can cancel if they want)
    showDialog(
      context: context,
      barrierDismissible: true, // Allow clicking outside to skip
      builder: (context) => const DownloadModelDialog(),
    ).then((result) {
        // Always navigate to onboarding, regardless of download success or skip
        _navigateToOnboarding();
    });
  }

  void _navigateToOnboarding() {
    if (!mounted) return;
    
    // Restore system UI before navigating away
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFFFFFFF), // Light blue background
      body: _initialized
          ? Container(

              color: const Color(0xFFFFFFFF), // Ensures background matches


              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(color: Color(0xFF033E8A)),
            ),
    );
  }
}

