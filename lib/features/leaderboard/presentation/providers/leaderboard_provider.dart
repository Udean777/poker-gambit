import 'package:poker_gambit/features/auth/presentation/providers/auth_provider.dart';
import 'package:poker_gambit/features/leaderboard/data/repositories/firebase_leaderboard_repository.dart';
import 'package:poker_gambit/features/leaderboard/domain/models/leaderboard_entry.dart';
import 'package:poker_gambit/features/leaderboard/domain/repositories/i_leaderboard_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final leaderboardRepositoryProvider = Provider<ILeaderboardRepository>(
  (ref) => FirebaseLeaderboardRepository(),
);

final leaderboardEntriesProvider = FutureProvider<List<LeaderboardEntry>>((
  ref,
) {
  return ref.watch(leaderboardRepositoryProvider).getTopEntries(limit: 10);
});

final userRankProvider = FutureProvider<int?>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null || user.isGuest) return Future.value(null);
  return ref.watch(leaderboardRepositoryProvider).getUserRank(user.uid);
});
