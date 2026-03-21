import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/triage_result.dart' hide Color;
import '../models/incident.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<TriageResult> _savedTriages = [];
  final List<Incident> _savedIncidents = [];

  List<TriageResult> get savedTriages => List.unmodifiable(_savedTriages);
  List<Incident> get savedIncidents => List.unmodifiable(_savedIncidents);
  int get totalCount => _savedTriages.length + _savedIncidents.length;

  bool isTriageSaved(String id) =>
      _savedTriages.any((t) => t.id == id);

  bool isIncidentSaved(String id) =>
      _savedIncidents.any((i) => i.id == id);

  void toggleTriage(TriageResult triage) {
    final index = _savedTriages.indexWhere((t) => t.id == triage.id);
    if (index >= 0) {
      _savedTriages.removeAt(index);
    } else {
      _savedTriages.insert(0, triage);
    }
    _persist();
    notifyListeners();
  }

  void toggleIncident(Incident incident) {
    final index = _savedIncidents.indexWhere((i) => i.id == incident.id);
    if (index >= 0) {
      _savedIncidents.removeAt(index);
    } else {
      _savedIncidents.insert(0, incident);
    }
    _persist();
    notifyListeners();
  }

  Future<void> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();

    final triagesJson = prefs.getString('saved_triages');
    if (triagesJson != null) {
      final list = jsonDecode(triagesJson) as List;
      _savedTriages
        ..clear()
        ..addAll(list.map((e) => TriageResult.fromJson(e)));
    }

    final incidentsJson = prefs.getString('saved_incidents');
    if (incidentsJson != null) {
      final list = jsonDecode(incidentsJson) as List;
      _savedIncidents
        ..clear()
        ..addAll(list.map((e) => Incident.fromJson(e)));
    }

    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'saved_triages',
      jsonEncode(_savedTriages.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      'saved_incidents',
      jsonEncode(_savedIncidents.map((e) => e.toJson()).toList()),
    );
  }

  void clearAll() {
    _savedTriages.clear();
    _savedIncidents.clear();
    _persist();
    notifyListeners();
  }
}
