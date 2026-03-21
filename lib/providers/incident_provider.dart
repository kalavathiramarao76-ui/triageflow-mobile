import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/incident.dart';
import '../models/triage_result.dart' hide Color;

class IncidentProvider extends ChangeNotifier {
  final List<Incident> _incidents = [];
  Incident? _currentIncident;

  List<Incident> get incidents => List.unmodifiable(_incidents);
  Incident? get currentIncident => _currentIncident;

  List<Incident> get openIncidents =>
      _incidents.where((i) => i.status != 'resolved').toList();

  List<Incident> get resolvedIncidents =>
      _incidents.where((i) => i.status == 'resolved').toList();

  Incident createFromTriage(TriageResult triage) {
    final incident = Incident(
      id: 'INC-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999).toString().padLeft(3, '0')}',
      title: '${triage.priority} ${triage.category.toUpperCase()} Alert',
      description: triage.summary,
      severity: triage.priority,
      triageResultId: triage.id,
      timeline: [
        TimelineEntry(
          id: 'tle-${DateTime.now().millisecondsSinceEpoch}',
          action: 'created',
          description:
              'Incident created from triaged alert. Category: ${triage.category}, Confidence: ${(triage.confidence * 100).toStringAsFixed(0)}%',
        ),
      ],
    );

    _incidents.insert(0, incident);
    _currentIncident = incident;
    notifyListeners();
    return incident;
  }

  Incident createManual({
    required String title,
    required String description,
    required String severity,
  }) {
    final incident = Incident(
      id: 'INC-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999).toString().padLeft(3, '0')}',
      title: title,
      description: description,
      severity: severity,
      timeline: [
        TimelineEntry(
          id: 'tle-${DateTime.now().millisecondsSinceEpoch}',
          action: 'created',
          description: 'Incident manually created.',
        ),
      ],
    );

    _incidents.insert(0, incident);
    _currentIncident = incident;
    notifyListeners();
    return incident;
  }

  void updateStatus(String incidentId, String newStatus) {
    final index = _incidents.indexWhere((i) => i.id == incidentId);
    if (index == -1) return;

    final incident = _incidents[index];
    final updatedTimeline = List<TimelineEntry>.from(incident.timeline)
      ..add(TimelineEntry(
        id: 'tle-${DateTime.now().millisecondsSinceEpoch}',
        action: 'status_change',
        description: 'Status changed from ${incident.status} to $newStatus',
      ));

    _incidents[index] = incident.copyWith(
      status: newStatus,
      timeline: updatedTimeline,
    );

    if (_currentIncident?.id == incidentId) {
      _currentIncident = _incidents[index];
    }

    notifyListeners();
  }

  void addTimelineEntry(String incidentId, String action, String description) {
    final index = _incidents.indexWhere((i) => i.id == incidentId);
    if (index == -1) return;

    final incident = _incidents[index];
    final updatedTimeline = List<TimelineEntry>.from(incident.timeline)
      ..add(TimelineEntry(
        id: 'tle-${DateTime.now().millisecondsSinceEpoch}',
        action: action,
        description: description,
      ));

    _incidents[index] = incident.copyWith(timeline: updatedTimeline);

    if (_currentIncident?.id == incidentId) {
      _currentIncident = _incidents[index];
    }

    notifyListeners();
  }

  void selectIncident(Incident incident) {
    _currentIncident = incident;
    notifyListeners();
  }

  void clearAll() {
    _incidents.clear();
    _currentIncident = null;
    notifyListeners();
  }
}
