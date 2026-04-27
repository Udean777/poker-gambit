import 'package:poker_gambit/core/theme/game_theme.dart';
import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isLocked;
  final bool isQuit;

  const MenuButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLocked = false,
    this.isQuit = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isQuit ? Colors.redAccent : Colors.white;
    final opacity = isLocked ? 0.3 : 1.0;

    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isQuit
              ? Colors.red.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          foregroundColor: baseColor,
          padding: EdgeInsets.zero,
          elevation: 0,
          side: BorderSide(
            color: isLocked
                ? Colors.white.withValues(alpha: 0.05)
                : (isQuit
                      ? Colors.redAccent.withValues(alpha: 0.3)
                      : GameTheme.accentAmber.withValues(alpha: 0.3)),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Ink(
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: !isLocked && !isQuit
                ? LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.05),
                      Colors.white.withValues(alpha: 0.01),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: baseColor.withValues(alpha: opacity),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      color: baseColor.withValues(alpha: opacity),
                    ),
                  ),
                ),
                if (isLocked)
                  Icon(
                    Icons.lock_rounded,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.2),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 24,
                    color: baseColor.withValues(alpha: 0.3),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
