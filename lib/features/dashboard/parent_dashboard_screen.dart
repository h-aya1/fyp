import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart'; // Assuming google_fonts is available as per pubspec
import '../../main.dart';
import '../child_selection/child_selection_screen.dart';
import '../../core/audio_service.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'Welcome, Parent!',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      // Settings action
                    },
                    icon: const Icon(LucideIcons.settings, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // My Little Learners Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Little Learners',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddDialog(context),
                    icon: const Icon(LucideIcons.plus, size: 18),
                    label: Text(
                      'Add Child',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF4F46E5), // Indigoish blue
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Main Content Area (Child List or Empty State)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: state.children.isEmpty
                    ? const _EmptyStateCard()
                    : ListView.builder(
                        itemCount: state.children.length,
                        itemBuilder: (context, index) {
                          final child = state.children[index];
                          return Card(
                            elevation: 2,
                            shadowColor: Colors.black12,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                radius: 28,
                                backgroundImage: NetworkImage(child.avatar),
                                onBackgroundImageError: (_, __) {}, // Handle error
                                child: child.avatar.isEmpty ? const Icon(LucideIcons.user) : null,
                              ),
                              title: Text(
                                child.name,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Text(
                                'Mastered ${child.mastery.length} items',
                                style: GoogleFonts.poppins(color: Colors.grey[600]),
                              ),
                              trailing: const Icon(LucideIcons.chevronRight, color: Color(0xFF94A3B8)),
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
            ),

            // Bottom Stats Panel
            const _BottomStatsPanel(),
          ],
        ),
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
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

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: const Color(0xFFE2E8F0), strokeWidth: 2, gap: 8, dash: 8),
      child: Container(
        width: double.infinity,
        height: 250, // Approximate height from image
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.trendingUp, // Placeholder for the zig-zag arrow
              size: 48,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No children added yet.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: const Color(0xFF94A3B8),
              ),
            ),
            Text(
              "Tap 'Add Child' to get started!",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomStatsPanel extends StatelessWidget {
  const _BottomStatsPanel();

  @override
  Widget build(BuildContext context) {
    // Stats would ideally come from the state, hardcoded '0' for now as per design mock
    final state = context.watch<AppState>();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF3B82F6), // Bright Blue
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(LucideIcons.barChart2, color: Colors.white70),
              const SizedBox(width: 12),
              Text(
                'Group Overview',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard('${state.children.length}', 'KIDS'),
              _buildStatCard('0', 'TASKS'), // Placeholder
              _buildStatCard('A+', 'GRADE'), // Placeholder
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dash;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
    this.dash = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(24),
      ));

    final Path dashedPath = _dashPath(path, dashWidth: dash, dashSpace: gap);
    canvas.drawPath(dashedPath, paint);
  }

  Path _dashPath(Path source, {required double dashWidth, required double dashSpace}) {
    final Path path = Path();
    for (final ui.PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        path.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    return path;
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        gap != oldDelegate.gap ||
        dash != oldDelegate.dash;
  }
}
