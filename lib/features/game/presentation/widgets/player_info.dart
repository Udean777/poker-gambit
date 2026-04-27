import 'package:poker_gambit/core/theme/game_theme.dart';
import 'package:poker_gambit/core/utils/time_utils.dart';
import 'package:flutter/material.dart';

class PlayerInfo extends StatelessWidget {
  final String name;
  final bool isTurn;
  final Color accentColor;
  final IconData avatarIcon;
  final int? timeLeft;

  const PlayerInfo({
    super.key,
    required this.name,
    required this.isTurn,
    required this.accentColor,
    required this.avatarIcon,
    this.timeLeft,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isTurn
            ? GameTheme.accentAmber.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTurn
              ? GameTheme.accentAmber.withValues(alpha: 0.6)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            avatarIcon,
            color: isTurn ? accentColor : accentColor.withValues(alpha: 0.4),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isTurn ? Colors.white : Colors.white38,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          if (isTurn) ...[
            const SizedBox(width: 6),
            if (timeLeft != null && timeLeft! > 0)
              Text(
                TimeUtils.formatSeconds(timeLeft!),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: timeLeft! <= 3 ? Colors.redAccent : Colors.amber,
                  fontSize: 14,
                ),
              )
            else
              Container(
                height: 6,
                width: 6,
                decoration: BoxDecoration(
                  color: GameTheme.accentAmber,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: GameTheme.accentAmber.withValues(alpha: 0.7),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
