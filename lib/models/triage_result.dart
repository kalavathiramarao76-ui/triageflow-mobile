class TriageResult {
  final String id;
  final String rawInput;
  final String priority; // P0-P4
  final String category; // infra, app, network, security, db
  final bool isNoise;
  final String summary;
  final String recommendation;
  final double confidence;
  final DateTime timestamp;

  TriageResult({
    required this.id,
    required this.rawInput,
    required this.priority,
    required this.category,
    required this.isNoise,
    required this.summary,
    required this.recommendation,
    required this.confidence,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Color get priorityColor {
    switch (priority) {
      case 'P0':
        return const Color(0xFFFF1744);
      case 'P1':
        return const Color(0xFFFF9100);
      case 'P2':
        return const Color(0xFFFFEA00);
      case 'P3':
        return const Color(0xFF00E5FF);
      case 'P4':
        return const Color(0xFF69F0AE);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String get priorityLabel {
    switch (priority) {
      case 'P0':
        return 'CRITICAL';
      case 'P1':
        return 'HIGH';
      case 'P2':
        return 'MEDIUM';
      case 'P3':
        return 'LOW';
      case 'P4':
        return 'INFO';
      default:
        return 'UNKNOWN';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'rawInput': rawInput,
        'priority': priority,
        'category': category,
        'isNoise': isNoise,
        'summary': summary,
        'recommendation': recommendation,
        'confidence': confidence,
        'timestamp': timestamp.toIso8601String(),
      };

  factory TriageResult.fromJson(Map<String, dynamic> json) => TriageResult(
        id: json['id'],
        rawInput: json['rawInput'],
        priority: json['priority'],
        category: json['category'],
        isNoise: json['isNoise'],
        summary: json['summary'],
        recommendation: json['recommendation'],
        confidence: (json['confidence'] as num).toDouble(),
        timestamp: DateTime.parse(json['timestamp']),
      );
}

// Using int color values to avoid flutter import in model
class Color {
  final int value;
  const Color(this.value);
}
