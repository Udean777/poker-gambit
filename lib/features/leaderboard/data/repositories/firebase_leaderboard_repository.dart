import 'package:card_games/features/leaderboard/domain/models/leaderboard_entry.dart';
import 'package:card_games/features/leaderboard/domain/repositories/i_leaderboard_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseLeaderboardRepository implements ILeaderboardRepository {
  final FirebaseFirestore _firestore;

  FirebaseLeaderboardRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _leaderboardCol =>
      _firestore.collection('leaderboard');

  @override
  Future<List<LeaderboardEntry>> getTopEntries({int limit = 10}) async {
    final snap = await _leaderboardCol
        .orderBy('highScore', descending: true)
        .limit(limit)
        .get();

    return snap.docs
        .map(
          (doc) => LeaderboardEntry.fromFirestoreMap(
            doc.id,
            doc.data() as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<int?> getUserRank(String uid) async {
    final userSnap = await _leaderboardCol.doc(uid).get();
    if (!userSnap.exists) return null;

    final userScore =
        (userSnap.data() as Map<String, dynamic>)['highScore'] as int? ?? 0;

    final higherSnap = await _leaderboardCol
        .where('highScore', isGreaterThan: userScore)
        .count()
        .get();

    return (higherSnap.count ?? 0) + 1;
  }
}
