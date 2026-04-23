import 'package:card_games/features/game/domain/repositories/i_game_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalGameRepository implements IGameRepository {
  static const String _keyHighScore = 'high_score';

  @override
  Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyHighScore) ?? 0;
  }

  @override
  Future<void> saveScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHighScore = prefs.getInt(_keyHighScore) ?? 0;
    if (score > currentHighScore) {
      await prefs.setInt(_keyHighScore, score);
    }
  }

  @override
  Future<void> resetStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHighScore);
  }
}
