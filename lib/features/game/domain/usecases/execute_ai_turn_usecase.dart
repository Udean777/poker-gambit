import 'package:card_games/features/game/domain/models/card_model.dart';
import 'package:card_games/features/game/domain/models/game_state.dart';
import 'package:card_games/features/game/domain/services/i_poker_ai_service.dart';

class AiTurnResult {
  final GameState stateAfterSwap;
  final CardModel playedCard;
  final GameState stateAfterPlay;

  AiTurnResult({
    required this.stateAfterSwap,
    required this.playedCard,
    required this.stateAfterPlay,
  });
}

class ExecuteAiTurnUseCase {
  final IPokerAiService _aiService;

  ExecuteAiTurnUseCase(this._aiService);

  Future<AiTurnResult?> execute(GameState state) async {
    if (state.aiHand.isEmpty) return null;

    var currentDeck = List<CardModel>.from(state.deck);
    var currentAiHand = List<CardModel>.from(state.aiHand);
    var currentState = state;

    // 1. Mid-game swap opportunity
    if (state.aiCanSwap) {
      final decision = await _aiService.decideDiscard(
        currentAiHand,
        canWait: false,
      );

      if (decision['action'] == 'swap') {
        final indices = (decision['indices'] as List? ?? [])
            .cast<int>()
            .toSet()
            .where((i) => i >= 0 && i < currentAiHand.length)
            .toList();

        for (final index in indices) {
          if (currentDeck.isNotEmpty) {
            currentAiHand[index] = currentDeck.removeAt(0);
          }
        }

        currentState = currentState.copyWith(
          deck: currentDeck,
          aiHand: currentAiHand,
          aiCanSwap: false,
          message: indices.isNotEmpty
              ? 'AI menukar kartu: ${decision['message']}'
              : 'AI batal menukar: ${decision['message']}',
        );
      } else {
        currentState = currentState.copyWith(aiCanSwap: false);
      }
    }

    // 2. Choose which card to play
    final playIndices = await _aiService.decidePlayOrder(
      currentAiHand,
      state.playerTableCards,
    );

    final chosenIndex =
        (playIndices.isNotEmpty && playIndices.first < currentAiHand.length)
        ? playIndices.first
        : 0;

    final chosenCard = currentAiHand[chosenIndex];
    final handAfterPlay = List<CardModel>.from(currentAiHand)
      ..removeAt(chosenIndex);

    // Blind Placement: Cards 2 and 4 are hidden
    final isHidden =
        currentState.aiTableCards.length == 1 ||
        currentState.aiTableCards.length == 3;
    final playedCard = chosenCard.copyWith(isFaceUp: !isHidden);

    final finalState = currentState.copyWith(
      aiHand: handAfterPlay,
      aiTableCards: [...currentState.aiTableCards, playedCard],
      message: 'AI memainkan kartu.',
    );

    return AiTurnResult(
      stateAfterSwap: currentState,
      playedCard: playedCard,
      stateAfterPlay: finalState,
    );
  }
}
