import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'models/child_model.dart';
import '../../core/services/persistence_service.dart';
import '../../core/models/handwriting_attempt.dart';

class ChildPerformanceScreen extends StatefulWidget {
  final Child child;
  const ChildPerformanceScreen({super.key, required this.child});

  @override
  State<ChildPerformanceScreen> createState() => _ChildPerformanceScreenState();
}

class _ChildPerformanceScreenState extends State<ChildPerformanceScreen> {
  final PersistenceService _persistence = PersistenceService();
  late Future<List<HandwritingAttempt>> _attemptsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _attemptsFuture = _persistence.getAttemptsForChild(widget.child.id);
  }

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
          "${widget.child.name}'s Performance",
          style: GoogleFonts.poppins(
            color: theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.refreshCw, color: theme.appBarTheme.foregroundColor),
            onPressed: () {
              setState(() {
                _loadData();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<HandwritingAttempt>>(
        future: _attemptsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final attempts = snapshot.data ?? [];
          
          if (attempts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(LucideIcons.clipboardList, size: 64, color: theme.dividerColor),
                   const SizedBox(height: 16),
                   Text(
                     "No learning activity yet",
                     style: GoogleFonts.poppins(
                       fontSize: 18, 
                       color: colorScheme.onSurface.withOpacity(0.6)
                     ),
                   ),
                   const SizedBox(height: 8),
                   Text(
                     "Encourage ${widget.child.name} to start learning!",
                     style: GoogleFonts.poppins(
                       fontSize: 14, 
                       color: colorScheme.onSurface.withOpacity(0.4)
                     ),
                   ),
                ],
              ),
            );
          }

          // Process Data
          final stats = _calculateStats(attempts);
          final recentSessions = attempts.take(5).toList(); // Last 5 attempts

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(context, 'All Time', true),
                      // Placeholder filters for now
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Performance Overview
                Text(
                  'Performance Overview',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Dynamically build cards based on available data categories
                if (stats.containsKey('English Alphabet'))
                  _buildPerformanceCard(
                    context: context,
                    title: "English Alphabet",
                    stats: stats['English Alphabet']!,
                    color: Colors.green,
                    icon: LucideIcons.bookOpen,
                  ),
                if (stats.containsKey('Numbers')) ...[
                  const SizedBox(height: 16),
                  _buildPerformanceCard(
                    context: context,
                    title: "Numbers",
                    stats: stats['Numbers']!,
                    color: Colors.blue,
                    icon: LucideIcons.calculator,
                  ),
                ],
                if (stats.containsKey('Other')) ...[
                   const SizedBox(height: 16),
                   _buildPerformanceCard(
                    context: context,
                    title: "Other Symbols",
                    stats: stats['Other']!,
                    color: Colors.amber,
                    icon: LucideIcons.shapes,
                  ),
                ],

                const SizedBox(height: 32),

                // Recent Activity
                Text(
                  'Recent Activity',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                
                ...recentSessions.map((attempt) {
                  return Column(
                    children: [
                      _buildSessionRow(context, attempt),
                      Divider(height: 32, color: theme.dividerColor),
                    ],
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, CategoryStats> _calculateStats(List<HandwritingAttempt> attempts) {
    final Map<String, CategoryStats> categories = {};

    for (var attempt in attempts) {
      String category = _getCategory(attempt.targetCharacter);
      
      if (!categories.containsKey(category)) {
        categories[category] = CategoryStats();
      }
      
      categories[category]!.addAttempt(attempt);
    }
    
    return categories;
  }

  String _getCategory(String char) {
    if (RegExp(r'[a-zA-Z]').hasMatch(char)) {
      return 'English Alphabet';
    }
    if (RegExp(r'[0-9]').hasMatch(char)) {
      return 'Numbers';
    }
    return 'Other';
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
    required CategoryStats stats,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accuracyStr = "${(stats.accuracy * 100).toInt()}%";

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
                        _buildMiniStat(context, "Accuracy", accuracyStr),
                        _buildMiniStat(context, "Attempts", "${stats.totalAttempts}"),
                        _buildMiniStat(context, "Best", stats.bestChar),
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
              value: stats.accuracy,
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

  Widget _buildSessionRow(BuildContext context, HandwritingAttempt attempt) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateStr = DateFormat('MMM d, h:mm a').format(attempt.createdAt);
    
    // Determine color based on score
    Color scoreColor = Colors.red;
    if (attempt.shapeSimilarity == 'high') {
      scoreColor = Colors.green;
    } else if (attempt.shapeSimilarity == 'medium') {
      scoreColor = Colors.amber;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Practiced '${attempt.targetCharacter}'", 
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateStr,
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
              attempt.shapeSimilarity.toUpperCase(),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: scoreColor,
              ),
            ),
            const SizedBox(height: 4),
            // Optional: Show confidence score bar or similar
          ],
        )
      ],
    );
  }
}

class CategoryStats {
  int totalAttempts = 0;
  int successfulAttempts = 0;
  String bestChar = '-'; // Character with highest success rate (simplified for now)

  // Map to track success per char to find 'best'
  // Map<String, int> charSuccesses = {};

  void addAttempt(HandwritingAttempt attempt) {
    totalAttempts++;
    if (attempt.shapeSimilarity == 'high' || attempt.shapeSimilarity == 'medium') {
      successfulAttempts++;
    }
  }

  double get accuracy => totalAttempts == 0 ? 0 : successfulAttempts / totalAttempts;
}
