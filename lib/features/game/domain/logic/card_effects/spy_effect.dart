import 'package:poker_gambit/features/game/domain/logic/card_effects/i_card_effect.dart';
import 'package:poker_gambit/features/game/domain/models/game_state.dart';

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

    return currentState.copyWith(
      isSpyPicking: true,
      spyOptions: targetHand,
      spySourceIsPlayer: isPlayer,
      message: isPlayer
          ? 'SPY: Pilih kartu untuk diintip!'
          : 'AI SPY: AI sedang mengintip...',
    );
  }
}
