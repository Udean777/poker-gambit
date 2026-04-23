import 'package:card_games/features/game/domain/models/card_model.dart';
import 'package:card_games/features/game/presentation/widgets/playing_card.dart';
import 'package:flutter/material.dart';

class PokerTable extends StatelessWidget {
  final List<CardModel> playerTableCards;
  final List<CardModel> aiTableCards;
  final bool isPlayerTurn;
  final bool isShowdown;
  final Function(CardModel) onCardDropped;

  const PokerTable({
    super.key,
    required this.playerTableCards,
    required this.aiTableCards,
    required this.isPlayerTurn,
    required this.isShowdown,
    required this.onCardDropped,
  });

  @override
  Widget build(BuildContext context) {
    final hasCards = playerTableCards.isNotEmpty || aiTableCards.isNotEmpty;

    return DragTarget<CardModel>(
      onWillAcceptWithDetails: (details) =>
          isPlayerTurn && playerTableCards.length < 5,
      onAcceptWithDetails: (details) => onCardDropped(details.data),
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: candidateData.isNotEmpty
                  ? Colors.amberAccent
                  : Colors.white12,
              width: 2,
            ),
          ),
          child: Center(
            child: !hasCards
                ? const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white10,
                    size: 50,
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: _TableCardsGrid(
                      playerCards: playerTableCards,
                      aiCards: aiTableCards,
                      isShowdown: isShowdown,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _TableCardsGrid extends StatelessWidget {
  final List<CardModel> playerCards;
  final List<CardModel> aiCards;
  final bool isShowdown;

  const _TableCardsGrid({
    required this.playerCards,
    required this.aiCards,
    required this.isShowdown,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (aiCards.isNotEmpty) ...[
          const Text(
            "AI",
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 2),
          _CompactCardRow(cards: aiCards, isSpread: isShowdown),
        ],
        if (aiCards.isNotEmpty && playerCards.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              "VS",
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        if (playerCards.isNotEmpty) ...[
          _CompactCardRow(cards: playerCards, isSpread: isShowdown),
          const SizedBox(height: 2),
          const Text(
            "YOU",
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ],
    );
  }
}

class _CompactCardRow extends StatelessWidget {
  final List<CardModel> cards;
  final bool isSpread;

  const _CompactCardRow({required this.cards, this.isSpread = false});

  @override
  Widget build(BuildContext context) {
    final double spreadWidth = isSpread ? 52.0 : 26.0;

    return SizedBox(
      height: 100,
      width: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Slot Placeholders
          ...List.generate(5, (index) {
            final offset = (index - 2) * spreadWidth;
            String label = "";
            if (index == 2) label = "x2";
            if (index == 3) label = "LOCK";

            return Positioned(
              left: (300 / 2 - 45) + offset,
              child: Transform.scale(
                scale: 0.65,
                child: Container(
                  width: 90,
                  height: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: label.isNotEmpty
                          ? Colors.amber.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      width: 1,
                    ),
                    color: Colors.black.withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: label == "x2" ? Colors.amber : Colors.white12,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),

          // Actual Cards
          ...List.generate(cards.length, (index) {
            final offset = (index - (cards.length - 1) / 2) * spreadWidth;
            // Center the cards over the placeholders if not spreading
            final centeredOffset = isSpread
                ? offset
                : (index - 2) * spreadWidth;

            return AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              left: (300 / 2 - 45) + (isSpread ? offset : centeredOffset),
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 600),
                turns: 0,
                child: Transform.scale(
                  scale: 0.65,
                  child: Opacity(
                    opacity: cards[index].value == 0 ? 0.4 : 1.0,
                    child: PlayingCard(card: cards[index]),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
