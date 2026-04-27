import 'package:poker_gambit/core/providers/connectivity_provider.dart';
import 'package:poker_gambit/core/theme/game_theme.dart';
import 'package:poker_gambit/core/widgets/app_scaffold.dart';
import 'package:poker_gambit/features/auth/presentation/providers/auth_provider.dart';
import 'package:poker_gambit/features/leaderboard/presentation/providers/leaderboard_provider.dart';
import 'package:poker_gambit/features/leaderboard/presentation/widgets/leaderboard_widgets.dart';
import 'package:poker_gambit/features/leaderboard/presentation/widgets/loading_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityProvider).valueOrNull ?? false;
    final currentUser = ref.watch(authStateProvider).valueOrNull;

    return AppScaffold(
      decoration: GameTheme.tableGradient,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: isOnline
                ? _LeaderboardContent(currentUid: currentUser?.uid)
                : const OfflineState(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          ),
          const Icon(
            Icons.emoji_events,
            color: GameTheme.accentAmber,
            size: 28,
          ),
          const SizedBox(width: 10),
          const Text(
            'LEADERBOARD',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardContent extends ConsumerWidget {
  final String? currentUid;
  const _LeaderboardContent({this.currentUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(leaderboardEntriesProvider);
    final userRankAsync = ref.watch(userRankProvider);

    return entriesAsync.when(
      loading: () => const LoadingSkeleton(),
      error: (e, _) => const Center(
        child: Text(
          'Gagal memuat leaderboard',
          style: TextStyle(color: Colors.white54),
        ),
      ),
      data: (entries) => RefreshIndicator(
        color: GameTheme.accentAmber,
        backgroundColor: GameTheme.secondaryGreen,
        onRefresh: () async {
          ref.invalidate(leaderboardEntriesProvider);
          ref.invalidate(userRankProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            ...entries.asMap().entries.map(
              (e) => LeaderboardRow(
                rank: e.key + 1,
                entry: e.value,
                isCurrentUser: e.value.uid == currentUid,
              ),
            ),
            if (entries.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Text(
                    'Belum ada data leaderboard',
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (currentUid != null)
              userRankAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (e, s) => const SizedBox.shrink(),
                data: (rank) {
                  if (rank == null || entries.any((e) => e.uid == currentUid)) {
                    return const SizedBox.shrink();
                  }
                  return UserRankBanner(rank: rank);
                },
              ),
          ],
        ),
      ),
    );
  }
}
