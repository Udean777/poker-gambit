import 'package:poker_gambit/features/game/domain/models/poker_hand.dart';
import 'package:flutter/foundation.dart';

@immutable
class GameStats {
  final int highScore;
  final int totalGames;
  final int totalWins;
  final int totalLosses;
  final Map<PokerHandRank, int> handCounts;
  final DateTime? lastSyncAt;
  final bool needsSync;

  const GameStats({
    this.highScore = 0,
    this.totalGames = 0,
    this.totalWins = 0,
    this.totalLosses = 0,
    this.handCounts = const {},
    this.lastSyncAt,
    this.needsSync = false,
  });

  GameStats copyWith({
    int? highScore,
    int? totalGames,
    int? totalWins,
    int? totalLosses,
    Map<PokerHandRank, int>? handCounts,
    DateTime? lastSyncAt,
    bool? needsSync,
  }) {
    return GameStats(
      highScore: highScore ?? this.highScore,
      totalGames: totalGames ?? this.totalGames,
      totalWins: totalWins ?? this.totalWins,
      totalLosses: totalLosses ?? this.totalLosses,
      handCounts: handCounts ?? this.handCounts,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      needsSync: needsSync ?? this.needsSync,
    );
  }

  GameStats mergeWith(GameStats other) {
    final mergedHandCounts = <PokerHandRank, int>{};
    for (final rank in PokerHandRank.values) {
      final a = handCounts[rank] ?? 0;
      final b = other.handCounts[rank] ?? 0;
      mergedHandCounts[rank] = a + b;
    }

    final newWins = totalWins + other.totalWins;
    final newLosses = totalLosses + other.totalLosses;
    var newTotalGames = totalGames + other.totalGames;

    // Enforce invariant: totalGames >= totalWins + totalLosses
    if (newTotalGames < newWins + newLosses) {
      newTotalGames = newWins + newLosses;
    }

    return GameStats(
      highScore: highScore > other.highScore ? highScore : other.highScore,
      totalGames: newTotalGames,
      totalWins: newWins,
      totalLosses: newLosses,
      handCounts: mergedHandCounts,
      lastSyncAt: DateTime.now(),
      needsSync: false,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    final handCountsMap = <String, int>{};
    for (final entry in handCounts.entries) {
      handCountsMap[entry.key.name] = entry.value;
    }
    return {
      'highScore': highScore,
      'totalGames': totalGames,
      'totalWins': totalWins,
      'totalLosses': totalLosses,
      'handCounts': handCountsMap,
      'lastSyncAt': lastSyncAt?.toIso8601String(),
    };
  }

  factory GameStats.fromFirestoreMap(Map<String, dynamic> map) {
    final rawHandCounts = map['handCounts'] as Map<String, dynamic>? ?? {};
    final handCounts = <PokerHandRank, int>{};
    for (final rank in PokerHandRank.values) {
      handCounts[rank] = (rawHandCounts[rank.name] as num? ?? 0).toInt();
    }
    return GameStats(
      highScore: (map['highScore'] as num? ?? 0).toInt(),
      totalGames: (map['totalGames'] as num? ?? 0).toInt(),
      totalWins: (map['totalWins'] as num? ?? 0).toInt(),
      totalLosses: (map['totalLosses'] as num? ?? 0).toInt(),
      handCounts: handCounts,
      lastSyncAt: _parseDateTime(map['lastSyncAt']),
      needsSync: false,
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
