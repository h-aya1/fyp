import 'package:flutter/material.dart';
import '../../core/audio_service.dart';
import '../camera/camera_screen.dart';
import '../learning/controllers/learning_session_controller.dart';

class QuestionScreen extends StatefulWidget {
  final LearningSessionController controller;
  const QuestionScreen({super.key, required this.controller});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  @override
  void initState() {
    super.initState();
    // The session is already started by the LearningModeScreen
  }


  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final session = widget.controller.session;
        if (session == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        return Scaffold(
          appBar: AppBar(
            title: Text('Practice: ${session.learningMode}', style: const TextStyle(fontWeight: FontWeight.bold)),
            elevation: 0,
          ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Hero(
            tag: 'char_display',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1)),
              ),
              child: Text(
                session.targetCharacter,
                style: TextStyle(
                  fontSize: 140, 
                  fontWeight: FontWeight.w900, 
                  color: Theme.of(context).primaryColor,
                  fontFamily: 'monospace'
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Write this on your paper/board!', 
            style: TextStyle(fontSize: 18, color: Colors.blueGrey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 32),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Stack(
                    children: [
                      CameraScreen(onCaptured: (file) async {
                        if (widget.controller.isProcessing) return;
                        
                        try {
                          final bytes = await file.readAsBytes();
                          final result = await widget.controller.submitHandwritingResult(bytes);
                          
                          if (result['correct']) {
                            audioService.playSuccess();
                          } else {
                            audioService.playError();
                          }
                          
                          if (mounted) {
                            _showResult(result['correct'], result['feedback']);
                          }
                        } catch (e) {
                          // Error handling
                        }
                      }),
                      Visibility(
                        visible: widget.controller.isProcessing,
                        child: Container(
                          color: Colors.black87,
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 16),
                                Text('Checking your work...', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
      }
    );
  }

  void _showResult(bool correct, String feedback) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Result',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, anim1, anim2) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: Column(
          children: [
            Text(correct ? '⭐' : '🔄', style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            Text(correct ? 'Excellent!' : 'Keep Trying!', 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
          ],
        ),
        content: Text(feedback, textAlign: TextAlign.center, 
          style: const TextStyle(fontSize: 18, color: Colors.black54)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                widget.controller.advanceQuestion();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: correct ? Colors.green : Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: const StadiumBorder()
              ),
              child: Text(correct ? 'AWESOME!' : 'TRY NEXT', 
                style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}
