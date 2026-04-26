import 'package:card_games/core/theme/game_theme.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: GameTheme.backgroundDark,
      body: Center(
        child: CircularProgressIndicator(color: GameTheme.accentAmber),
      ),
    );
  }
}
