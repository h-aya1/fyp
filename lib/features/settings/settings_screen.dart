import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _voiceAssistantEnabled = true; // Represented by volume for now
  double _volume = 0.75;
  bool _cameraAccess = true;
  bool _micAccess = true;
  String _selectedLanguage = 'English';
  String _selectedDifficulty = 'Medium';

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings & Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: theme.appBarTheme.foregroundColor,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: const SizedBox(), 
        automaticallyImplyLeading: false, 
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildSectionHeader('Parent Profile', theme),
          _buildSettingsTile(
            icon: LucideIcons.user,
            title: 'Edit Profile Details',
            subtitle: 'Update your personal information and contact details.',
            onTap: () {},
            theme: theme,
          ),
          _buildSettingsTile(
            icon: LucideIcons.lock,
            title: 'Change Password',
            subtitle: 'Keep your account secure by updating your password regularly.',
            onTap: () {},
            theme: theme,
          ),
          const SizedBox(height: 32),

          _buildSectionHeader('Child Profiles', theme),
          _buildSettingsTile(
            icon: LucideIcons.graduationCap,
            title: 'Manage Child Profiles',
            subtitle: 'Add, edit, or remove child accounts linked to your profile.',
            onTap: () {},
            theme: theme,
          ),
          _buildSettingsTile(
            icon: LucideIcons.plus,
            title: 'Add New Child',
            subtitle: 'Create a new learning profile for another child.',
            onTap: () {},
            theme: theme,
          ),
          const SizedBox(height: 32),

          _buildSectionHeader('App Settings', theme),
          _buildSwitchTile(
            icon: LucideIcons.moon,
            title: 'Dark Mode',
            subtitle: 'Enable dark theme for easier viewing at night.',
            value: appState.themeMode == ThemeMode.dark,
            onChanged: (val) => ref.read(appStateProvider.notifier).toggleTheme(val),
            theme: theme,
          ),
          _buildSettingsTile(
            icon: LucideIcons.bell,
            title: 'Notification Preferences',
            subtitle: 'Control when and how you receive app notifications.',
            onTap: () {},
            theme: theme,
          ),
          _buildDropdownTile(
            icon: LucideIcons.globe,
            title: 'Language Options',
            subtitle: 'Choose the primary display language for the parent app.',
            value: _selectedLanguage,
            items: ['English', 'Spanish', 'French'],
            onChanged: (val) => setState(() => _selectedLanguage = val!),
            theme: theme,
          ),
           _buildSliderTile(
            icon: LucideIcons.volume2,
            title: 'Voice Assistant Volume',
            subtitle: 'Adjust the volume level of the in-app voice assistant.',
            value: _volume,
            onChanged: (val) => setState(() => _volume = val),
            theme: theme,
          ),
          _buildDropdownTile(
            icon: LucideIcons.settings, // Cog icon
            title: 'Difficulty Level',
            subtitle: 'Set the default difficulty for learning sessions.',
            value: _selectedDifficulty,
            items: ['Easy', 'Medium', 'Hard'],
            onChanged: (val) => setState(() => _selectedDifficulty = val!),
            theme: theme,
          ),
          const SizedBox(height: 32),

          _buildSectionHeader('Permissions', theme),
          _buildSwitchTile(
            icon: LucideIcons.camera,
            title: 'Camera Access',
            subtitle: 'Allow LangoKids to use your device\'s camera for handwriting recognition.',
            value: _cameraAccess,
            onChanged: (val) => setState(() => _cameraAccess = val),
            theme: theme,
          ),
          _buildSwitchTile(
            icon: LucideIcons.mic,
            title: 'Microphone Access',
            subtitle: 'Grant access to the microphone for voice assistance and feedback.',
            value: _micAccess,
            onChanged: (val) => setState(() => _micAccess = val),
            theme: theme,
          ),

          const SizedBox(height: 32),

          _buildSectionHeader('Help & Support', theme),
           _buildSettingsTile(
            icon: LucideIcons.helpCircle,
            title: 'FAQ & Help Center',
            subtitle: 'Find answers to common questions and troubleshooting tips.',
            onTap: () {},
            theme: theme,
          ),
           _buildSettingsTile(
            icon: LucideIcons.messageSquare, // Or similar
            title: 'Contact Support',
            subtitle: 'Get in touch with our support team for personalized assistance.',
            onTap: () {},
            theme: theme,
          ),
           _buildSettingsTile(
            icon: LucideIcons.info,
            title: 'About LangoKids',
            subtitle: 'Learn more about the app, its mission, and version information.',
            onTap: () {},
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: theme.iconTheme.color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 20, color: theme.dividerColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: theme.iconTheme.color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: theme.iconTheme.color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isDense: true,
                dropdownColor: theme.cardTheme.color,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required ValueChanged<double> onChanged,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: theme.iconTheme.color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              SizedBox(
                width: 80, // Small width for slider
                child: SliderTheme(
                   data: SliderTheme.of(context).copyWith(
                    activeTrackColor: theme.colorScheme.primary,
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                   ),
                  child: Slider(
                    value: value,
                    onChanged: onChanged,
                  ),
                ),
              ),
              Text(
                '${(value * 100).toInt()}%',
                 style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
