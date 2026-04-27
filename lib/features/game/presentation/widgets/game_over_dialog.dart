import 'package:poker_gambit/core/theme/game_theme.dart';
import 'package:flutter/material.dart';

class GameOverDialog extends StatelessWidget {
  final int playerScore;
  final int aiScore;
  final VoidCallback onRestart;

  const GameOverDialog({
    super.key,
    required this.playerScore,
    required this.aiScore,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final isWin = playerScore > aiScore;
    final isDraw = playerScore == aiScore;

    final String title;
    final String emoji;
    final Color borderColor;

    if (isDraw) {
      title = "SERI!";
      emoji = "🤝";
      borderColor = Colors.white;
    } else if (isWin) {
      title = "ANDA MENANG!";
      emoji = "🏆";
      borderColor = Colors.amber;
    } else {
      title = "AI MENANG!";
      emoji = "💀";
      borderColor = GameTheme.aiRed;
    }

    return AlertDialog(
      backgroundColor: const Color(0xFF0A2E16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor, width: 3),
      ),
      title: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: borderColor,
              fontSize: 28,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "SKOR AKHIR",
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ScoreDisplay(
                label: "YOU",
                score: playerScore,
                color: GameTheme.playerBlue,
              ),
              const Text(
                "-",
                style: TextStyle(color: Colors.white38, fontSize: 24),
              ),
              _ScoreDisplay(
                label: "AI",
                score: aiScore,
                color: GameTheme.aiRed,
              ),
            ],
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Column(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pop();
                onRestart();
              },
              label: Text(
                "MAIN LAGI",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text(
                "MENU UTAMA",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ScoreDisplay extends StatelessWidget {
  final String label;
  final int score;
  final Color color;

  const _ScoreDisplay({
    required this.label,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "$score",
          style: TextStyle(
            color: color,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
