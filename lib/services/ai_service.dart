import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/triage_result.dart' hide Color;
import '../models/action_item.dart';

class AIService {
  final String endpoint;
  final String model;
  final String? apiKey;

  AIService({
    required this.endpoint,
    required this.model,
    this.apiKey,
  });

  /// Classify an alert — uses AI endpoint if configured, otherwise local heuristics
  Future<TriageResult> triageAlert(String alertText) async {
    if (apiKey != null && apiKey!.isNotEmpty) {
      return _triageWithAI(alertText);
    }
    return _triageLocally(alertText);
  }

  Future<TriageResult> _triageWithAI(String alertText) async {
    try {
      final response = await http.post(
        Uri.parse('$endpoint/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are an SRE alert triage AI. Analyze the alert and respond with JSON: {"priority":"P0-P4","category":"infra|app|network|security|db","isNoise":bool,"summary":"...","recommendation":"...","confidence":0.0-1.0}'
            },
            {'role': 'user', 'content': alertText}
          ],
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final result = jsonDecode(content);
        return TriageResult(
          id: _generateId(),
          rawInput: alertText,
          priority: result['priority'] ?? 'P3',
          category: result['category'] ?? 'app',
          isNoise: result['isNoise'] ?? false,
          summary: result['summary'] ?? 'AI-generated summary',
          recommendation: result['recommendation'] ?? 'Review manually',
          confidence: (result['confidence'] as num?)?.toDouble() ?? 0.8,
        );
      }
    } catch (e) {
      // Fall back to local triage
    }
    return _triageLocally(alertText);
  }

  Future<TriageResult> _triageLocally(String alertText) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final lower = alertText.toLowerCase();

    String priority;
    String category;
    bool isNoise;
    String summary;
    String recommendation;
    double confidence;

    // Priority classification
    if (lower.contains('critical') ||
        lower.contains('outage') ||
        lower.contains('down') ||
        lower.contains('fatal') ||
        lower.contains('emergency')) {
      priority = 'P0';
      confidence = 0.92;
    } else if (lower.contains('error') ||
        lower.contains('failure') ||
        lower.contains('high cpu') ||
        lower.contains('memory leak') ||
        lower.contains('timeout')) {
      priority = 'P1';
      confidence = 0.87;
    } else if (lower.contains('warning') ||
        lower.contains('degraded') ||
        lower.contains('slow') ||
        lower.contains('latency')) {
      priority = 'P2';
      confidence = 0.83;
    } else if (lower.contains('info') ||
        lower.contains('notice') ||
        lower.contains('resolved') ||
        lower.contains('recovered')) {
      priority = 'P4';
      confidence = 0.78;
    } else {
      priority = 'P3';
      confidence = 0.72;
    }

    // Category classification
    if (lower.contains('cpu') ||
        lower.contains('memory') ||
        lower.contains('disk') ||
        lower.contains('node') ||
        lower.contains('pod') ||
        lower.contains('kubernetes') ||
        lower.contains('k8s') ||
        lower.contains('container') ||
        lower.contains('server')) {
      category = 'infra';
    } else if (lower.contains('network') ||
        lower.contains('dns') ||
        lower.contains('ssl') ||
        lower.contains('tls') ||
        lower.contains('connection') ||
        lower.contains('packet') ||
        lower.contains('latency')) {
      category = 'network';
    } else if (lower.contains('security') ||
        lower.contains('auth') ||
        lower.contains('unauthorized') ||
        lower.contains('breach') ||
        lower.contains('vulnerability') ||
        lower.contains('exploit')) {
      category = 'security';
    } else if (lower.contains('database') ||
        lower.contains('db') ||
        lower.contains('query') ||
        lower.contains('sql') ||
        lower.contains('postgres') ||
        lower.contains('mysql') ||
        lower.contains('redis') ||
        lower.contains('mongo')) {
      category = 'db';
    } else {
      category = 'app';
    }

    // Noise detection
    isNoise = lower.contains('test') ||
        lower.contains('heartbeat') ||
        lower.contains('flapping') ||
        lower.contains('auto-resolved') ||
        (lower.contains('resolved') && lower.contains('info'));

    // Generate summary
    if (isNoise) {
      summary =
          'Noise alert detected. This appears to be a non-actionable alert (test/heartbeat/auto-resolved).';
      recommendation =
          'Consider suppressing this alert pattern. Add to noise filter rules.';
      priority = 'P4';
      confidence = 0.90;
    } else {
      summary = _generateSummary(alertText, priority, category);
      recommendation = _generateRecommendation(priority, category);
    }

    return TriageResult(
      id: _generateId(),
      rawInput: alertText,
      priority: priority,
      category: category,
      isNoise: isNoise,
      summary: summary,
      recommendation: recommendation,
      confidence: confidence,
    );
  }

  String _generateSummary(String alert, String priority, String category) {
    final truncated =
        alert.length > 100 ? '${alert.substring(0, 100)}...' : alert;
    return '$priority $category alert detected. $truncated';
  }

  String _generateRecommendation(String priority, String category) {
    switch (priority) {
      case 'P0':
        return 'IMMEDIATE ACTION REQUIRED. Page on-call engineer. Start incident bridge. Check $category dashboards and runbooks.';
      case 'P1':
        return 'Investigate within 15 minutes. Check $category monitoring. Review recent deployments and changes.';
      case 'P2':
        return 'Investigate within 1 hour. Review $category metrics and logs. Consider creating a ticket.';
      case 'P3':
        return 'Review during business hours. Add to $category backlog for investigation.';
      case 'P4':
        return 'Informational. Log for trend analysis. No immediate action needed.';
      default:
        return 'Review the alert and determine appropriate action.';
    }
  }

  /// Generate AI-recommended actions with escalation paths
  Future<List<ActionItem>> getRecommendedActions(
      TriageResult triageResult) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final actions = <ActionItem>[];

    switch (triageResult.priority) {
      case 'P0':
        actions.addAll([
          ActionItem(
            id: _generateId(),
            title: 'Page On-Call Engineer',
            description:
                'Immediately escalate to the on-call ${triageResult.category} engineer via PagerDuty.',
            type: 'immediate',
            escalationPath:
                'On-Call Engineer -> Team Lead -> Engineering Manager -> VP Engineering',
            steps: [
              'Trigger PagerDuty incident',
              'Start incident bridge call',
              'Post in #incidents Slack channel',
              'Begin impact assessment',
            ],
            priority: 'P0',
          ),
          ActionItem(
            id: _generateId(),
            title: 'Run Diagnostic Playbook',
            description:
                'Execute the ${triageResult.category} diagnostic runbook to gather initial data.',
            type: 'immediate',
            escalationPath: 'On-Call -> SRE Team Lead',
            steps: [
              'Check service health endpoints',
              'Review error logs (last 15 min)',
              'Check infrastructure metrics',
              'Verify recent deployments',
              'Test connectivity to dependencies',
            ],
            priority: 'P0',
          ),
        ]);
        break;
      case 'P1':
        actions.addAll([
          ActionItem(
            id: _generateId(),
            title: 'Investigate Root Cause',
            description:
                'Start investigating the ${triageResult.category} issue within 15 minutes.',
            type: 'immediate',
            escalationPath: 'On-Call -> Team Lead',
            steps: [
              'Review monitoring dashboards',
              'Check correlated alerts',
              'Analyze error patterns',
              'Identify affected services',
            ],
            priority: 'P1',
          ),
        ]);
        break;
      case 'P2':
        actions.addAll([
          ActionItem(
            id: _generateId(),
            title: 'Schedule Investigation',
            description:
                'Investigate ${triageResult.category} issue within 1 hour.',
            type: 'short-term',
            escalationPath: 'Engineer -> Team Lead (if unresolved in 2h)',
            steps: [
              'Review historical trends',
              'Check if known issue',
              'Gather diagnostic data',
              'Create JIRA ticket if needed',
            ],
            priority: 'P2',
          ),
        ]);
        break;
      default:
        actions.add(
          ActionItem(
            id: _generateId(),
            title: 'Log and Monitor',
            description:
                'Track this ${triageResult.category} alert for patterns.',
            type: 'long-term',
            escalationPath: 'Team backlog review',
            steps: [
              'Add to monitoring dashboard',
              'Review during next standup',
              'Update alert thresholds if needed',
            ],
            priority: triageResult.priority,
          ),
        );
    }

    return actions;
  }

  /// Generate a Slack-ready incident summary
  String generateSlackSummary(TriageResult triage, {String? incidentTitle}) {
    final emoji = _priorityEmoji(triage.priority);
    final noiseTag = triage.isNoise ? ' [NOISE]' : '';
    final title = incidentTitle ?? 'Alert Triage Report';

    return '''$emoji *$title*$noiseTag

*Priority:* ${triage.priority} (${triage.priorityLabel})
*Category:* ${triage.category.toUpperCase()}
*Confidence:* ${(triage.confidence * 100).toStringAsFixed(0)}%
*Noise:* ${triage.isNoise ? 'Yes - Consider suppressing' : 'No'}

*Summary:*
${triage.summary}

*Recommendation:*
${triage.recommendation}

---
_Generated by TriageFlow AI at ${DateTime.now().toUtc().toIso8601String()}_''';
  }

  String _priorityEmoji(String priority) {
    switch (priority) {
      case 'P0':
        return ':rotating_light:';
      case 'P1':
        return ':warning:';
      case 'P2':
        return ':large_yellow_circle:';
      case 'P3':
        return ':information_source:';
      case 'P4':
        return ':white_check_mark:';
      default:
        return ':question:';
    }
  }

  String _generateId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'tf-$now-$random';
  }
}
