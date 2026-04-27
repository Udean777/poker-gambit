import 'package:flutter/material.dart';
import 'package:poker_gambit/core/theme/game_theme.dart';
import 'package:poker_gambit/features/game/domain/models/card_model.dart';
import 'package:poker_gambit/features/game/presentation/widgets/playing_card.dart';

class GameHeader extends StatelessWidget {
  final int playerScore;
  final int aiScore;
  final bool isPlayerTurn;
  final VoidCallback onPause;

  const GameHeader({
    super.key,
    required this.playerScore,
    required this.aiScore,
    required this.isPlayerTurn,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildScoreBoard('YOU', playerScore, true),
          _buildTurnIndicator(),
          _buildScoreBoard('AI', aiScore, false),
          IconButton(
            icon: const Icon(Icons.pause, color: Colors.white, size: 30),
            onPressed: onPause,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBoard(String label, int score, bool isPlayer) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '$score',
          style: TextStyle(
            color: isPlayer ? GameTheme.accentAmber : Colors.redAccent,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildTurnIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: (isPlayerTurn ? GameTheme.accentAmber : Colors.redAccent)
            .withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isPlayerTurn ? GameTheme.accentAmber : Colors.redAccent)
              .withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        isPlayerTurn ? "YOUR TURN" : "AI'S TURN",
        style: TextStyle(
          color: isPlayerTurn ? GameTheme.accentAmber : Colors.redAccent,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class CardSlot extends StatelessWidget {
  final CardModel? card;
  final String label;
  final bool isHighlighted;
  final VoidCallback? onTap;

  const CardSlot({
    super.key,
    this.card,
    required this.label,
    this.isHighlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isHighlighted ? GameTheme.accentAmber : Colors.white12,
                width: isHighlighted ? 2 : 1,
              ),
              boxShadow: isHighlighted
                  ? [
                      BoxShadow(
                        color: GameTheme.accentAmber.withValues(alpha: 0.3),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: card != null
                ? PlayingCard(card: card!, height: 100)
                : Center(
                    child: Icon(
                      Icons.add,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class DeckPileSection extends StatelessWidget {
  final int remainingCards;
  final VoidCallback? onDraw;
  final bool canDraw;

  const DeckPileSection({
    super.key,
    required this.remainingCards,
    this.onDraw,
    required this.canDraw,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 250,
      child: GestureDetector(
        onTap: canDraw ? onDraw : null,
        child: Column(
          children: [
            Stack(
              children: List.generate(
                3,
                (i) => Transform.translate(
                  offset: Offset(-i * 2.0, -i * 2.0),
                  child: Container(
                    width: 60,
                    height: 85,
                    decoration: BoxDecoration(
                      color: i == 2
                          ? const Color(0xFF2D3436)
                          : const Color(0xFF1E272E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: i == 2
                        ? const Center(
                            child: Icon(
                              Icons.style,
                              color: Colors.white24,
                              size: 30,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$remainingCards',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
