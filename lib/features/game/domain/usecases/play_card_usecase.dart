import 'package:card_games/features/game/domain/models/card_model.dart';
import 'package:card_games/features/game/domain/models/game_state.dart';

class PlayCardUseCase {
  GameState execute({
    required GameState currentState,
    required CardModel card,
    required bool isPlayer,
  }) {
    if (isPlayer) {
      if (currentState.phase != GamePhase.playing ||
          !currentState.isPlayerTurn ||
          !currentState.playerHand.contains(card)) {
        return currentState;
      }

      // Blind Placement: Cards 2 and 4 (indices 1 and 3) are hidden
      final isHidden =
          currentState.playerTableCards.length == 1 ||
          currentState.playerTableCards.length == 3;

      final playedCard = card.copyWith(isFaceUp: !isHidden);

      return currentState.copyWith(
        playerHand: List.from(currentState.playerHand)..remove(card),
        playerTableCards: [...currentState.playerTableCards, playedCard],
        selectedIndices: const [], // Clear swap selection when a card is played
        isPlayerTurn: false,
        message: 'AI sedang menganalisis meja...',
      );
    } else {
      if (currentState.phase != GamePhase.playing ||
          currentState.isPlayerTurn ||
          !currentState.aiHand.contains(card)) {
        return currentState;
      }

      // AI Logic
      final isHidden =
          currentState.aiTableCards.length == 1 ||
          currentState.aiTableCards.length == 3;

      final playedCard = card.copyWith(isFaceUp: !isHidden);

      return currentState.copyWith(
        aiHand: List.from(currentState.aiHand)..remove(card),
        aiTableCards: [...currentState.aiTableCards, playedCard],
        aiSelectedIndices:
            const [], // Clear AI swap selection when a card is played
        isPlayerTurn: true,
        message: 'Giliran Anda!',
      );
    }
  }
}
