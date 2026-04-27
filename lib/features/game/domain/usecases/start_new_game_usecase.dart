import 'package:poker_gambit/core/constants/game_constants.dart';
import 'package:poker_gambit/features/game/domain/models/game_state.dart';
import 'package:poker_gambit/features/game/domain/services/i_deck_service.dart';

class StartNewGameUseCase {
  final IDeckService _deckService;

  StartNewGameUseCase(this._deckService);

  GameState execute({int highScore = 0}) {
    final deck = _deckService.createShuffledDeck();
    final deal = _deckService.dealInitialHands(deck);

    return GameState(
      deck: deal.remainingDeck,
      playerHand: deal.playerHand,
      aiHand: deal.aiHand,
      highScore: highScore,
      phase: GamePhase.drawing,
      message:
          'Fase Tukar: Pilih kartu yang ingin diganti (Maks ${GameConstants.maxSwapCards}).',
    );
  }
}
