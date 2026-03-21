import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceLight = Color(0xFF1C2128);
  static const Color border = Color(0xFF30363D);
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color accent = Color(0xFF00C853);
  static const Color accentDark = Color(0xFF00A844);

  // Priority colors
  static const Color p0 = Color(0xFFFF1744);
  static const Color p1 = Color(0xFFFF9100);
  static const Color p2 = Color(0xFFFFEA00);
  static const Color p3 = Color(0xFF00E5FF);
  static const Color p4 = Color(0xFF69F0AE);

  // Status colors
  static const Color open = Color(0xFFFF1744);
  static const Color investigating = Color(0xFFFF9100);
  static const Color mitigated = Color(0xFFFFEA00);
  static const Color resolved = Color(0xFF69F0AE);

  // Category colors
  static const Color infra = Color(0xFF448AFF);
  static const Color app = Color(0xFFAB47BC);
  static const Color network = Color(0xFF26C6DA);
  static const Color security = Color(0xFFFF5252);
  static const Color db = Color(0xFFFFCA28);

  static Color getPriorityColor(String priority) {
    switch (priority) {
      case 'P0':
        return p0;
      case 'P1':
        return p1;
      case 'P2':
        return p2;
      case 'P3':
        return p3;
      case 'P4':
        return p4;
      default:
        return textSecondary;
    }
  }

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'infra':
        return infra;
      case 'app':
        return app;
      case 'network':
        return network;
      case 'security':
        return security;
      case 'db':
        return db;
      default:
        return textSecondary;
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return open;
      case 'investigating':
        return investigating;
      case 'mitigated':
        return mitigated;
      case 'resolved':
        return resolved;
      default:
        return textSecondary;
    }
  }
}

class AppStrings {
  static const String appName = 'TriageFlow AI';
  static const String tagline = 'Intelligent Alert Triage for SRE Teams';

  static const List<String> priorities = ['P0', 'P1', 'P2', 'P3', 'P4'];
  static const List<String> categories = [
    'infra',
    'app',
    'network',
    'security',
    'db'
  ];
  static const List<String> statuses = [
    'open',
    'investigating',
    'mitigated',
    'resolved'
  ];

  static const String defaultEndpoint = 'https://api.openai.com/v1';
  static const String defaultModel = 'gpt-4';
}
