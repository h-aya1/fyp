
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../child_selection/child_selection_screen.dart';
import '../../core/audio_service.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: state.children.isEmpty
            ? const Center(child: Text('No learners yet. Add your first child!'))
            : ListView.builder(
                itemCount: state.children.length,
                itemBuilder: (context, index) {
                  final child = state.children[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: CircleAvatar(backgroundImage: NetworkImage(child.avatar)),
                      title: Text(child.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Mastered ${child.mastery.length} items'),
                      trailing: const Icon(LucideIcons.chevronRight, color: Colors.blueGrey),
                      onTap: () {
                        audioService.playClick();
                        state.selectChild(child);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ChildSelectionScreen()));
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(LucideIcons.plus, size: 32, color: Colors.white),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Learner'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Name')),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<AppState>().addChild(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }
}
