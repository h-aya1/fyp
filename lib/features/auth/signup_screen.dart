import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import '../../core/audio_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSignup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    audioService.playClick();
    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (mounted) {
        if (response.user != null) {
          // Success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created! Please log in.'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back to login
          Navigator.pop(context);
        } else {
          throw 'Signup failed';
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup Failed: ${e.message}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                  : [const Color(0xFFF0F9FF), const Color(0xFFBAE6FD)],
              ),
            ),
          ),
          
          // Floating Bubbles (reuse same style)
          ..._buildFloatingBubbles(context),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Back Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(LucideIcons.arrowLeft),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ).animate().fadeIn(),

                    const SizedBox(height: 16),

                    // Icon
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? colorScheme.surface : const Color(0xFF1F2937),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF60A5FA).withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          LucideIcons.userPlus,
                          size: 48,
                          color: isDark ? Colors.blue.shade400 : Colors.white,
                        ),
                      ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                    ),
                    
                    const SizedBox(height: 24),

                    Text(
                      'Join the Family!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 32),

                    // Form Container
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _emailController,
                            hint: 'Parent Email',
                            icon: LucideIcons.mail,
                            delay: 400.ms,
                            theme: theme,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _passwordController,
                            hint: 'Password (min 6 chars)',
                            icon: LucideIcons.lock,
                            isPassword: true,
                            delay: 550.ms,
                            theme: theme,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _confirmPasswordController,
                            hint: 'Confirm Password',
                            icon: LucideIcons.checkCircle,
                            isPassword: true,
                            delay: 700.ms,
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),

                    // Sign Up Button
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                         boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF60A5FA).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)], // Blue gradient
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoading 
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                            )
                          : Text(
                              'Create Account',
                              style: GoogleFonts.fredoka(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                      ),
                    ).animate().fadeIn(delay: 850.ms).scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOut),

                    const SizedBox(height: 24),
                    
                     Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: GoogleFonts.comicNeue(
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Log in',
                            style: GoogleFonts.comicNeue(
                              color: const Color(0xFF2563EB),
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 1000.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers reused from login_screen ---

  List<Widget> _buildFloatingBubbles(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double opacity = isDark ? 0.12 : 0.3;
    return [
      _buildBubble(top: -40, left: -40, size: 200, color: const Color(0xFF60A5FA).withOpacity(opacity)),
      _buildBubble(bottom: 50, right: -20, size: 160, color: const Color(0xFFA78BFA).withOpacity(opacity)),
      _buildBubble(top: 150, right: 20, size: 80, color: const Color(0xFFF472B6).withOpacity(opacity)),
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
       .moveY(begin: 0, end: 15, duration: (2 + (size % 3)).seconds, curve: Curves.easeInOut),
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
         boxShadow: [ // Subtle inner shadow feel
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
