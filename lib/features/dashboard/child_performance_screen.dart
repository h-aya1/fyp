import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'models/child_model.dart'; // Make sure this path is correct based on folder structure

class ChildPerformanceScreen extends StatelessWidget {
  final Child child;
  const ChildPerformanceScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: theme.appBarTheme.foregroundColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "${child.name}'s Performance",
          style: GoogleFonts.poppins(
            color: theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.share2, color: theme.appBarTheme.foregroundColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(context, 'Last 7 Days', true),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'Last 30 Days', false),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'All Time', false),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'Custom', false),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Performance Overview
            Text(
              'Performance Overview for ${child.name}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildPerformanceCard(
              context: context,
              title: "English Alphabet",
              accuracy: "85%",
              sessions: "25",
              time: "5h 10m",
              color: Colors.green,
              icon: LucideIcons.bookOpen,
              progress: 0.85,
            ),
            const SizedBox(height: 16),
            _buildPerformanceCard(
              context: context,
              title: "Amharic Alphabet",
              accuracy: "78%",
              sessions: "18",
              time: "3h 45m",
              color: Colors.amber,
              icon: LucideIcons.book,
              progress: 0.78,
            ),
             const SizedBox(height: 16),
            _buildPerformanceCard(
              context: context,
              title: "Numbers",
              accuracy: "92%",
              sessions: "30",
              time: "6h 20m",
              color: Colors.blue,
              icon: LucideIcons.calculator, // or Hash
              progress: 0.92,
            ),

            const SizedBox(height: 32),

            // Recent Learning Sessions
            Text(
              'Recent Learning Sessions',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildSessionRow(context, "English Alphabet", "Oct 26, 2023", "20 min", "95%", "Excellent", Colors.green),
            Divider(height: 32, color: theme.dividerColor),
            _buildSessionRow(context, "Amharic Alphabet", "Oct 25, 2023", "15 min", "80%", "Good", Colors.amber),
            Divider(height: 32, color: theme.dividerColor),
            _buildSessionRow(context, "Numbers", "Oct 24, 2023", "25 min", "88%", "Great", Colors.orange),

             const SizedBox(height: 32),

            // Timeline
            Text(
              'Learning Journey Timeline',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            _buildTimelineItem(context, "Oct 2023", "Mastered numbers 1-10.", Colors.green, true),
            _buildTimelineItem(context, "Sep 2023", "Recognizing all English letters.", Colors.amber, true),
            _buildTimelineItem(context, "Aug 2023", "Started Amharic letters.", Colors.blue, false),

             const SizedBox(height: 32),

             // Suggestions
            Text(
              'Personalized Learning Suggestions',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildSuggestionItem(context, "Focus on 'Amharic Alphabet' for 15 minutes daily to improve recognition."),
            _buildSuggestionItem(context, "Practice writing numbers 11-20 with the camera feature."),
            _buildSuggestionItem(context, "Revisit English consonant sounds through interactive games."),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Chip(
      label: Text(label),
      backgroundColor: isSelected ? const Color(0xFF4ADE80) : theme.cardTheme.color,
      labelStyle: GoogleFonts.poppins(
        color: isSelected ? Colors.white : colorScheme.onSurface.withOpacity(0.7),
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), 
        side: isSelected ? BorderSide.none : BorderSide(color: theme.dividerColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildPerformanceCard({
    required BuildContext context,
    required String title,
    required String accuracy,
    required String sessions,
    required String time,
    required Color color,
    required IconData icon,
    required double progress,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMiniStat(context, "Accuracy", accuracy),
                        _buildMiniStat(context, "Session", sessions),
                        _buildMiniStat(context, "Time", time),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              color: color,
              backgroundColor: theme.dividerColor,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionRow(BuildContext context, String subject, String date, String duration, String percent, String badge, Color color) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$subject - $date", // Simplified combining title and date for now in prompt style
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                duration,
                style: GoogleFonts.poppins(
                   fontSize: 13,
                   color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              percent,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTimelineItem(BuildContext context, String date, String desc, Color color, bool showLine) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(LucideIcons.trendingUp, color: color, size: 20), // Icon somewhat matches
            if (showLine)
              Container(
                width: 2,
                height: 40,
                color: theme.dividerColor,
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                   date,
                   style: GoogleFonts.poppins(
                     fontSize: 12,
                     color: colorScheme.onSurface.withOpacity(0.5),
                   ),
                 ),
                 const SizedBox(height: 4),
                 Text(
                   desc,
                   style: GoogleFonts.poppins(
                     fontSize: 14,
                     color: colorScheme.onSurface,
                   ),
                 ),
                 const SizedBox(height: 16), // Spacer for next item
              ],
            ),
        ),
      ],
    );
  }

  Widget _buildSuggestionItem(BuildContext context, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.lightbulb, color: Colors.amber, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
