import 'package:flutter/material.dart';

class ScoreBoard extends StatelessWidget {
  final String playerName;
  final int playerScore;
  final String aiName;
  final int aiScore;

  const ScoreBoard({
    super.key,
    required this.playerName,
    required this.playerScore,
    required this.aiName,
    required this.aiScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CompactScoreItem(
            label: "YOU",
            score: playerScore,
            color: Colors.blueAccent,
            isLeft: true,
          ),
          Container(
            width: 1,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 15),
            color: Colors.white12,
          ),
          _CompactScoreItem(
            label: "AI",
            score: aiScore,
            color: Colors.redAccent,
            isLeft: false,
          ),
        ],
      ),
    );
  }
}

class _CompactScoreItem extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  final bool isLeft;

  const _CompactScoreItem({
    required this.label,
    required this.score,
    required this.color,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!isLeft) ...[
          Text(
            "$score",
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        if (isLeft) ...[
          const SizedBox(width: 8),
          Text(
            "$score",
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ],
    );
  }
}
