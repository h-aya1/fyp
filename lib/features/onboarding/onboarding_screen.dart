import 'package:flutter/material.dart';
import 'package:concentric_transition/concentric_transition.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_screen.dart';
import '../../core/audio_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      icon: "📚",
      title: "Learn & Play",
      subtitle: "Master letters and numbers through fun games!",
      bgColor: const Color(0xFF0096C7), // Brand Primary Blue
      textColor: Colors.white,
    ),
    OnboardingPageData(
      icon: "📸",
      title: "Snap & Solve",
      subtitle: "Show your work to the camera for instant magic help.",
      bgColor: const Color(0xFF48CAE3), // Brand Secondary Cyan
      textColor: Colors.white,
    ),
    OnboardingPageData(
      icon: "🚀",
      title: "Blast Off!",
      subtitle: "Track your progress and reach for the stars.",
      bgColor: const Color(0xFF40E0D0), // Brand Accent Yellow
      textColor: const Color(0xFF033E8A), // Brand Deep Blue for contrast
    ),
  ];

  void _finishOnboarding() {
    audioService.playClick();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Concentric transition doesn't typically need dark mode scaffolding for the pages themselves
    // as it covers the whole screen with its own colors. 
    // However, we ensure the button and text styles remain vibrant.
    
    return Scaffold(
      body: ConcentricPageView(
        colors: _pages.map((p) => p.bgColor).toList(),
        radius: 30,
        curve: Curves.ease,
        nextButtonBuilder: (context) => const Icon(
          Icons.arrow_forward_rounded,
          size: 30,
          color: Colors.white,
        ),
        itemCount: _pages.length,
        onFinish: _finishOnboarding,
        itemBuilder: (index) {
          final page = _pages[index];
          return Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Emoji / Icon
                  Text(
                    page.icon,
                    style: const TextStyle(fontSize: 120),
                  ),
                  const SizedBox(height: 40),
                  
                  // Title
                  Text(
                    page.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.fredoka(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      color: page.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Subtitle
                  Text(
                    page.subtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.comicNeue(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: page.textColor.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class OnboardingPageData {
  final String icon;
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color textColor;

  OnboardingPageData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.textColor,
  });
}
