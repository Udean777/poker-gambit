import 'package:poker_gambit/features/game/domain/logic/card_effects/i_card_effect.dart';
import 'package:poker_gambit/features/game/domain/models/game_state.dart';

class WitchEffect implements ICardEffect {
  @override
  String get triggerLabel => 'Q';

  @override
  Future<GameState> apply(
    GameState currentState, {
    required bool isPlayer,
  }) async {
    if (currentState.deck.length < 4) return currentState;

    final options = currentState.deck.take(4).toList();
    final remainingDeck = currentState.deck.skip(4).toList();

    return currentState.copyWith(
      deck: remainingDeck,
      witchOptions: options,
      isWitchPicking: true,
      witchSourceIsPlayer: isPlayer,
      message: isPlayer
          ? 'WITCH: Pilih kartu sabotase!'
          : 'AI WITCH: AI sedang memilih...',
    );
  }
}
