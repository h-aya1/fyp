import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
import '../child_selection/child_selection_screen.dart';
import 'child_performance_screen.dart'; 
import 'parent_home_screen.dart'; // Import to switch tabs
import '../../core/audio_service.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary, 
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.bookOpen, color: Colors.white),
                  ),
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=Parent'), 
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Notification Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED), // Keep accent bg for now, or match theme? keeping for visual consistency
                  // Ideally this should adapt too, maybe colorScheme.surfaceVariant
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.bell, color: Color(0xFF9A3412), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'New Learning Games Available!',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: const Color(0xFF431407),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explore exciting new games to make learning Amharic and English even more fun.',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF78350F),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Read More',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF78350F),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Your Children's Progress
              Text(
                "Your Children's Progress",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              
              // Children List Component
              state.children.isEmpty 
               ? _buildEmptyChildrenState(context)
               : SizedBox(
                  height: 240, // Increased height to prevent overflow
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.children.length,
                    clipBehavior: Clip.none,
                    itemBuilder: (context, index) {
                      final child = state.children[index];
                      return Container(
                        width: 280,
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: theme.dividerColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05), // Subtle shadow
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage: NetworkImage(child.avatar),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      child.name,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(LucideIcons.trendingUp, size: 14, color: Color(0xFFF97316)),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Score: 92%', // Placeholder
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF3B82F6),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Progress',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                  Text(
                                    '85%',
                                    style: GoogleFonts.poppins(color: colorScheme.onSurface.withOpacity(0.5)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: 0.85,
                                  backgroundColor: theme.dividerColor,
                                  color: const Color(0xFF3B82F6), // Blue
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Last activity: 15 mins ago',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                     audioService.playClick();
                                     state.selectChild(child);
                                     Navigator.push(context, MaterialPageRoute(builder: (context) => ChildPerformanceScreen(child: child)));
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    side: BorderSide(color: theme.dividerColor),
                                  ),
                                  child: Text(
                                    'View Details',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
              const SizedBox(height: 32),
              
              // Weekly Learning Time Chart
              Text(
                "Weekly Learning Time",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                "Total hours spent learning this week",
                style: GoogleFonts.poppins(color: colorScheme.onSurface.withOpacity(0.5)),
              ),
              const SizedBox(height: 24),
              // Simple Placeholder Chart
              Container(
                height: 200,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                   color: theme.cardTheme.color,
                   borderRadius: BorderRadius.circular(24),
                   border: Border.all(color: theme.dividerColor),
                ),
                child: CustomPaint(
                  painter: _ChartPainter(color: colorScheme.primary, gridColor: theme.dividerColor),
                ),
              ),

              const SizedBox(height: 32),

              // Quick Actions
              Text(
                "Quick Actions",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.6, // Adjusted to prevent overflow
                children: [
                  _buildActionCard(
                    icon: LucideIcons.users,
                    label: 'Enter Kids Mode',
                    color: const Color(0xFF3B82F6), // Blue
                    textColor: Colors.white,
                    onTap: () {
                       // Navigate to kids mode tab (Index 1)
                       ParentHomeScreen.of(context)?.switchToTab(1);
                    },
                  ),
                  _buildActionCard(
                    icon: LucideIcons.userPlus,
                    label: 'Add Child',
                    color: theme.dividerColor, 
                    textColor: colorScheme.onSurface,
                    onTap: () => _showAddDialog(context),
                  ),
                  _buildActionCard(
                    icon: LucideIcons.fileText,
                    label: 'View Reports',
                    color: theme.dividerColor,
                    textColor: colorScheme.onSurface,
                    onTap: () {},
                  ),
                  _buildActionCard(
                    icon: LucideIcons.gamepad2,
                    label: 'Browse Games',
                    color: theme.dividerColor,
                    textColor: colorScheme.onSurface,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyChildrenState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.users, size: 48, color: theme.iconTheme.color),
          const SizedBox(height: 16),
          Text(
            "No children added yet",
            style: GoogleFonts.poppins(color: theme.textTheme.bodyMedium?.color),
          ),
          TextButton(
            onPressed: () => _showAddDialog(context),
            child: const Text("Add a child"),
          )
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
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

class _ChartPainter extends CustomPainter {
  final Color color;
  final Color gridColor;

  _ChartPainter({this.color = const Color(0xFF3B82F6), this.gridColor = Colors.grey});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final Paint dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Grid lines
    final Paint gridPaint = Paint()
      ..color = gridColor.withOpacity(0.2)
      ..strokeWidth = 1;

    // Draw horizontal grid lines
    for (int i = 0; i < 5; i++) {
      double y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Rough data points (normalized 0-1)
    final points = [0.8, 0.6, 0.4, 0.5, 0.3, 0.1, 0.4]; 
    final path = Path();
    
    // Width between points
    final stepX = size.width / (points.length - 1);

    for (int i = 0; i < points.length; i++) {
        final x = i * stepX;
        final y = points[i] * size.height; // Invert logic if usually bottom is 0, but top is 0 here so it works fine visually
        
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          // Bezier curve for smoothness
          final prevX = (i - 1) * stepX;
          final prevY = points[i - 1] * size.height;
          final midX = (prevX + x) / 2;
          path.cubicTo(midX, prevY, midX, y, x, y);
        }
        
        canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
    
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
