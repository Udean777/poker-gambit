import 'package:poker_gambit/features/game/domain/models/poker_hand.dart';
import 'package:poker_gambit/features/game/domain/repositories/i_game_repository.dart';

class SaveGameResultUseCase {
  final IGameRepository _repository;

  SaveGameResultUseCase(this._repository);

  Future<void> call({
    required int score,
    required bool isWin,
    required PokerHandRank playerHand,
  }) {
    return _repository.saveGameResult(
      score: score,
      isWin: isWin,
      playerHand: playerHand,
    );
  }
}
