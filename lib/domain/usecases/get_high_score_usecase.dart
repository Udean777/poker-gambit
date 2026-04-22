import 'package:card_games/domain/repositories/i_game_repository.dart';

class GetHighScoreUseCase {
  final IGameRepository _repository;

  GetHighScoreUseCase(this._repository);

  Future<int> execute() {
    return _repository.getHighScore();
  }
}
