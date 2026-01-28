import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'digital_ink_service.dart';

class DownloadModelDialog extends ConsumerStatefulWidget {
  final bool isBlocking; // If true, hide "Skip" button
  const DownloadModelDialog({super.key, this.isBlocking = false});

  @override
  ConsumerState<DownloadModelDialog> createState() => _DownloadModelDialogState();
}

class _DownloadModelDialogState extends ConsumerState<DownloadModelDialog> {
  @override
  void initState() {
    super.initState();
    // Check initial status when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(digitalInkServiceProvider).checkAllModelsStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progressState = ref.watch(downloadProgressProvider);
    
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'One-time Download Required',
          style: TextStyle(
            color: Color(0xFF033E8A),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   const SizedBox(height: 10), // Space for X button
                  const Text(
                    'The writing feature requires downloading AI models (~40MB). This guarantees offline access forever.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  
                  // Status Check List
                  if (progressState.status != DownloadStatus.idle) ...[
                    _buildStatusRow('Internet Connection', progressState.hasInternet),
                    _buildStatusRow('Google Servers Reachable', progressState.canReachGoogle),
                    _buildStatusRow('Amharic Model', progressState.amharicDownloaded),
                    _buildStatusRow('English Model', progressState.englishDownloaded),
                    const SizedBox(height: 20),
                  ],

                  // Progress Bar or Error
                  if (progressState.status == DownloadStatus.failed)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        progressState.errorDetails ?? 'An error occurred.',
                        style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else if (progressState.status != DownloadStatus.idle && 
                           progressState.status != DownloadStatus.failed) ...[
                    LinearProgressIndicator(
                      value: progressState.progress,
                      backgroundColor: Colors.grey.shade200,
                      color: const Color(0xFF00B4D8),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      progressState.downloadedSize, // "X MB / 40.0 MB"
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF033E8A),
                      ),
                    ),
                    Text(
                      progressState.message,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
              // Close "X" Button
              Positioned(
                top: -15,
                right: -15,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 20, color: Colors.black54),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          // If already completed (happens if quick re-opened or success)
          if (progressState.status == DownloadStatus.completed)
             SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Start Learning!', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
             )
          else if (progressState.status == DownloadStatus.idle || 
              progressState.status == DownloadStatus.failed) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(digitalInkServiceProvider).downloadAllModels()
                     .then((success) {
                       if (success && mounted) {
                         // Auto close on strict success
                         Navigator.of(context).pop(true);
                       }
                     });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF033E8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  progressState.status == DownloadStatus.failed ? 'Retry Download' : 'Download Now',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (!widget.isBlocking) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false), // Skip
                    child: const Text('Skip for now'),
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool isSuccess) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isSuccess ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
