import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../question/question_screen.dart';
import '../../core/audio_service.dart';
import 'controllers/learning_session_controller.dart';

class LearningModeScreen extends StatelessWidget {
  const LearningModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select World')),
      body: GridView.count(
        padding: const EdgeInsets.all(24),
        crossAxisCount: 2,
        children: [
          _mode(context, 'English', '🔤', Colors.pink, 'ENGLISH'),
          _mode(context, 'Numbers', '🔢', Colors.blue, 'NUMBERS'),
          _mode(context, 'Amharic', '🌍', Colors.green, 'AMHARIC'),
          _mode(context, 'Random', '🎲', Colors.orange, 'RANDOM'),
        ],
      ),
    );
  }

  Widget _mode(BuildContext context, String title, String icon, Color color, String mode) {
    return Card(
      color: color.withOpacity(0.1),
      child: InkWell(
        onTap: () {
          audioService.playClick();
          final appState = Provider.of<AppState>(context, listen: false);
          final controller = LearningSessionController(
            onUpdateMastery: appState.updateMastery,
          )..startSession(appState.selectedChild!, mode);
          
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => QuestionScreen(controller: controller)
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 50)),
            const SizedBox(height: 8), 
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }
}
