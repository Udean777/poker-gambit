import 'package:card_games/features/game/domain/models/poker_hand.dart';
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
      mergedHandCounts[rank] = a > b ? a : b;
    }

    return GameStats(
      highScore: highScore > other.highScore ? highScore : other.highScore,
      totalGames: totalGames > other.totalGames ? totalGames : other.totalGames,
      totalWins: totalWins > other.totalWins ? totalWins : other.totalWins,
      totalLosses: totalLosses > other.totalLosses
          ? totalLosses
          : other.totalLosses,
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
      handCounts[rank] = (rawHandCounts[rank.name] as int?) ?? 0;
    }
    return GameStats(
      highScore: (map['highScore'] as int?) ?? 0,
      totalGames: (map['totalGames'] as int?) ?? 0,
      totalWins: (map['totalWins'] as int?) ?? 0,
      totalLosses: (map['totalLosses'] as int?) ?? 0,
      handCounts: handCounts,
      lastSyncAt: map['lastSyncAt'] != null
          ? DateTime.tryParse(map['lastSyncAt'] as String)
          : null,
      needsSync: false,
    );
  }
}
