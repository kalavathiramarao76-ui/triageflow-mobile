import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../providers/settings_provider.dart';
import '../providers/triage_provider.dart';
import '../providers/incident_provider.dart';
import '../providers/favorites_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _endpointCtrl;
  late TextEditingController _modelCtrl;
  late TextEditingController _apiKeyCtrl;
  bool _showApiKey = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _endpointCtrl = TextEditingController(text: settings.endpoint);
    _modelCtrl = TextEditingController(text: settings.model);
    _apiKeyCtrl = TextEditingController(text: settings.apiKey);
  }

  @override
  void dispose() {
    _endpointCtrl.dispose();
    _modelCtrl.dispose();
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Clear All Data',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will clear all triages, incidents, favorites, and settings. This action cannot be undone.',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () {
              context.read<SettingsProvider>().clearAllData();
              context.read<TriageProvider>().clearAll();
              context.read<IncidentProvider>().clearAll();
              context.read<FavoritesProvider>().clearAll();
              _endpointCtrl.text = AppStrings.defaultEndpoint;
              _modelCtrl.text = AppStrings.defaultModel;
              _apiKeyCtrl.text = '';
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All data cleared',
                      style: GoogleFonts.inter()),
                  backgroundColor: AppColors.p0,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.p0,
              foregroundColor: Colors.white,
            ),
            child: Text('Clear', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Settings',
          style: GoogleFonts.jetBrainsMono(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // AI Configuration
          _buildSectionHeader('AI Configuration'),
          const SizedBox(height: 12),
          _buildSettingCard(
            children: [
              _buildTextField(
                label: 'API Endpoint',
                controller: _endpointCtrl,
                hint: 'https://api.openai.com/v1',
                icon: Icons.link_rounded,
                onChanged: (v) => settings.setEndpoint(v),
              ),
              const Divider(color: AppColors.border, height: 24),
              _buildTextField(
                label: 'Model',
                controller: _modelCtrl,
                hint: 'gpt-4',
                icon: Icons.smart_toy_rounded,
                onChanged: (v) => settings.setModel(v),
              ),
              const Divider(color: AppColors.border, height: 24),
              _buildTextField(
                label: 'API Key',
                controller: _apiKeyCtrl,
                hint: 'sk-...',
                icon: Icons.key_rounded,
                obscure: !_showApiKey,
                onChanged: (v) => settings.setApiKey(v),
                suffix: IconButton(
                  icon: Icon(
                    _showApiKey
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _showApiKey = !_showApiKey),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

          const SizedBox(height: 28),

          // Appearance
          _buildSectionHeader('Appearance'),
          const SizedBox(height: 12),
          _buildSettingCard(
            children: [
              Row(
                children: [
                  Icon(Icons.dark_mode_rounded,
                      color: AppColors.textSecondary, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    'Dark Mode',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: settings.isDarkMode,
                    onChanged: (_) => settings.toggleDarkMode(),
                    activeColor: AppColors.accent,
                  ),
                ],
              ),
            ],
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

          const SizedBox(height: 28),

          // Data Management
          _buildSectionHeader('Data Management'),
          const SizedBox(height: 12),
          _buildSettingCard(
            children: [
              GestureDetector(
                onTap: _clearAllData,
                child: Row(
                  children: [
                    Icon(Icons.delete_forever_rounded,
                        color: AppColors.p0, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      'Clear All Data',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: AppColors.p0,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded,
                        color: AppColors.textSecondary),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

          const SizedBox(height: 28),

          // About
          _buildSectionHeader('About'),
          const SizedBox(height: 12),
          _buildSettingCard(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.security_rounded,
                        color: AppColors.accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TriageFlow AI',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'v1.0.0',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Intelligent alert triage for SRE teams. AI-powered priority classification, noise detection, incident management, and Slack integration.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildSettingCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.4),
            ),
            suffixIcon: suffix,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
