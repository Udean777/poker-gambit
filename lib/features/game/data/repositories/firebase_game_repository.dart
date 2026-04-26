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
    await _firestore.runTransaction((transaction) async {
      final snap = await transaction.get(_statsDoc);
      final current = snap.exists
          ? GameStats.fromFirestoreMap(snap.data() as Map<String, dynamic>)
          : const GameStats();

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

      transaction.set(_statsDoc, updated.toFirestoreMap());

      final leaderboardData = {
        'uid': uid,
        'displayName': displayName,
        'highScore': updated.highScore,
        'totalGames': updated.totalGames,
        'totalWins': updated.totalWins,
        'totalLosses': updated.totalLosses,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (photoUrl != null) {
        leaderboardData['photoUrl'] = photoUrl as Object;
      }

      transaction.set(
        _leaderboardDoc,
        leaderboardData,
        SetOptions(merge: true),
      );
    });
  }

  @override
  Future<void> resetStats() async {
    final batch = _firestore.batch();
    batch.delete(_statsDoc);
    batch.delete(_leaderboardDoc);
    await batch.commit();
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
    final data = {
      'uid': uid,
      'displayName': displayName,
      'highScore': stats.highScore,
      'totalGames': stats.totalGames,
      'totalWins': stats.totalWins,
      'totalLosses': stats.totalLosses,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (photoUrl != null) {
      data['photoUrl'] = photoUrl as Object;
    }

    await _leaderboardDoc.set(data, SetOptions(merge: true));
  }
}
