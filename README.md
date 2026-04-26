# Poker Gambit 🃏

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-%232196F3.svg?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)

**Poker Gambit** adalah game kartu strategi berbasis Flutter yang menggabungkan mekanik poker klasik dengan elemen interaktif modern. Pemain bertarung melawan AI yang memiliki logika strategi lokal, dilengkapi sistem autentikasi Firebase, leaderboard global, dan sinkronisasi data offline-first.

---

## ✨ Fitur Utama

### 🔐 Autentikasi & User

- **Guest Mode**: Langsung bermain tanpa login, data tersimpan lokal.
- **Google Sign-In**: Login dengan akun Google untuk akses fitur penuh.
- **Upgrade Akun**: Guest bisa upgrade ke akun Google tanpa kehilangan data.
- **Offline-First**: Data tersimpan lokal dan otomatis sync ke Firebase saat online.

### 🎮 Gameplay

- **VS AI Mode**: Tantang AI dengan pengambilan keputusan strategis lokal (tanpa API/Limit).
- **Mekanik x2 & Suit Lock**: Slot meja khusus yang memberikan pengganda poin dan tantangan kecocokan kartu.
- **Kartu Spesial**: Tiga efek unik — Spy (intip kartu lawan), Witch (tukar kartu), Destroyer (hancurkan kartu).
- **QTE (Quick Time Event)**: Sistem Counter/Block interaktif berbasis skill.
- **Fase Swap Kartu**: Tukar kartu sebelum showdown dengan animasi premium.

### 🏆 Statistik & Leaderboard

- **Statistik Lengkap**: Tracking high score, total games, wins, losses, dan frekuensi tiap kombinasi kartu.
- **Global Leaderboard**: Papan peringkat top 10 pemain di seluruh dunia.
- **Sync Otomatis**: Data sinkronisasi ke Firestore saat kembali online.

### 🎨 Visual & UX

- **Premium Dark Aesthetics**: Desain glassmorphic dengan aksen neon gold dan blue.
- **Animasi Imersif**: Animasi draw, discard, dan transisi kartu yang sangat halus dan responsif.
- **Onboarding**: Alur pengenalan untuk pemain baru.
- **Responsive**: Mendukung Android, iOS, Web, dan macOS.

---

## 🛠 Tech Stack

| Kategori         | Library                                                           | Keterangan                 |
| ---------------- | ----------------------------------------------------------------- | -------------------------- |
| Framework        | [Flutter](https://flutter.dev) `latest`                           | Cross-platform UI          |
| Language         | [Dart](https://dart.dev)                                          |                            |
| State Management | [flutter_riverpod](https://riverpod.dev)                          | Reactive state management  |
| Auth             | [firebase_auth](https://pub.dev/packages/firebase_auth)           | Google Sign-In + Anonymous |
| Database         | [cloud_firestore](https://pub.dev/packages/cloud_firestore)       | Leaderboard & user stats   |
| Local Storage    | [shared_preferences](https://pub.dev/packages/shared_preferences) | Cache lokal                |
| Typography       | [google_fonts](https://pub.dev/packages/google_fonts)             | Font Outfit                |
| Audio            | [audioplayers](https://pub.dev/packages/audioplayers)             | Sound effects              |

---

## 🏗 Arsitektur

Project mengikuti **Clean Architecture** + **SOLID Principles**.

```
lib/
├── core/                # Config, Theme, Utils, Common Widgets
├── features/
│   ├── auth/            # Firebase Auth Layer
│   ├── game/            # Gameplay, AI Logic, UI
│   ├── leaderboard/     # Global Ranking
│   └── menu/            # Navigation & UI
└── main.dart
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Firebase project (Auth & Firestore diaktifkan)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/Udean777/poker-gambit.git
   cd card_games
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

---

## 🎨 Asset Credits

Game ini menggunakan aset kartu yang luar biasa dari:

- **xCards Assets**: [Xadeck/xCards](https://github.com/Xadeck/xCards)

---

## 📅 Roadmap

- [x] Onboarding Flow
- [x] Main Menu
- [x] Local Strategic AI Opponent
- [x] Kartu Spesial (Spy, Witch, Destroyer)
- [x] Mekanik Slot x2 & Suit Lock
- [x] Firebase Auth (Google + Anonymous)
- [x] Offline-First Data Sync
- [x] Global Leaderboard
- [x] Statistik Lengkap
- [ ] Online Multiplayer
- [ ] Tournament Mode

---

## 👤 Author

**ssajudn** ft. **AI**
