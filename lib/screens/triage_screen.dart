import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../providers/triage_provider.dart';
import '../providers/incident_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/settings_provider.dart';
import 'actions_screen.dart';
import 'slack_summary_screen.dart';

class TriageScreen extends StatefulWidget {
  const TriageScreen({super.key});

  @override
  State<TriageScreen> createState() => _TriageScreenState();
}

class _TriageScreenState extends State<TriageScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  final List<String> _sampleAlerts = [
    '{"alert":"CriticalCPUUsage","severity":"critical","host":"prod-api-01","cpu_percent":98.7,"duration":"5m","service":"payment-gateway"}',
    'WARNING: Database connection pool exhausted on prod-db-primary. Active connections: 500/500. Queries queuing.',
    'ALERT: Network latency spike detected. p99 latency: 2300ms (threshold: 500ms). Affected: us-east-1 region.',
    'SecurityAlert: Multiple failed SSH login attempts detected on bastion-host-01. Source: 203.0.113.42. Count: 847 in last 10 minutes.',
    'INFO: Auto-scaling group web-tier scaled from 4 to 8 instances. Trigger: CPU > 70% for 3 minutes. Status: healthy.',
    'HEARTBEAT: Service health-checker reporting OK. All 23 endpoints responding. This is an automated test message.',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _runTriage() {
    if (_controller.text.trim().isEmpty) return;
    final settings = context.read<SettingsProvider>();
    context.read<TriageProvider>().triageAlert(
          _controller.text.trim(),
          endpoint: settings.endpoint,
          model: settings.model,
          apiKey: settings.apiKey.isNotEmpty ? settings.apiKey : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final triageProvider = context.watch<TriageProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Triage Alert',
          style: GoogleFonts.jetBrainsMono(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          if (triageProvider.currentResult != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                triageProvider.clearCurrent();
                _controller.clear();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input section
            Text(
              'Paste Alert',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'JSON, raw text, or log snippet',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 6,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '{"alert": "HighCPU", "severity": "critical"...}',
                hintStyle: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste_rounded,
                      color: AppColors.textSecondary),
                  onPressed: () async {
                    final data = await Clipboard.getData('text/plain');
                    if (data?.text != null) {
                      _controller.text = data!.text!;
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Sample alerts
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _sampleAlerts.length,
                itemBuilder: (context, index) {
                  final labels = [
                    'CPU Critical',
                    'DB Pool',
                    'Network',
                    'Security',
                    'Auto-scale',
                    'Heartbeat'
                  ];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(
                        labels[index],
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      backgroundColor: AppColors.surface,
                      side: const BorderSide(color: AppColors.border),
                      onPressed: () {
                        _controller.text = _sampleAlerts[index];
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Triage button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: triageProvider.isTriaging ? null : _runTriage,
                icon: triageProvider.isTriaging
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(Icons.bolt_rounded),
                label: Text(
                  triageProvider.isTriaging
                      ? 'Analyzing...'
                      : 'Run AI Triage',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            // Error
            if (triageProvider.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.p0.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppColors.p0.withOpacity(0.3)),
                  ),
                  child: Text(
                    triageProvider.error!,
                    style: GoogleFonts.inter(
                        color: AppColors.p0, fontSize: 13),
                  ),
                ),
              ),

            // Results
            if (triageProvider.currentResult != null) ...[
              const SizedBox(height: 28),
              _buildResultCard(context, triageProvider),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, TriageProvider provider) {
    final result = provider.currentResult!;
    final priorityColor = AppColors.getPriorityColor(result.priority);
    final categoryColor = AppColors.getCategoryColor(result.category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Priority & Category header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: priorityColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Priority badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: priorityColor.withOpacity(0.4)),
                    ),
                    child: Text(
                      '${result.priority} - ${result.priorityLabel}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: priorityColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      result.category.toUpperCase(),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Favorite button
                  Consumer<FavoritesProvider>(
                    builder: (context, favs, _) {
                      final isSaved = favs.isTriageSaved(result.id);
                      return IconButton(
                        icon: Icon(
                          isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: isSaved
                              ? AppColors.accent
                              : AppColors.textSecondary,
                        ),
                        onPressed: () => favs.toggleTriage(result),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Noise indicator
              if (result.isNoise)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.p2.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppColors.p2.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.noise_aware_rounded,
                          color: AppColors.p2, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'NOISE DETECTED - Consider suppressing',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: AppColors.p2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              // Confidence
              Row(
                children: [
                  Text(
                    'Confidence:',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: result.confidence,
                        backgroundColor: AppColors.border,
                        color: priorityColor,
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(result.confidence * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 13,
                      color: priorityColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Summary
              Text(
                'Summary',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                result.summary,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              // Recommendation
              Text(
                'Recommendation',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  result.recommendation,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    color: AppColors.accent,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

        const SizedBox(height: 16),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  provider.loadActions();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ActionsScreen()),
                  );
                },
                icon: const Icon(Icons.lightbulb_outline_rounded),
                label: const Text('Actions'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  side: const BorderSide(color: AppColors.accent),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SlackSummaryScreen()),
                  );
                },
                icon: const Icon(Icons.send_rounded),
                label: const Text('Slack'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.p3,
                  side: const BorderSide(color: AppColors.p3),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  context
                      .read<IncidentProvider>()
                      .createFromTriage(result);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Incident created',
                        style: GoogleFonts.inter(),
                      ),
                      backgroundColor: AppColors.accent,
                    ),
                  );
                },
                icon: const Icon(Icons.add_alert_rounded, size: 18),
                label: const Text('Incident'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.p1,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
      ],
    );
  }
}
