import 'package:flutter/foundation.dart';
import '../models/triage_result.dart' hide Color;
import '../models/action_item.dart';
import '../services/ai_service.dart';

class TriageProvider extends ChangeNotifier {
  final List<TriageResult> _results = [];
  TriageResult? _currentResult;
  List<ActionItem> _currentActions = [];
  bool _isTriaging = false;
  bool _isLoadingActions = false;
  String? _error;
  String _slackSummary = '';

  List<TriageResult> get results => List.unmodifiable(_results);
  TriageResult? get currentResult => _currentResult;
  List<ActionItem> get currentActions => _currentActions;
  bool get isTriaging => _isTriaging;
  bool get isLoadingActions => _isLoadingActions;
  String? get error => _error;
  String get slackSummary => _slackSummary;

  AIService _getService(
      {String endpoint = 'https://api.openai.com/v1',
      String model = 'gpt-4',
      String? apiKey}) {
    return AIService(endpoint: endpoint, model: model, apiKey: apiKey);
  }

  Future<void> triageAlert(String alertText,
      {String? endpoint, String? model, String? apiKey}) async {
    _isTriaging = true;
    _error = null;
    notifyListeners();

    try {
      final service = _getService(
        endpoint: endpoint ?? 'https://api.openai.com/v1',
        model: model ?? 'gpt-4',
        apiKey: apiKey,
      );
      _currentResult = await service.triageAlert(alertText);
      _results.insert(0, _currentResult!);

      // Auto-generate slack summary
      _slackSummary = service.generateSlackSummary(_currentResult!);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isTriaging = false;
      notifyListeners();
    }
  }

  Future<void> loadActions() async {
    if (_currentResult == null) return;

    _isLoadingActions = true;
    notifyListeners();

    try {
      final service = _getService();
      _currentActions = await service.getRecommendedActions(_currentResult!);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingActions = false;
      notifyListeners();
    }
  }

  void generateSlackSummary({String? incidentTitle}) {
    if (_currentResult == null) return;
    final service = _getService();
    _slackSummary = service.generateSlackSummary(
      _currentResult!,
      incidentTitle: incidentTitle,
    );
    notifyListeners();
  }

  void selectResult(TriageResult result) {
    _currentResult = result;
    final service = _getService();
    _slackSummary = service.generateSlackSummary(result);
    notifyListeners();
  }

  void clearCurrent() {
    _currentResult = null;
    _currentActions = [];
    _slackSummary = '';
    _error = null;
    notifyListeners();
  }

  void clearAll() {
    _results.clear();
    clearCurrent();
  }
}
