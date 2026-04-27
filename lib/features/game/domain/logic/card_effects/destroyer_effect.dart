import 'package:poker_gambit/features/game/domain/logic/card_effects/i_card_effect.dart';
import 'package:poker_gambit/features/game/domain/models/game_state.dart';

class DestroyerEffect implements ICardEffect {
  @override
  String get triggerLabel => 'Joker'; // Matches CardModel.isJoker logic

  @override
  Future<GameState> apply(
    GameState currentState, {
    required bool isPlayer,
  }) async {
    final targetTable = isPlayer
        ? currentState.aiTableCards
        : currentState.playerTableCards;
    if (targetTable.isEmpty) return currentState;

    return currentState.copyWith(
      isDestroyPicking: true,
      destroySourceIsPlayer: isPlayer,
      message: isPlayer
          ? 'JOKER: Pilih kartu lawan untuk dihancurkan!'
          : 'AI JOKER: AI sedang menargetkan kartu Anda...',
    );
  }
}
