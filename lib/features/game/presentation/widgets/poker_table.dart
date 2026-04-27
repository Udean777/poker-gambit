import 'package:poker_gambit/features/game/domain/models/card_model.dart';
import 'package:poker_gambit/features/game/presentation/widgets/playing_card.dart';
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
          // Background Slot Placeholders (Premium Glassmorphism & Reactive Animations)
          ...List.generate(5, (index) {
            final offset = (index - 2) * spreadWidth;
            final isSlot2 = index == 2; // x2
            final isSlot3 = index == 3; // LOCK

            bool hasCard = index < cards.length;
            bool isCardInvalid = hasCard && cards[index].isInvalid;

            return Positioned(
              left: (320 / 2 - 45) + offset,
              child: Transform.scale(
                scale: 0.65,
                child: _AnimatedSlotPlaceholder(
                  index: index,
                  isSpecial: isSlot2 || isSlot3,
                  hasCard: hasCard,
                  isInvalid: isCardInvalid,
                  label: isSlot2 ? "x2" : (isSlot3 ? "LOCK" : ""),
                  color: isSlot2
                      ? Colors.amber
                      : (isSlot3 ? Colors.blueAccent : Colors.white),
                  icon: isSlot2
                      ? Icons.bolt
                      : (isSlot3 ? Icons.lock_open : Icons.crop_free),
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

            final isSlot2 = index == 2;
            final isSlot3 = index == 3;

            return AnimatedPositioned(
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              left: (320 / 2 - 45) + (isSpread ? offset : centeredOffset),
              top: 0,
              bottom: 0,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Transform.scale(
                      scale: 0.65 * (0.8 + (0.2 * value)),
                      child: Opacity(
                        opacity: value,
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              if (isSlot2 && !card.isInvalid)
                                BoxShadow(
                                  color: Colors.amber.withValues(
                                    alpha: 0.6 * value,
                                  ),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              if (isSlot3 && !card.isInvalid)
                                BoxShadow(
                                  color: Colors.blueAccent.withValues(
                                    alpha: 0.6 * value,
                                  ),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              if (card.isInvalid)
                                BoxShadow(
                                  color: Colors.redAccent.withValues(
                                    alpha: 0.5 * value,
                                  ),
                                  blurRadius: 25,
                                  spreadRadius: 2,
                                ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              PlayingCard(card: card),
                              if (isSlot2 && !card.isInvalid)
                                _buildOverlayEffect(Colors.amber, Icons.bolt),
                              if (isSlot3 && !card.isInvalid)
                                _buildOverlayEffect(
                                  Colors.blueAccent,
                                  Icons.verified_user,
                                ),
                              if (card.isInvalid)
                                _buildOverlayEffect(
                                  Colors.redAccent,
                                  Icons.lock_outline,
                                  isError: true,
                                ),
                              if (card.isJoker) _buildWildBadge(),
                            ],
                          ),
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

  Widget _buildWildBadge() {
    return Positioned(
      bottom: 5,
      left: 5,
      right: 5,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Colors.purple,
              Colors.blue,
              Colors.green,
              Colors.yellow,
              Colors.orange,
              Colors.red,
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: const Center(
          child: Text(
            "WILD",
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayEffect(
    Color color,
    IconData icon, {
    bool isError = false,
  }) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 3),
        ),
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                topRight: Radius.circular(10),
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
        ),
      ),
    );
  }
}

class _AnimatedSlotPlaceholder extends StatefulWidget {
  final int index;
  final bool isSpecial;
  final bool hasCard;
  final bool isInvalid;
  final String label;
  final Color color;
  final IconData icon;

  const _AnimatedSlotPlaceholder({
    required this.index,
    required this.isSpecial,
    required this.hasCard,
    required this.isInvalid,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  State<_AnimatedSlotPlaceholder> createState() =>
      __AnimatedSlotPlaceholderState();
}

class __AnimatedSlotPlaceholderState extends State<_AnimatedSlotPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color slotColor = widget.isInvalid ? Colors.redAccent : widget.color;
    IconData displayIcon = widget.isInvalid ? Icons.lock_outline : widget.icon;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: 90,
          height: 130,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSpecial
                  ? slotColor.withValues(alpha: widget.hasCard ? 0.8 : 0.4)
                  : Colors.white.withValues(alpha: 0.1),
              width: widget.hasCard ? 3 : 1.5,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.isSpecial
                    ? slotColor.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.05),
                Colors.black.withValues(alpha: 0.4),
              ],
            ),
            boxShadow: [
              if (widget.isSpecial && !widget.hasCard)
                BoxShadow(
                  color: slotColor.withValues(
                    alpha: 0.1 * _pulseAnimation.value,
                  ),
                  blurRadius: 15 * _pulseAnimation.value,
                  spreadRadius: 2 * _pulseAnimation.value,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                if (widget.isSpecial)
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
                      Transform.scale(
                        scale: widget.isSpecial && !widget.hasCard
                            ? _pulseAnimation.value
                            : 1.0,
                        child: Icon(
                          displayIcon,
                          size: 24,
                          color: widget.isSpecial
                              ? slotColor.withValues(
                                  alpha: widget.hasCard ? 0.9 : 0.5,
                                )
                              : Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      if (widget.label.isNotEmpty && !widget.hasCard) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.label,
                          style: TextStyle(
                            color: slotColor.withValues(alpha: 0.7),
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
        );
      },
    );
  }
}
