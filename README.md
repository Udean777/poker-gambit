# Poker Gambit 🃏

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-%232196F3.svg?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

**Poker Gambit** is a high-stakes, strategic card game built with Flutter. It combines classic card game mechanics with modern interactive elements, featuring a premium dark-themed UI and an advanced AI opponent.

---

## ✨ Features

### 🚀 Seamless Experience

- **Immersive Onboarding**: A beautiful introductory flow to get players started.
- **Premium Main Menu**: An elegant, glassmorphic menu design with multiple game modes.

### 🎮 Gameplay Mechanics

- **VS AI Mode**: Challenge a sophisticated AI with strategic decision-making.
- **QTE (Quick Time Event)**: Interactive "Counter/Block" system for dynamic skill-based gameplay.
- **High-Stakes Poker Elements**: Real-time turn timers and strategic card swapping phases.

### 🎨 Visual & Audio

- **Modern Aesthetics**: Rich dark-mode design with vibrant accents and smooth animations.
- **Dynamic HUD**: Real-time score tracking, turn indicators, and interactive status messages.
- **Responsive Layout**: Optimized for various screen sizes using a custom design system.

---

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev)
- **State Management**: [Riverpod](https://riverpod.dev) (Generator & Annotations)
- **AI Integration**: [Google Generative AI](https://pub.dev/packages/google_generative_ai)
- **Game Engine**: [Flame](https://flame-engine.org) (Core loop & Animations)
- **Typography**: Google Fonts (Outfit)
- **Asset Management**: SVG for resolution-independent card assets.

---

## 🏗 Architecture

The project follows **Clean Architecture** principles to ensure scalability and maintainability:

```text
lib/
├── core/           # Design system, themes, constants, and utilities
├── data/           # Data sources and repository implementations
├── domain/         # Business logic, models, and repository interfaces
└── presentation/   # UI components, screens, and controllers (Riverpod)
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK
- Android Studio / VS Code

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
   Create a `.env` file in the root directory and add your API key (if applicable):

   ```env
   API_KEY=your_google_ai_api_key
   ```

4. **Generate Code** (for Riverpod)

   ```bash
   flutter pub run build_runner build
   ```

5. **Run the App**
   ```bash
   flutter run
   ```

---

## 📅 Roadmap

- [x] Onboarding Flow
- [x] Main Menu Implementation
- [x] VS AI Core Mechanics
- [ ] VS Player (Local)
- [ ] Online Multiplayer
- [ ] Tournament Mode

---

## 👤 Author

**ssajudn** ft. **Antigravity**

---

Made by Me ft. Antigravity.
