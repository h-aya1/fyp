
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../main.dart';
import 'child_performance_screen.dart'; 
import 'parent_home_screen.dart'; 
import '../../core/audio_service.dart';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? theme.cardTheme.color : Colors.white.withOpacity(0.5), 
                      borderRadius: BorderRadius.circular(16),
                      border: isDark ? Border.all(color: theme.dividerColor) : null,
                    ),
                    child: Icon(LucideIcons.bookOpen, color: isDark ? colorScheme.primary : const Color(0xFF1F2937)),
                  ),
                   Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF4ADE80), width: 3),
                    ),
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=Parent'), 
                    ),
                  ),
                ],
              ).animate().fadeIn().slideY(begin: -0.2, end: 0),
              
              const SizedBox(height: 24),
              
              Text(
                'Welcome Back, Parent!',
                style: GoogleFonts.fredoka(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),

              const SizedBox(height: 24),

              // Notification Card (Gradient)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                      ? [theme.cardTheme.color!, theme.cardTheme.color!.withOpacity(0.8)]
                      : [const Color(0xFFFFEDD5), const Color(0xFFFED7AA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: isDark ? Border.all(color: theme.dividerColor) : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                           padding: const EdgeInsets.all(8),
                           decoration: BoxDecoration(
                             color: isDark ? colorScheme.surface.withOpacity(0.3) : Colors.white, 
                             shape: BoxShape.circle
                           ),
                           child: Icon(LucideIcons.bell, color: isDark ? colorScheme.secondary : const Color(0xFF9A3412), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'New Learning Games!',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? colorScheme.onSurface : const Color(0xFF7C2D12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Explore exciting new games to make learning Amharic and English even more fun.',
                      style: GoogleFonts.comicNeue(
                        color: isDark ? colorScheme.onSurface.withOpacity(0.8) : const Color(0xFF7C2D12),
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? colorScheme.primary.withOpacity(0.2) : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: isDark ? Border.all(color: colorScheme.primary.withOpacity(0.3)) : null,
                      ),
                      child: Text(
                        'Read More',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          color: isDark ? colorScheme.primary : const Color(0xFF9A3412),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms).scale(),
              
              const SizedBox(height: 32),

              // Your Children's Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    "Learner Progress",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                   Text(
                    "View All",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4ADE80),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Children List Component
              state.children.isEmpty 
               ? _buildEmptyChildrenState(context, ref)
               : SizedBox(
                  height: 250, 
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.children.length,
                    clipBehavior: Clip.none,
                    itemBuilder: (context, index) {
                      final child = state.children[index];
                      return Container(
                        width: 290,
                        margin: const EdgeInsets.only(right: 20),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundImage: NetworkImage(child.avatar),
                                  backgroundColor: isDark ? colorScheme.surface : Colors.grey.shade200,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        child.name,
                                        style: GoogleFonts.fredoka(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                           color: isDark ? colorScheme.primary.withOpacity(0.1) : const Color(0xFFDCFCE7),
                                           borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Score: 92%', 
                                          style: GoogleFonts.poppins(
                                            color: isDark ? colorScheme.primary : const Color(0xFF15803D),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            const Spacer(),
                            
                            // Progress Bar
                             Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Overall',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? colorScheme.onSurface.withOpacity(0.5) : Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '85%',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: 0.85,
                                  backgroundColor: isDark ? colorScheme.surface : Colors.grey[100],
                                  color: const Color(0xFF4ADE80), 
                                  minHeight: 10,
                                ),
                              ),
                              const SizedBox(height: 20),

                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                     onPressed: () {
                                       audioService.playClick();
                                       ref.read(appStateProvider.notifier).selectChild(child);
                                       Navigator.push(context, MaterialPageRoute(builder: (context) => ChildPerformanceScreen(child: child)));
                                    },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    side: BorderSide(color: theme.dividerColor),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: Text(
                                    'View Details',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ).animate(delay: (200 * index).ms).slideX(begin: 0.2, end: 0, curve: Curves.easeOut);
                    },
                  ),
                ),
                
              const SizedBox(height: 32),

              // Quick Actions Grid
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
                childAspectRatio: 1.5, 
                children: [
                  _buildActionCard(
                    icon: LucideIcons.users,
                    label: 'Enter Kids Mode',
                    startColor: const Color(0xFF60A5FA), 
                    endColor: const Color(0xFF3B82F6),
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    onTap: () {
                       ref.read(appStateProvider.notifier).updateTabIndex(1);
                    },
                  ),
                  _buildActionCard(
                    icon: LucideIcons.userPlus,
                    label: 'Add Child',
                    startColor: isDark ? colorScheme.surface : Colors.white,
                    endColor: isDark ? colorScheme.surface : Colors.grey.shade50,
                    iconColor: const Color(0xFF4ADE80),
                    textColor: colorScheme.onSurface,
                    isDark: isDark,
                    isOutlined: true,
                    onTap: () => _showAddDialog(context, ref),
                  ),
                  _buildActionCard(
                    icon: LucideIcons.fileText,
                    label: 'View Reports',
                    startColor: isDark ? colorScheme.surface : Colors.white,
                    endColor: isDark ? colorScheme.surface : Colors.grey.shade50,
                    iconColor: const Color(0xFFA78BFA),
                    textColor: colorScheme.onSurface,
                    isDark: isDark,
                    isOutlined: true,
                    onTap: () {},
                  ),
                  _buildActionCard(
                    icon: LucideIcons.gamepad2,
                    label: 'Browse Games',
                    startColor: isDark ? colorScheme.surface : Colors.white,
                    endColor: isDark ? colorScheme.surface : Colors.grey.shade50,
                    iconColor: const Color(0xFFFFD93D),
                    textColor: colorScheme.onSurface,
                    isDark: isDark,
                    isOutlined: true,
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

  Widget _buildEmptyChildrenState(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
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
          Container(
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(color: theme.colorScheme.surface, shape: BoxShape.circle),
             child: Icon(LucideIcons.users, size: 32, color: theme.colorScheme.onSurface.withOpacity(0.5)),
          ),
          const SizedBox(height: 16),
          Text(
            "Start the journey!",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            "Add your first learner to track progress.",
            style: GoogleFonts.poppins(color: theme.colorScheme.onSurface.withOpacity(0.6)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showAddDialog(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4ADE80),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
            child: const Text("Add a Child"),
          )
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color startColor,
    required Color endColor,
    required Color textColor,
    required Color iconColor,
    bool isOutlined = false,
    bool isDark = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [startColor, endColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          border: isOutlined ? Border.all(color: isDark ? const Color(0xFF1E40AF) : Colors.grey.shade200) : null,
          boxShadow: isOutlined ? [] : [
            BoxShadow(
              color: startColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isOutlined ? (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50) : Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: textColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    ).animate().scale();
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: isDark ? BorderSide(color: theme.dividerColor) : BorderSide.none),
        title: Text('Add Learner', style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
        content: TextField(
          controller: controller, 
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Child\'s Name',
            hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          )
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(appStateProvider.notifier).addChild(controller.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
               backgroundColor: const Color(0xFF4ADE80),
               foregroundColor: Colors.white,
               elevation: 0,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Add'),
          )
        ],
      ),
    );
  }
}
