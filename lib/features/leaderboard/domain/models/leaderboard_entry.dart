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
      highScore: (map['highScore'] as num? ?? 0).toInt(),
      totalGames: (map['totalGames'] as num? ?? 0).toInt(),
      totalWins: (map['totalWins'] as num? ?? 0).toInt(),
      totalLosses: (map['totalLosses'] as num? ?? 0).toInt(),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);

    try {
      if (value.runtimeType.toString() == 'Timestamp') {
        return (value as dynamic).toDate();
      }
      final dynamic v = value;
      if (v.seconds is int) {
        final int seconds = v.seconds;
        final int nanos = (v.nanoseconds as num? ?? 0).toInt();
        return DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanos ~/ 1000000),
        );
      }
    } catch (_) {
      if (value is Map) {
        final seconds = value['seconds'] ?? value['_seconds'];
        final nanos = value['nanoseconds'] ?? value['_nanoseconds'] ?? 0;
        if (seconds is int) {
          final int s = seconds;
          final int n = (nanos as num).toInt();
          return DateTime.fromMillisecondsSinceEpoch(s * 1000 + (n ~/ 1000000));
        }
      }
    }
    return DateTime.tryParse(value.toString());
  }
}
