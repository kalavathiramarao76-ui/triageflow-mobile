class Incident {
  final String id;
  final String title;
  final String description;
  final String severity; // P0-P4
  final String status; // open, investigating, mitigated, resolved
  final String? triageResultId;
  final List<TimelineEntry> timeline;
  final DateTime createdAt;
  final DateTime updatedAt;

  Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    this.status = 'open',
    this.triageResultId,
    List<TimelineEntry>? timeline,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : timeline = timeline ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Incident copyWith({
    String? title,
    String? description,
    String? severity,
    String? status,
    List<TimelineEntry>? timeline,
  }) {
    return Incident(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      triageResultId: triageResultId,
      timeline: timeline ?? this.timeline,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'severity': severity,
        'status': status,
        'triageResultId': triageResultId,
        'timeline': timeline.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Incident.fromJson(Map<String, dynamic> json) => Incident(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        severity: json['severity'],
        status: json['status'] ?? 'open',
        triageResultId: json['triageResultId'],
        timeline: (json['timeline'] as List?)
                ?.map((e) => TimelineEntry.fromJson(e))
                .toList() ??
            [],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );
}

class TimelineEntry {
  final String id;
  final String action;
  final String description;
  final DateTime timestamp;

  TimelineEntry({
    required this.id,
    required this.action,
    required this.description,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'action': action,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
      };

  factory TimelineEntry.fromJson(Map<String, dynamic> json) => TimelineEntry(
        id: json['id'],
        action: json['action'],
        description: json['description'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}
