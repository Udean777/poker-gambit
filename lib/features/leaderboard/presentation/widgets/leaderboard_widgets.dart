import 'package:flutter/material.dart';
import 'package:poker_gambit/core/theme/game_theme.dart';
import 'package:poker_gambit/features/leaderboard/domain/models/leaderboard_entry.dart';

class LeaderboardRow extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const LeaderboardRow({
    super.key,
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
            _buildInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 20,
      backgroundImage: entry.photoUrl != null
          ? NetworkImage(entry.photoUrl!)
          : null,
      backgroundColor: Colors.white12,
      child: entry.photoUrl == null
          ? Text(
              entry.displayName.isNotEmpty
                  ? entry.displayName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  Widget _buildInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.displayName,
                  style: TextStyle(
                    color: isCurrentUser ? GameTheme.accentAmber : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isCurrentUser) _buildCurrentUserTag(),
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
    );
  }

  Widget _buildCurrentUserTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 11, color: color),
      const SizedBox(width: 2),
      Text(label, style: TextStyle(color: color, fontSize: 11)),
    ],
  );
}

class UserRankBanner extends StatelessWidget {
  final int rank;
  const UserRankBanner({super.key, required this.rank});
  @override
  Widget build(BuildContext context) => Container(
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

class OfflineState extends StatelessWidget {
  const OfflineState({super.key});
  @override
  Widget build(BuildContext context) => Center(
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
