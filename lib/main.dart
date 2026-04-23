import 'package:card_games/core/theme/game_theme.dart';
import 'package:card_games/features/menu/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: CardGameApp()));
}

class CardGameApp extends StatelessWidget {
  const CardGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poker Gambit',
      debugShowCheckedModeBanner: false,
      theme: GameTheme.darkTheme,
      home: const OnboardingScreen(),
    );
  }
}
