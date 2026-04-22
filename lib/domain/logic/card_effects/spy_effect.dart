import 'package:card_games/core/constants/game_constants.dart';
import 'package:card_games/domain/logic/card_effects/i_card_effect.dart';
import 'package:card_games/domain/models/card_model.dart';
import 'package:card_games/domain/models/game_state.dart';

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

    final randomIndex = DateTime.now().millisecond % targetHand.length;
    final updatedHand = List<CardModel>.from(targetHand);
    updatedHand[randomIndex] = updatedHand[randomIndex].copyWith(
      isFaceUp: true,
    );

    var state = isPlayer
        ? currentState.copyWith(
            aiHand: updatedHand,
            message: 'SPY: Mengintip kartu lawan!',
          )
        : currentState.copyWith(
            playerHand: updatedHand,
            message: 'AI SPY: Kartu Anda diintip!',
          );

    // This delay might be tricky if handled inside the effect.
    // Usually, effects just return the transformation.
    // But for "temporary reveal", we need to wait and hide again.

    await Future.delayed(GameConstants.spyRevealDuration);

    final resetHand = List<CardModel>.from(updatedHand);
    resetHand[randomIndex] = resetHand[randomIndex].copyWith(isFaceUp: false);

    return isPlayer
        ? state.copyWith(aiHand: resetHand)
        : state.copyWith(playerHand: resetHand);
  }
}
