import 'package:card_games/core/constants/game_constants.dart';
import 'package:card_games/domain/models/game_state.dart';
import 'package:card_games/domain/services/i_deck_service.dart';

class StartNewGameUseCase {
  final IDeckService _deckService;

  StartNewGameUseCase(this._deckService);

  GameState execute() {
    final deck = _deckService.createShuffledDeck();
    final deal = _deckService.dealInitialHands(deck);

    return GameState(
      deck: deal.remainingDeck,
      playerHand: deal.playerHand,
      aiHand: deal.aiHand,
      phase: GamePhase.drawing,
      message:
          'Fase Tukar: Pilih kartu yang ingin diganti (Maks ${GameConstants.maxSwapCards}).',
    );
  }
}
