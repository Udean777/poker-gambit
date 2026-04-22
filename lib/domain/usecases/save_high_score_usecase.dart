import 'package:card_games/domain/repositories/i_game_repository.dart';

class SaveHighScoreUseCase {
  final IGameRepository _repository;

  SaveHighScoreUseCase(this._repository);

  Future<void> execute(int score) {
    return _repository.saveScore(score);
  }
}
