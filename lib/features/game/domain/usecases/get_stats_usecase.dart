import 'package:poker_gambit/features/game/domain/models/game_stats.dart';
import 'package:poker_gambit/features/game/domain/repositories/i_game_repository.dart';

class GetStatsUseCase {
  final IGameRepository _repository;

  GetStatsUseCase(this._repository);

  Future<GameStats> call() => _repository.getStats();
}
