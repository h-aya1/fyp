
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../learning/learning_mode_screen.dart';
import '../../core/audio_service.dart';
import '../dashboard/models/child_model.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChildSelectionScreen extends StatelessWidget {
  const ChildSelectionScreen({super.key});

  String _calculateAccuracy(Child child) {
    if (child.mastery.isEmpty) return '0%';
    int totalAttempts = 0;
    int totalSuccesses = 0;
    for (var m in child.mastery) {
      totalAttempts += m.attempts;
      totalSuccesses += m.successes;
    }
    if (totalAttempts == 0) return '0%';
    return '${((totalSuccesses / totalAttempts) * 100).toStringAsFixed(0)}%';
  }

  @override
  Widget build(BuildContext context) {
    final child = context.watch<AppState>().selectedChild;
    if (child == null) return const Scaffold();

    return Scaffold(
      appBar: AppBar(
        title: Text(child.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 32),
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).primaryColor, width: 4),
              ),
              child: CircleAvatar(
                radius: 70, 
                backgroundColor: Colors.grey[200],
                backgroundImage: NetworkImage(child.avatar)
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statCard(context, 'Learned', child.mastery.length.toString(), LucideIcons.trophy, Colors.orange),
              _statCard(context, 'Accuracy', _calculateAccuracy(child), LucideIcons.target, Colors.green),
            ],
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: () {
                  audioService.playClick();
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const LearningModeScreen())
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4D96FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                ),
                child: const Text(
                  'START LEARNING', 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2)
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _statCard(BuildContext context, String label, String val, IconData icon, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 12),
          Text(val, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(color: color.withOpacity(0.8), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
