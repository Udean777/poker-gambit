import 'package:card_games/core/constants/game_constants.dart';
import 'package:card_games/core/theme/game_theme.dart';
import 'package:card_games/presentation/widgets/card_container.dart';
import 'package:flutter/material.dart';

/// Small card-back widget used in draw animations.
///
/// Represents a face-down card flying from the deck to a player's hand.
class MiniCardBack extends StatelessWidget {
  const MiniCardBack({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: GameConstants.miniCardWidth,
      height: GameConstants.miniCardHeight,
      child: CardContainer(
        color: GameTheme.cardBackBlue,
        child: const Center(
          child: Icon(Icons.style, size: 30, color: Colors.white24),
        ),
      ),
    );
  }
}
