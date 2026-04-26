import 'package:card_games/core/providers/connectivity_provider.dart';
import 'package:card_games/core/theme/game_theme.dart';
import 'package:card_games/core/widgets/app_scaffold.dart';
import 'package:card_games/features/auth/presentation/providers/auth_provider.dart';
import 'package:card_games/features/leaderboard/domain/models/leaderboard_entry.dart';
import 'package:card_games/features/leaderboard/presentation/providers/leaderboard_provider.dart';
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
                : const _OfflineState(),
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
          Text(
            'LEADERBOARD',
            style: const TextStyle(
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
      loading: () => const _LoadingSkeleton(),
      error: (e, _) => Center(
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
              (e) => _LeaderboardRow(
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
                  if (rank == null) return const SizedBox.shrink();
                  final isInTop = entries.any((e) => e.uid == currentUid);
                  if (isInTop) return const SizedBox.shrink();
                  return _UserRankBanner(rank: rank);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const _LeaderboardRow({
    required this.rank,
    required this.entry,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;
    final rankColors = [
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
    ];
    final rankColor = isTop3 ? rankColors[rank - 1] : Colors.white38;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? GameTheme.accentAmber.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentUser
              ? GameTheme.accentAmber.withValues(alpha: 0.5)
              : Colors.white10,
          width: isCurrentUser ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: rankColor,
                  fontWeight: FontWeight.w900,
                  fontSize: isTop3 ? 18 : 15,
                ),
              ),
            ),
            const SizedBox(width: 10),
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.displayName,
                          style: TextStyle(
                            color: isCurrentUser
                                ? GameTheme.accentAmber
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrentUser)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: GameTheme.accentAmber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Kamu',
                            style: TextStyle(
                              color: GameTheme.accentAmber,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _StatChip(
                        icon: Icons.star,
                        color: GameTheme.accentAmber,
                        label: '${entry.highScore}',
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        icon: Icons.sports_esports,
                        color: Colors.white54,
                        label: '${entry.totalGames}G',
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        icon: Icons.emoji_events,
                        color: Colors.greenAccent,
                        label: '${entry.totalWins}W',
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        icon: Icons.close,
                        color: Colors.redAccent,
                        label: '${entry.totalLosses}L',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (entry.photoUrl != null) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(entry.photoUrl!),
        backgroundColor: Colors.white12,
      );
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.white12,
      child: Text(
        entry.displayName.isNotEmpty ? entry.displayName[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _StatChip({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 2),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }
}

class _UserRankBanner extends StatelessWidget {
  final int rank;

  const _UserRankBanner({required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline, color: Colors.white54, size: 18),
          const SizedBox(width: 8),
          Text(
            'Posisi kamu: #$rank',
            style: const TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineState extends StatelessWidget {
  const _OfflineState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, color: Colors.white24, size: 56),
          const SizedBox(height: 16),
          const Text(
            'Leaderboard tidak tersedia\nsaat offline',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: 6,
      itemBuilder: (_, i) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        child: _ShimmerBox(),
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.03, end: 0.1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: _animation.value),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
