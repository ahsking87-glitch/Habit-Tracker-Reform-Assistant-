# Mīzān (ميزان) — Flutter Workspace

Offline-first Islamic Habit Tracker, Ethical Digital Wellbeing Shield, Multi-AI Gateway (BYOK), and Bounded Floating Companion (`Nūr • نور`).

## Visual Design System
- **Deep Background**: `#051210` with subtle 24px dotted gold geometric pattern (`rgba(207, 168, 89, 0.04)`)
- **Surfaces & Cards**: `#061814`, `#071D17`, `#09221B`, `#0D2822`
- **Primary Gold Accent**: `#CFA859` & Amber `#F59E0B`
- **Emerald Accent**: `#10B981`
- **Borders**: `#183E36` / `#064E3B`
- **Typography**: `Plus Jakarta Sans` (UI), `Cinzel` (Headings), `Amiri` (RTL Uthmani Arabic), `JetBrains Mono` (Code & Telemetry)

## Workspace Structure
- `lib/core/` — Theme, domain models, offline Adhan solar calculation engine, procedural 7-tone PCM audio synthesizer, Multi-AI Gateway HTTP client + offline matrix, Riverpod state providers, embedded Quran & knowledge datasets.
- `lib/features/` — Identical 10-module layout:
  1. Interactive App (`PhoneSimulatorScreen` with Salah, Shield, Quran, 24h Planner, Coach, Peer Accountability, Profile, and bounded `FloatingCompanionOverlay`)
  2. Multi-AI Gateway (`MultiAIGatewayScreen` for Gemini, OpenAI, Claude, DeepSeek, Offline Matrix)
  3. AI Floating Companion (`InteractiveCompanionScreen` workbench + 7 non-verbal soundboard)
  4. Al-Murshid AI Agent (`HolisticAIAgentScreen`)
  5. Quran & Sunnah (বাংলা/EN) (`MultilingualQuranScreen`)
  6. Habit Streaks & Badges (`StreaksAndRewardsScreen`)
  7. Identity & Security (`ProfileAuthScreen`)
  8. Source Code Explorer (`ArchitectureExplorerScreen`)
  9. System Diagrams (`SystemArchitectureDiagramScreen`)
  10. Ethical Constitution (`EthicalConstitutionScreen`)
- `android/` — Native Kotlin `ShortsBlockerAccessibilityService`, `FocusOverlayService`, `FloatingCompanionOverlayService`, `CompanionAudioPoolManager`, `ScreenTimeMonitorWorker`, `MainActivity`, and `AndroidManifest.xml`.
- `ios/` — Native Swift `ScreenTimeBridge` (`FamilyControls`, `ManagedSettings`, `DeviceActivity`) and `ShieldConfigurationExtension`.

## Getting Started
```bash
cd flutter_app
flutter pub get
flutter run
```
