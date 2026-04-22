import 'package:card_games/domain/logic/card_effects/i_card_effect.dart';
import 'package:card_games/domain/models/card_model.dart';
import 'package:card_games/domain/models/game_state.dart';

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

    final newTable = List<CardModel>.from(targetTable)..removeLast();

    return isPlayer
        ? currentState.copyWith(
            aiTableCards: newTable,
            message: 'JOKER: Menghancurkan kartu AI!',
          )
        : currentState.copyWith(
            playerTableCards: newTable,
            message: 'AI JOKER: Kartu Anda dihancurkan!',
          );
  }
}
