
import 'package:flutter/material.dart';
import '../dashboard/parent_dashboard_screen.dart';
import '../../core/audio_service.dart';
import 'package:lucide_icons/lucide_icons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'emoji': '📚',
      'title': 'Learn & Play',
      'desc': 'A fun way to master letters and numbers.'
    },
    {
      'emoji': '📸',
      'title': 'AI Recognition',
      'desc': 'Just show your work to the camera!'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _slides.length,
              itemBuilder: (context, i) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_slides[i]['emoji'], style: const TextStyle(fontSize: 80)),
                  const SizedBox(height: 24),
                  Text(_slides[i]['title'], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(_slides[i]['desc'], textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: FloatingActionButton(
              onPressed: () {
                audioService.playClick();
                if (_currentPage < _slides.length - 1) {
                  _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                } else {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ParentDashboardScreen()));
                }
              },
              child: const Icon(LucideIcons.arrowRight, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
