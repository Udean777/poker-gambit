import 'package:card_games/core/constants/game_constants.dart';
import 'package:card_games/features/game/presentation/widgets/card_container.dart';
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.asset(
            'assets/images/cards/card-back.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
