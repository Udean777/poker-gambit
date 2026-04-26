import 'package:card_games/features/game/domain/logic/card_effects/i_card_effect.dart';
import 'package:card_games/features/game/domain/models/card_model.dart';
import 'package:card_games/features/game/domain/models/game_state.dart';

class WitchEffect implements ICardEffect {
  @override
  String get triggerLabel => 'Q';

  @override
  Future<GameState> apply(
    GameState currentState, {
    required bool isPlayer,
  }) async {
    final targetHand = isPlayer ? currentState.playerHand : currentState.aiHand;
    if (targetHand.isEmpty || currentState.deck.isEmpty) return currentState;

    final newDeck = List<CardModel>.from(currentState.deck);
    final newHand = List<CardModel>.from(targetHand);
    final randomIndex = DateTime.now().millisecond % targetHand.length;

    newHand[randomIndex] = newDeck.removeAt(0).copyWith(isFaceUp: isPlayer);

    return isPlayer
        ? currentState.copyWith(
            playerHand: newHand,
            deck: newDeck,
            message: 'WITCH: Menukar kartu tangan!',
          )
        : currentState.copyWith(
            aiHand: newHand,
            deck: newDeck,
            message: 'AI WITCH: AI menukar kartu!',
          );
  }
}
