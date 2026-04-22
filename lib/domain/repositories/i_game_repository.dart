abstract class IGameRepository {
  /// Gets the highest score achieved by the player.
  Future<int> getHighScore();

  /// Saves a new score if it's higher than the current high score.
  Future<void> saveScore(int score);

  /// Resets the game statistics.
  Future<void> resetStats();
}
