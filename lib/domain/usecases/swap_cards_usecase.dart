import 'package:card_games/domain/models/game_state.dart';
import 'package:card_games/domain/services/i_deck_service.dart';

class SwapCardsUseCase {
  final IDeckService _deckService;

  SwapCardsUseCase(this._deckService);

  GameState execute({
    required GameState currentState,
    required List<int> selectedIndices,
    bool isPlayer = true,
  }) {
    final count = selectedIndices.length;
    final hasSwapped = count > 0;

    final draw = _deckService.drawCards(
      currentState.deck,
      count,
      faceUp: isPlayer,
    );

    if (isPlayer) {
      final newHand = List.of(currentState.playerHand);
      // Note: We assume the cards were already removed by another step
      // or we handle removal and addition here.
      // In current implementation, discardSelectedCards was called first.

      final updatedHand = [...newHand, ...draw.drawnCards];

      if (currentState.phase == GamePhase.drawing) {
        return currentState.copyWith(
          deck: draw.remainingDeck,
          playerHand: updatedHand,
          selectedIndices: const [],
          phase: GamePhase.playing,
          isPlayerTurn: false,
          playerCanSwap: !hasSwapped,
          message: hasSwapped
              ? 'Berhasil ditukar! AI sedang menukar kartu...'
              : 'Melewati tukar kartu. AI sedang menukar...',
        );
      } else {
        return currentState.copyWith(
          deck: draw.remainingDeck,
          playerHand: updatedHand,
          selectedIndices: const [],
          playerCanSwap: !hasSwapped,
          message: hasSwapped ? 'Kartu berhasil ditukar!' : null,
        );
      }
    } else {
      // AI Logic
      return currentState.copyWith(
        deck: draw.remainingDeck,
        aiHand: [...currentState.aiHand, ...draw.drawnCards],
        aiCanSwap: false,
        aiSelectedIndices: const [],
        phase: GamePhase.playing,
        isPlayerTurn: true,
      );
    }
  }
}
