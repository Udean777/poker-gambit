import 'package:flutter/foundation.dart';

@immutable
class LeaderboardEntry {
  final String uid;
  final String displayName;
  final String? photoUrl;
  final int highScore;
  final int totalGames;
  final int totalWins;
  final int totalLosses;
  final DateTime? updatedAt;

  const LeaderboardEntry({
    required this.uid,
    required this.displayName,
    this.photoUrl,
    required this.highScore,
    this.totalGames = 0,
    this.totalWins = 0,
    this.totalLosses = 0,
    this.updatedAt,
  });

  double get winRate => totalGames == 0 ? 0 : (totalWins / totalGames * 100);

  factory LeaderboardEntry.fromFirestoreMap(
    String uid,
    Map<String, dynamic> map,
  ) {
    return LeaderboardEntry(
      uid: uid,
      displayName: (map['displayName'] as String?) ?? 'Player',
      photoUrl: map['photoUrl'] as String?,
      highScore: (map['highScore'] as int?) ?? 0,
      totalGames: (map['totalGames'] as int?) ?? 0,
      totalWins: (map['totalWins'] as int?) ?? 0,
      totalLosses: (map['totalLosses'] as int?) ?? 0,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
    );
  }
}
