import 'package:poker_gambit/features/leaderboard/domain/models/leaderboard_entry.dart';

abstract class ILeaderboardRepository {
  Future<List<LeaderboardEntry>> getTopEntries({int limit = 10});
  Future<int?> getUserRank(String uid);
}
