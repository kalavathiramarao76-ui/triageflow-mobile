# TriageFlow AI

**Intelligent Alert Triage for SRE Teams**

A Flutter mobile app that uses AI to classify, prioritize, and manage production alerts — helping SRE teams cut through noise and respond faster.

## Screenshots

| Splash | Home | Triage | Incidents |
|--------|------|--------|-----------|
| Animated logo | Tool cards dashboard | AI classification | Timeline view |

## Features

### 9 Screens
1. **Splash** — Animated logo with terminal-style branding
2. **Onboarding** — 3-page SRE walkthrough
3. **Home** — Dashboard with tool cards (Triage, Incidents, Favorites, Settings)
4. **Triage** — Paste alert JSON/text, AI classifies priority (P0-P4), category (infra/app/network/security/db), noise detection
5. **Incidents** — Create incidents from triaged alerts, full timeline view
6. **Actions** — AI action recommender with escalation paths and step-by-step playbooks
7. **Slack Summary** — Generate Slack-ready incident updates with copy/share
8. **Favorites** — Saved triages and incidents
9. **Settings** — API endpoint, model selection, theme toggle, clear data

### AI Capabilities
- **Priority Classification**: P0 (Critical) through P4 (Info)
- **Category Detection**: Infrastructure, Application, Network, Security, Database
- **Noise Filtering**: Identifies heartbeats, test alerts, auto-resolved events
- **Action Recommendations**: Escalation paths, diagnostic playbooks, step-by-step guides
- **Slack Integration**: Formatted incident summaries ready for #incidents channel

### Design
- Material 3 dark theme
- Green/red severity accent colors
- JetBrains Mono monospace for terminal-style code display
- Smooth animations with flutter_animate

## Tech Stack

- **Flutter** with Material 3
- **Provider** for state management
- **http** for AI API calls
- **shared_preferences** for local persistence
- **google_fonts** for JetBrains Mono & Inter
- **flutter_animate** for micro-interactions
- **share_plus** for system share sheet

## Getting Started

```bash
flutter pub get
flutter run
```

### AI Configuration
1. Open Settings
2. Set your API endpoint (OpenAI-compatible)
3. Enter your API key
4. Select model (default: gpt-4)

Without an API key, the app uses built-in heuristic triage (keyword-based classification).

## Architecture

```
lib/
├── main.dart                 # App entry, theme, providers
├── models/
│   ├── triage_result.dart    # Triage data model
│   ├── incident.dart         # Incident + timeline models
│   └── action_item.dart      # Action recommendation model
├── providers/
│   ├── triage_provider.dart  # Triage state management
│   ├── incident_provider.dart # Incident lifecycle
│   ├── favorites_provider.dart # Saved items persistence
│   └── settings_provider.dart  # App configuration
├── services/
│   └── ai_service.dart       # AI triage + local heuristics
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── home_screen.dart
│   ├── triage_screen.dart
│   ├── incidents_screen.dart
│   ├── actions_screen.dart
│   ├── slack_summary_screen.dart
│   ├── favorites_screen.dart
│   └── settings_screen.dart
├── widgets/
│   └── priority_badge.dart   # Reusable badge components
└── utils/
    └── constants.dart        # Colors, strings, config
```

## License

MIT
