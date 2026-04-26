import 'package:card_games/core/theme/game_theme.dart';
import 'package:flutter/material.dart';

class MenuLogo extends StatelessWidget {
  const MenuLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: GameTheme.accentAmber.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: GameTheme.accentAmber.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: GameTheme.accentAmber.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.style,
            size: 60,
            color: GameTheme.accentAmber,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'POKER GAMBIT',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 8,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                offset: const Offset(2, 4),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 3,
          width: 80,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                GameTheme.accentAmber,
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
