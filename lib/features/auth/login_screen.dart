
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../dashboard/parent_home_screen.dart';
import '../../core/audio_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    audioService.playClick();
    setState(() => _isLoading = true);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ParentHomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // --- Lively Background ---
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark 
                  ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                  : [const Color(0xFFF0F9FF), const Color(0xFFBAE6FD)], // Soft baby blue
              ),
            ),
          ),
          
          // Floating Bubbles (Decorative)
          ..._buildFloatingBubbles(context),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo with "Pulse" and "Bounce"
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark ? colorScheme.surface : const Color(0xFF1F2937),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 25,
                              offset: const Offset(0, 15),
                            ),
                            BoxShadow(
                              color: const Color(0xFF4ADE80).withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          LucideIcons.graduationCap,
                          size: 56,
                          color: isDark ? colorScheme.primary : Colors.white,
                        ),
                      ).animate(onPlay: (c) => c.repeat(reverse: true))
                       .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 2.seconds, curve: Curves.easeInOut)
                       .animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
                    ),
                    
                    const SizedBox(height: 32),

                    // Title with Gradient-like Feel
                    Text(
                      'Welcome Home!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A), // Darker for better contrast
                        letterSpacing: 1,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutBack),
                    
                    const SizedBox(height: 8),
                    Text(
                      'Ready to learn something new today?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.comicNeue(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? colorScheme.onSurface.withOpacity(0.7) : const Color(0xFF334155),
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutBack),
                    
                    const SizedBox(height: 32),

                    // Form Container with Glassmorphic Feel
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.4), // Slightly more visible glass
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _emailController,
                            hint: 'Parent Email',
                            icon: LucideIcons.mail,
                            delay: 600.ms,
                            theme: theme,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _passwordController,
                            hint: 'Password',
                            icon: LucideIcons.lock,
                            isPassword: true,
                            delay: 750.ms,
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot password?',
                          style: GoogleFonts.comicNeue(
                            color: const Color(0xFF16A34A), // Richer green
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 900.ms),
                    
                    const SizedBox(height: 24),

                    // Log In Button - Vibrant Gradient
                    Container(
                      height: 68,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(34),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4ADE80).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(34),
                          ),
                        ),
                        child: _isLoading 
                          ? const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 4),
                            )
                          : Text(
                              'Let\'s Go! 🚀',
                              style: GoogleFonts.fredoka(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                      ),
                    ).animate().fadeIn(delay: 1.seconds).scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut),
                    
                    const SizedBox(height: 32),
                    
                    // Social
                    Text(
                      'Or continue with',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.comicNeue(
                         color: isDark ? Colors.white54 : const Color(0xFF64748B),
                         fontWeight: FontWeight.w900,
                         fontSize: 14,
                      ),
                    ).animate().fadeIn(delay: 1200.ms),
                    
                    const SizedBox(height: 20),
                    
                    SizedBox(
                      height: 60,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.8),
                          side: BorderSide(color: isDark ? Colors.white10 : Colors.blue.withOpacity(0.1), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          foregroundColor: colorScheme.onSurface,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24),
                                children: [
                                  TextSpan(text: 'G', style: TextStyle(color: Colors.blue.shade600)),
                                  TextSpan(text: 'o', style: TextStyle(color: Colors.red.shade600)),
                                  TextSpan(text: 'o', style: TextStyle(color: Colors.yellow.shade700)),
                                  TextSpan(text: 'g', style: TextStyle(color: Colors.blue.shade600)),
                                  TextSpan(text: 'l', style: TextStyle(color: Colors.green.shade600)),
                                  TextSpan(text: 'e', style: TextStyle(color: Colors.red.shade600)),
                                  const TextSpan(text: '  ', style: TextStyle(fontSize: 10)),
                                  TextSpan(text: 'Sign in', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 18, fontWeight: FontWeight.normal)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 1400.ms).slideY(begin: 0.3, end: 0, curve: Curves.easeOutBack),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingBubbles(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double opacity = isDark ? 0.12 : 0.3; // Increased opacity for visibility
    return [
      _buildBubble(top: -40, right: -40, size: 240, color: const Color(0xFF4ADE80).withOpacity(opacity)),
      _buildBubble(bottom: 100, left: -60, size: 200, color: const Color(0xFF60A5FA).withOpacity(opacity)),
      _buildBubble(top: 200, left: -20, size: 100, color: const Color(0xFFFACC15).withOpacity(opacity)),
      _buildBubble(bottom: -20, right: 30, size: 140, color: const Color(0xFFF87171).withOpacity(opacity)),
    ];
  }

  Widget _buildBubble({double? top, double? bottom, double? left, double? right, required double size, required Color color}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true))
       .moveY(begin: 0, end: 20, duration: (2 + (size % 3)).seconds, curve: Curves.easeInOut)
       .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: (size / 50).seconds, curve: Curves.easeInOut),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    required Duration delay,
    required ThemeData theme,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.cardTheme.color : Colors.grey.shade50,
         borderRadius: BorderRadius.circular(30),
         boxShadow: [
           BoxShadow(
             color: Colors.black.withOpacity(0.03),
             blurRadius: 10,
             offset: const Offset(0, 4),
           ),
         ],
         border: isDark ? Border.all(color: theme.dividerColor) : null,
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: GoogleFonts.comicNeue(
          fontSize: 18, 
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.comicNeue(color: isDark ? theme.colorScheme.onSurface.withOpacity(0.4) : Colors.grey.shade400),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(icon, color: isDark ? theme.colorScheme.primary : Colors.grey.shade400, size: 22),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    ).animate().fadeIn(delay: delay).slideX(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }
}
