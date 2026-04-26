# Poker Gambit 🃏

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-%232196F3.svg?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Gemini](https://img.shields.io/badge/Google%20Gemini-4285F4?style=for-the-badge&logo=google&logoColor=white)

**Poker Gambit** adalah game kartu strategi berbasis Flutter yang menggabungkan mekanik poker klasik dengan elemen interaktif modern. Pemain bertarung melawan AI yang didukung Google Gemini, dilengkapi sistem autentikasi Firebase, leaderboard global, dan sinkronisasi data offline-first.

---

## ✨ Fitur Utama

### 🔐 Autentikasi & User
- **Guest Mode**: Langsung bermain tanpa login, data tersimpan lokal.
- **Google Sign-In**: Login dengan akun Google untuk akses fitur penuh.
- **Upgrade Akun**: Guest bisa upgrade ke akun Google tanpa kehilangan data.
- **Offline-First**: Data tersimpan lokal dan otomatis sync ke Firebase saat online.

### 🎮 Gameplay
- **VS AI Mode**: Tantang AI dengan pengambilan keputusan strategis berbasis Gemini.
- **Kartu Spesial**: Tiga efek unik — Spy (intip kartu lawan), Witch (tukar kartu), Destroyer (hancurkan kartu).
- **QTE (Quick Time Event)**: Sistem Counter/Block interaktif berbasis skill.
- **Turn Timer**: Timer real-time yang menambah tekanan di setiap giliran.
- **Fase Swap Kartu**: Tukar kartu sebelum showdown.

### 🏆 Statistik & Leaderboard
- **Statistik Lengkap**: Tracking high score, total games, wins, losses, dan frekuensi tiap kombinasi kartu.
- **Global Leaderboard**: Papan peringkat top 10 pemain di seluruh dunia.
- **Sync Otomatis**: Data sinkronisasi ke Firestore saat kembali online.

### 🎨 Visual & UX
- **Dark Mode Premium**: Desain glassmorphic dengan aksen amber/gold.
- **Animasi Fluid**: Animasi draw, discard, dan transisi yang halus.
- **Onboarding**: Alur pengenalan untuk pemain baru (hanya tampil sekali).
- **Responsive**: Mendukung Android, iOS, Web, dan macOS.

---

## 🛠 Tech Stack

| Kategori | Library | Keterangan |
|---|---|---|
| Framework | [Flutter](https://flutter.dev) `latest` | Cross-platform UI |
| Language | [Dart](https://dart.dev) `^3.11.4` | |
| State Management | [flutter_riverpod](https://riverpod.dev) `^2.5.1` | Reactive state management |
| Auth | [firebase_auth](https://pub.dev/packages/firebase_auth) `^5.x` | Google Sign-In + Anonymous |
| Database | [cloud_firestore](https://pub.dev/packages/cloud_firestore) `^5.x` | Leaderboard & user stats |
| AI Opponent | [google_generative_ai](https://pub.dev/packages/google_generative_ai) `^0.4.7` | Gemini 2.5 Flash |
| Connectivity | [connectivity_plus](https://pub.dev/packages/connectivity_plus) `^6.x` | Offline-first sync |
| Local Storage | [shared_preferences](https://pub.dev/packages/shared_preferences) `^2.5.5` | Cache lokal |
| Typography | [google_fonts](https://pub.dev/packages/google_fonts) `^6.1.0` | Font Outfit |
| Audio | [audioplayers](https://pub.dev/packages/audioplayers) `^5.2.1` | Sound effects |
| SVG | [flutter_svg](https://pub.dev/packages/flutter_svg) `^2.0.10` | Kartu vektor |
| Environment | [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) `^6.0.1` | API key management |
| Code Gen | [riverpod_generator](https://pub.dev/packages/riverpod_generator) + [build_runner](https://pub.dev/packages/build_runner) | Generate providers |
| Testing | [mocktail](https://pub.dev/packages/mocktail) + [fake_async](https://pub.dev/packages/fake_async) | Unit testing |

---

## 🏗 Arsitektur

Project mengikuti **Clean Architecture** + **SOLID Principles** dengan pemisahan layer yang ketat.

```
lib/
├── core/
│   ├── config/          # AppConfig, AppInitializer
│   ├── constants/       # GameConstants
│   ├── providers/       # ConnectivityProvider
│   ├── services/        # ConnectivityService
│   ├── theme/           # GameTheme
│   ├── utils/           # CardUtils, TimeUtils
│   └── widgets/         # AppScaffold, SplashScreen, AutoGuestSignIn
│
├── features/
│   ├── auth/
│   │   ├── data/        # FirebaseAuthRepository
│   │   ├── domain/      # AppUser, IAuthRepository, UseCases
│   │   └── presentation/ # AuthProvider, AuthNotifier, ProfileBottomSheet
│   │
│   ├── game/
│   │   ├── data/        # LocalRepo, FirebaseRepo, OfflineFirstRepo
│   │   ├── domain/      # Models, Logic, Services, UseCases
│   │   └── presentation/ # GameNotifier, GameScreen, Widgets
│   │
│   ├── leaderboard/
│   │   ├── data/        # FirebaseLeaderboardRepository
│   │   ├── domain/      # LeaderboardEntry, ILeaderboardRepository
│   │   └── presentation/ # LeaderboardProvider, LeaderboardScreen
│   │
│   └── menu/
│       └── presentation/ # OnboardingScreen, MainMenuScreen, Widgets
│
└── main.dart
```

### Alur Data

```
UI → Provider (Riverpod) → UseCase → Repository → Domain Model
                                   ↓
                          Local (SharedPrefs) ←→ Remote (Firestore)
```

### Offline-First Strategy

```
saveGameResult()
  → simpan ke SharedPreferences (selalu)
  → jika online → sync ke Firestore
  → jika offline → set needsSync = true
  → saat kembali online → auto sync dengan conflict resolution "best wins"
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK `^3.11.4`
- Android Studio / VS Code
- Google Gemini API Key
- Firebase project (dengan Auth & Firestore diaktifkan)

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
   GEMINI_API_KEY=your_google_gemini_api_key
   ```

4. **Firebase Setup**

   - Tambah `google-services.json` ke `android/app/`
   - Tambah `GoogleService-Info.plist` ke `ios/Runner/` dan `macos/Runner/`
   - Update Firebase web config di `web/index.html`

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
- [x] Main Menu
- [x] VS AI (Gemini 2.5 Flash)
- [x] Kartu Spesial (Spy, Witch, Destroyer)
- [x] QTE System
- [x] Firebase Auth (Google + Anonymous)
- [x] Offline-First Data Sync
- [x] Global Leaderboard
- [x] Statistik Lengkap
- [ ] VS Player (Local)
- [ ] Online Multiplayer
- [ ] Tournament Mode

---

## 👤 Author

**ssajudn** ft. **Antigravity**
