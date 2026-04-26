# Poker Gambit 🃏

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-%232196F3.svg?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Flame](https://img.shields.io/badge/Flame-%23FF6B35.svg?style=for-the-badge&logo=flutter&logoColor=white)
![Gemini](https://img.shields.io/badge/Google%20Gemini-4285F4?style=for-the-badge&logo=google&logoColor=white)

**Poker Gambit** adalah game kartu strategi berbasis Flutter yang menggabungkan mekanik poker klasik dengan elemen interaktif modern. Pemain bertarung melawan AI yang didukung Google Gemini, dengan sistem kartu spesial, QTE (Quick Time Event), dan timer giliran yang membuat setiap ronde terasa menegangkan. Tampilan menggunakan dark-mode premium dengan desain glassmorphic dan animasi yang halus.

---

## ✨ Fitur Utama

### 🚀 Pengalaman Bermain
- **Onboarding Immersif**: Alur pengenalan yang memandu pemain baru.
- **Main Menu Premium**: Desain glassmorphic elegan dengan beberapa pilihan mode permainan.

### 🎮 Mekanik Gameplay
- **VS AI Mode**: Tantang AI dengan pengambilan keputusan strategis berbasis Gemini.
- **Kartu Spesial**: Tiga jenis efek kartu unik — Spy (intip kartu lawan), Witch (tukar kartu), dan Destroyer (hancurkan kartu).
- **QTE (Quick Time Event)**: Sistem "Counter/Block" interaktif untuk gameplay berbasis skill.
- **Turn Timer**: Timer real-time yang menambah tekanan di setiap giliran.
- **Fase Swap Kartu**: Pemain bisa menukar kartu sebelum showdown.

### 🎨 Visual & Audio
- **Dark Mode Premium**: Desain kaya dengan aksen warna vibrant dan animasi smooth.
- **Dynamic HUD**: Skor real-time, indikator giliran, dan pesan status interaktif.
- **Animasi Kartu**: Animasi draw dan discard yang fluid.
- **Sound Effects**: Audio feedback untuk setiap aksi dalam permainan.

---

## 🛠 Tech Stack & Library

| Kategori | Library | Versi | Keterangan |
|---|---|---|---|
| Framework | [Flutter](https://flutter.dev) | latest stable | Cross-platform UI framework |
| Language | [Dart](https://dart.dev) | ^3.11.4 | |
| State Management | [flutter_riverpod](https://riverpod.dev) | ^2.5.1 | Reactive state management |
| Code Generation | [riverpod_generator](https://pub.dev/packages/riverpod_generator) + [build_runner](https://pub.dev/packages/build_runner) | ^2.3.9 / ^2.4.8 | Generate Riverpod providers otomatis |
| AI Opponent | [google_generative_ai](https://pub.dev/packages/google_generative_ai) | ^0.4.7 | Gemini API untuk logika AI |
| Game Engine | [flame](https://flame-engine.org) | ^1.11.0 | Game loop & animasi |
| SVG Assets | [flutter_svg](https://pub.dev/packages/flutter_svg) | ^2.0.10+1 | Render kartu vektor resolusi independen |
| Typography | [google_fonts](https://pub.dev/packages/google_fonts) | ^6.1.0 | Font Outfit untuk UI game |
| Audio | [audioplayers](https://pub.dev/packages/audioplayers) | ^5.2.1 | Sound effects |
| Environment | [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) | ^6.0.1 | Manajemen API key via `.env` |
| Persistensi | [shared_preferences](https://pub.dev/packages/shared_preferences) | ^2.5.5 | Simpan high score lokal |
| Testing | [mocktail](https://pub.dev/packages/mocktail) + [fake_async](https://pub.dev/packages/fake_async) | ^1.0.4 / ^1.3.1 | Unit & widget testing |

---

## 🏗 Arsitektur

Project mengikuti prinsip **Clean Architecture** dengan pemisahan layer yang jelas, memastikan skalabilitas dan kemudahan maintenance.

```
lib/
├── core/
│   ├── constants/       # Konstanta game (GameConstants)
│   ├── theme/           # Design system & tema (GameTheme)
│   └── utils/           # Utility functions (CardUtils, TimeUtils)
│
├── features/
│   ├── game/
│   │   ├── data/
│   │   │   └── repositories/    # Implementasi repository (LocalGameRepository)
│   │   │
│   │   ├── domain/
│   │   │   ├── logic/
│   │   │   │   ├── card_effects/ # Efek kartu spesial (Spy, Witch, Destroyer)
│   │   │   │   └── poker_evaluator.dart  # Evaluasi hand poker
│   │   │   ├── models/          # CardModel, GameState, PokerHand
│   │   │   ├── repositories/    # Interface repository
│   │   │   ├── services/        # DeckService, PokerAiService (Gemini)
│   │   │   └── usecases/        # StartGame, PlayCard, SwapCards, EvaluateRound, dll.
│   │   │
│   │   └── presentation/
│   │       ├── controllers/     # SwapAnimationOrchestrator
│   │       ├── providers/       # GameNotifier (Riverpod) + GameTimerMixin
│   │       ├── screens/         # GameScreen
│   │       └── widgets/         # PokerTable, PlayerHand, OpponentArea, animasi, dll.
│   │
│   └── menu/
│       └── presentation/
│           ├── screens/         # OnboardingScreen, MainMenuScreen
│           └── widgets/         # RulesDialog
│
└── main.dart
```

### Alur Data

```
UI (Widget) → Provider (Riverpod) → UseCase → Repository / Service → Domain Model
```

- **Domain layer** murni Dart, tidak bergantung pada Flutter.
- **UseCase** mengenkapsulasi satu operasi bisnis (single responsibility).
- **Riverpod** sebagai jembatan antara domain dan UI, dengan `GameNotifier` sebagai pusat state game.
- **AI Service** memanggil Gemini API untuk menentukan aksi lawan secara dinamis.

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK ^3.11.4
- Android Studio / VS Code
- Google Gemini API Key

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd card_games
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Environment Setup**

   Buat file `.env` di root directory:

   ```env
   API_KEY=your_google_gemini_api_key
   ```

4. **Generate Code** (Riverpod)

   ```bash
   flutter pub run build_runner build
   ```

5. **Run the App**

   ```bash
   flutter run
   ```

6. **Run Tests**

   ```bash
   flutter test
   ```

---

## 📅 Roadmap

- [x] Onboarding Flow
- [x] Main Menu Implementation
- [x] VS AI Core Mechanics (Gemini)
- [x] Kartu Spesial (Spy, Witch, Destroyer)
- [x] QTE System
- [ ] VS Player (Local)
- [ ] Online Multiplayer
- [ ] Tournament Mode

---

## 👤 Author

**ssajudn** ft. **Antigravity**

---

Made by ssajudn ft. Antigravity.
