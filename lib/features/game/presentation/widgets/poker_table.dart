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
    // final hasCards = playerTableCards.isNotEmpty || aiTableCards.isNotEmpty;

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
            child: SingleChildScrollView(
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
        const Text(
          "AI BOARD",
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        _CompactCardRow(cards: aiCards, isSpread: isShowdown, isAi: true),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            "VS",
            style: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 4,
            ),
          ),
        ),
        _CompactCardRow(cards: playerCards, isSpread: isShowdown, isAi: false),
        const SizedBox(height: 8),
        const Text(
          "YOUR BOARD",
          style: TextStyle(
            color: Colors.blueAccent,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _CompactCardRow extends StatelessWidget {
  final List<CardModel> cards;
  final bool isSpread;
  final bool isAi;

  const _CompactCardRow({
    required this.cards,
    this.isSpread = false,
    required this.isAi,
  });

  @override
  Widget build(BuildContext context) {
    final double spreadWidth = isSpread ? 52.0 : 30.0;

    return SizedBox(
      height: 130,
      width: 320,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Background Slot Placeholders (Premium Glassmorphism)
          ...List.generate(5, (index) {
            final offset = (index - 2) * spreadWidth;
            String label = "";
            Color slotColor = Colors.white.withValues(alpha: 0.08);
            IconData icon = Icons.crop_free;
            bool isSpecial = false;

            if (index == 2) {
              label = "x2";
              slotColor = Colors.amber;
              icon = Icons.bolt;
              isSpecial = true;
            }
            if (index == 3) {
              label = "LOCK";
              slotColor = Colors.blueAccent;
              icon = Icons.lock_open;
              isSpecial = true;
            }

            // Check if card at this slot is invalid
            bool isCardInvalid = index < cards.length && cards[index].isInvalid;
            if (isCardInvalid) {
              slotColor = Colors.redAccent;
              icon = Icons.lock_outline;
            }

            return Positioned(
              left: (320 / 2 - 45) + offset,
              child: Transform.scale(
                scale: 0.65,
                child: Container(
                  width: 90,
                  height: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSpecial
                          ? slotColor.withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.1),
                      width: 1.5,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        isSpecial
                            ? slotColor.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.4),
                      ],
                    ),
                    boxShadow: [
                      if (isSpecial)
                        BoxShadow(
                          color: slotColor.withValues(alpha: 0.1),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        // Subtle inner glow
                        if (isSpecial)
                          Positioned(
                            top: -20,
                            right: -20,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: slotColor.withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                icon,
                                size: 24,
                                color: isSpecial
                                    ? slotColor.withValues(alpha: 0.5)
                                    : Colors.white.withValues(alpha: 0.05),
                              ),
                              if (label.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  label,
                                  style: TextStyle(
                                    color: isSpecial
                                        ? slotColor.withValues(alpha: 0.7)
                                        : Colors.white24,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          // Actual Cards with Premium Entrance Animation
          ...List.generate(cards.length, (index) {
            final offset = (index - (cards.length - 1) / 2) * spreadWidth;
            final centeredOffset = isSpread
                ? offset
                : (index - 2) * spreadWidth;
            final card = cards[index];

            bool isSlot2 = index == 2;
            bool isSlot3 = index == 3;

            return AnimatedPositioned(
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut, // Membuat kartu terasa "mendarat"
              left: (320 / 2 - 45) + (isSpread ? offset : centeredOffset),
              top: 0,
              bottom: 0,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)), // Efek slide up
                    child: Transform.scale(
                      scale: 0.65 * (0.8 + (0.2 * value)), // Efek zoom in kecil
                      child: Opacity(
                        opacity: value,
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              if (isSlot2 && !card.isInvalid)
                                BoxShadow(
                                  color: Colors.amber.withValues(alpha: 0.4),
                                  blurRadius: 25,
                                  spreadRadius: 2,
                                ),
                              if (isSlot3 && !card.isInvalid)
                                BoxShadow(
                                  color: Colors.blueAccent.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 25,
                                  spreadRadius: 2,
                                ),
                              if (card.isInvalid)
                                BoxShadow(
                                  color: Colors.redAccent.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 20,
                                  spreadRadius: 1,
                                ),
                            ],
                          ),
                          child: PlayingCard(card: card),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
