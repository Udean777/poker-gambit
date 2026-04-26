import 'package:card_games/features/game/domain/models/game_stats.dart';
import 'package:card_games/features/game/domain/models/poker_hand.dart';

abstract class IGameRepository {
  Future<GameStats> getStats();

  Future<void> saveGameResult({
    required int score,
    required bool isWin,
    required PokerHandRank playerHand,
  });

  Future<void> resetStats();
}
