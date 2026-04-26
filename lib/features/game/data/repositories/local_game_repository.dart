import 'package:card_games/features/game/domain/models/game_stats.dart';
import 'package:card_games/features/game/domain/models/poker_hand.dart';
import 'package:card_games/features/game/domain/repositories/i_game_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalGameRepository implements IGameRepository {
  static const _keyHighScore = 'stat_highScore';
  static const _keyTotalGames = 'stat_totalGames';
  static const _keyTotalWins = 'stat_totalWins';
  static const _keyTotalLosses = 'stat_totalLosses';
  static const _keyNeedsSync = 'stat_needsSync';
  static const _keyLastSyncAt = 'stat_lastSyncAt';
  static const _keyPendingRemoteReset = 'stat_pendingRemoteReset';
  static String _handKey(PokerHandRank rank) => 'stat_hand_${rank.name}';

  @override
  Future<GameStats> getStats() async {
    final prefs = await SharedPreferences.getInstance();
    final handCounts = <PokerHandRank, int>{};
    for (final rank in PokerHandRank.values) {
      handCounts[rank] = prefs.getInt(_handKey(rank)) ?? 0;
    }
    final lastSyncRaw = prefs.getString(_keyLastSyncAt);
    return GameStats(
      highScore: prefs.getInt(_keyHighScore) ?? 0,
      totalGames: prefs.getInt(_keyTotalGames) ?? 0,
      totalWins: prefs.getInt(_keyTotalWins) ?? 0,
      totalLosses: prefs.getInt(_keyTotalLosses) ?? 0,
      handCounts: handCounts,
      lastSyncAt: lastSyncRaw != null ? DateTime.tryParse(lastSyncRaw) : null,
      needsSync: prefs.getBool(_keyNeedsSync) ?? false,
    );
  }

  @override
  Future<void> saveGameResult({
    required int score,
    required bool isWin,
    required PokerHandRank playerHand,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final currentHighScore = prefs.getInt(_keyHighScore) ?? 0;
    if (score > currentHighScore) {
      await prefs.setInt(_keyHighScore, score);
    }

    final totalGames = (prefs.getInt(_keyTotalGames) ?? 0) + 1;
    await prefs.setInt(_keyTotalGames, totalGames);

    if (isWin) {
      final totalWins = (prefs.getInt(_keyTotalWins) ?? 0) + 1;
      await prefs.setInt(_keyTotalWins, totalWins);
    } else {
      final totalLosses = (prefs.getInt(_keyTotalLosses) ?? 0) + 1;
      await prefs.setInt(_keyTotalLosses, totalLosses);
    }

    final handCount = (prefs.getInt(_handKey(playerHand)) ?? 0) + 1;
    await prefs.setInt(_handKey(playerHand), handCount);

    await prefs.setBool(_keyNeedsSync, true);
  }

  @override
  Future<void> resetStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHighScore);
    await prefs.remove(_keyTotalGames);
    await prefs.remove(_keyTotalWins);
    await prefs.remove(_keyTotalLosses);
    await prefs.remove(_keyNeedsSync);
    await prefs.remove(_keyLastSyncAt);
    for (final rank in PokerHandRank.values) {
      await prefs.remove(_handKey(rank));
    }
  }

  Future<void> markSynced(DateTime syncedAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNeedsSync, false);
    await prefs.setString(_keyLastSyncAt, syncedAt.toIso8601String());
  }

  Future<void> setPendingRemoteReset(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value) {
      await prefs.setBool(_keyPendingRemoteReset, true);
    } else {
      await prefs.remove(_keyPendingRemoteReset);
    }
  }

  Future<bool> getPendingRemoteReset() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPendingRemoteReset) ?? false;
  }
}
