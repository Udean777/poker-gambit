import 'dart:async';

import 'package:poker_gambit/core/services/connectivity_service.dart';
import 'package:poker_gambit/features/game/data/repositories/firebase_game_repository.dart';
import 'package:poker_gambit/features/game/data/repositories/local_game_repository.dart';
import 'package:poker_gambit/features/game/domain/models/game_stats.dart';
import 'package:poker_gambit/features/game/domain/models/poker_hand.dart';
import 'package:poker_gambit/features/game/domain/repositories/i_game_repository.dart';

class OfflineFirstGameRepository implements IGameRepository {
  final LocalGameRepository _local;
  final FirebaseGameRepository _remote;
  final IConnectivityService _connectivity;

  StreamSubscription<bool>? _connectivitySub;

  OfflineFirstGameRepository({
    required LocalGameRepository local,
    required FirebaseGameRepository remote,
    required IConnectivityService connectivity,
  }) : _local = local,
       _remote = remote,
       _connectivity = connectivity {
    _listenConnectivity();
  }

  void _listenConnectivity() {
    _connectivitySub = _connectivity.onConnectivityChanged.listen((isOnline) {
      if (isOnline) _syncIfNeeded();
    });
  }

  @override
  Future<GameStats> getStats() => _local.getStats();

  @override
  Future<void> saveGameResult({
    required int score,
    required bool isWin,
    required PokerHandRank playerHand,
  }) async {
    await _local.saveGameResult(
      score: score,
      isWin: isWin,
      playerHand: playerHand,
    );

    final isOnline = await _connectivity.isOnline;
    if (isOnline) await _syncIfNeeded();
  }

  @override
  Future<void> resetStats() async {
    await _local.resetStats();
    final isOnline = await _connectivity.isOnline;
    if (isOnline) {
      await _remote.resetStats();
      await _local.setPendingRemoteReset(false);
    } else {
      await _local.setPendingRemoteReset(true);
    }
  }

  Future<void> _syncIfNeeded() async {
    try {
      final pendingReset = await _local.getPendingRemoteReset();
      if (pendingReset) {
        await _remote.resetStats();
        await _local.setPendingRemoteReset(false);
      }

      final localStats = await _local.getStats();
      if (!localStats.needsSync) return;

      final remoteStats = await _remote.getStats();
      final merged = localStats.mergeWith(remoteStats);
      await _remote.uploadStats(merged);
      await _local.markSynced(merged.lastSyncAt ?? DateTime.now());
    } catch (_) {}
  }

  Future<void> forceSync() => _syncIfNeeded();

  void dispose() {
    _connectivitySub?.cancel();
  }
}
