import 'dart:math';

import 'package:card_games/features/game/domain/logic/card_effects/i_card_effect.dart';
import 'package:card_games/features/game/domain/models/card_model.dart';
import 'package:card_games/features/game/domain/models/game_state.dart';

class SpyEffect implements ICardEffect {
  @override
  String get triggerLabel => 'J';

  @override
  Future<GameState> apply(
    GameState currentState, {
    required bool isPlayer,
  }) async {
    final targetHand = isPlayer ? currentState.aiHand : currentState.playerHand;
    if (targetHand.isEmpty) return currentState;

    final randomIndex = Random().nextInt(targetHand.length);
    final updatedHand = List<CardModel>.from(targetHand);
    updatedHand[randomIndex] = updatedHand[randomIndex].copyWith(
      isFaceUp: true,
    );

    return isPlayer
        ? currentState.copyWith(
            aiHand: updatedHand,
            message: 'SPY: Mengintip kartu lawan!',
          )
        : currentState.copyWith(
            playerHand: updatedHand,
            message: 'AI SPY: Kartu Anda diintip!',
          );
  }
}
