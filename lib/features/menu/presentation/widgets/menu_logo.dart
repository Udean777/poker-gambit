import 'package:card_games/core/theme/game_theme.dart';
import 'package:flutter/material.dart';

class MenuLogo extends StatelessWidget {
  const MenuLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: GameTheme.accentAmber.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/poker-gambit.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
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
        const SizedBox(height: 10),
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
