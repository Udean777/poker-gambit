import 'package:card_games/features/game/domain/logic/card_effects/card_effect_handler.dart';
import 'package:card_games/features/game/domain/models/card_model.dart';
import 'package:card_games/features/game/domain/models/game_state.dart';

class ApplyCardEffectUseCase {
  final CardEffectHandler _handler;

  ApplyCardEffectUseCase(this._handler);

  Future<GameState> execute(
    CardModel card,
    GameState currentState, {
    required bool isPlayer,
  }) async {
    // 1. Check for Suit Lock (Modifier Check)
    var state = _checkSuitLock(currentState, isPlayer);

    // If suit lock invalidated the card, skip strategy-based effects
    if (state != currentState) {
      return state;
    }

    // 2. Apply Strategy-based Effects (J, Q, Joker)
    if (_handler.hasEffect(card)) {
      state = await _handler.applyEffect(card, state, isPlayer: isPlayer);
    }

    return state;
  }

  GameState _checkSuitLock(GameState state, bool isPlayer) {
    final table = isPlayer ? state.playerTableCards : state.aiTableCards;

    if (table.length >= 4) {
      final card3 = table[2];
      final card4 = table[3];

      if (card3.suit != card4.suit && !card4.isJoker && !card3.isJoker) {
        final invalidatedTable = List<CardModel>.from(table);
        invalidatedTable[3] = card4.copyWith(
          isInvalid: true,
        ); // Marked as invalid

        return isPlayer
            ? state.copyWith(
                playerTableCards: invalidatedTable,
                message: 'SUIT LOCK FAILED!',
              )
            : state.copyWith(
                aiTableCards: invalidatedTable,
                message: 'AI SUIT LOCK FAILED!',
              );
      }
    }
    return state;
  }
}
