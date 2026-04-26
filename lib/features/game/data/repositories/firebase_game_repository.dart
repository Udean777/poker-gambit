import 'package:card_games/features/game/domain/models/game_stats.dart';
import 'package:card_games/features/game/domain/models/poker_hand.dart';
import 'package:card_games/features/game/domain/repositories/i_game_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseGameRepository implements IGameRepository {
  final String uid;
  final String displayName;
  final String? photoUrl;
  final FirebaseFirestore _firestore;

  FirebaseGameRepository({
    required this.uid,
    required this.displayName,
    this.photoUrl,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference get _statsDoc =>
      _firestore.collection('users').doc(uid).collection('stats').doc('data');

  DocumentReference get _leaderboardDoc =>
      _firestore.collection('leaderboard').doc(uid);

  @override
  Future<GameStats> getStats() async {
    final snap = await _statsDoc.get();
    if (!snap.exists) return const GameStats();
    return GameStats.fromFirestoreMap(snap.data() as Map<String, dynamic>);
  }

  @override
  Future<void> saveGameResult({
    required int score,
    required bool isWin,
    required PokerHandRank playerHand,
  }) async {
    final current = await getStats();

    final newHandCounts = Map<PokerHandRank, int>.from(current.handCounts);
    newHandCounts[playerHand] = (newHandCounts[playerHand] ?? 0) + 1;

    final updated = GameStats(
      highScore: score > current.highScore ? score : current.highScore,
      totalGames: current.totalGames + 1,
      totalWins: isWin ? current.totalWins + 1 : current.totalWins,
      totalLosses: !isWin ? current.totalLosses + 1 : current.totalLosses,
      handCounts: newHandCounts,
      lastSyncAt: DateTime.now(),
      needsSync: false,
    );

    await _statsDoc.set(updated.toFirestoreMap());
    await _updateLeaderboard(updated);
  }

  @override
  Future<void> resetStats() async {
    await _statsDoc.delete();
    await _leaderboardDoc.delete();
  }

  Future<void> uploadStats(GameStats stats) async {
    final syncedStats = stats.copyWith(
      lastSyncAt: DateTime.now(),
      needsSync: false,
    );
    await _statsDoc.set(syncedStats.toFirestoreMap());
    await _updateLeaderboard(syncedStats);
  }

  Future<void> _updateLeaderboard(GameStats stats) async {
    await _leaderboardDoc.set({
      'uid': uid,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'highScore': stats.highScore,
      'totalGames': stats.totalGames,
      'totalWins': stats.totalWins,
      'totalLosses': stats.totalLosses,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
