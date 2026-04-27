import 'dart:ui' show lerpDouble;
import 'package:poker_gambit/features/game/domain/models/card_model.dart';
import 'package:poker_gambit/features/game/presentation/widgets/playing_card.dart';
import 'package:flutter/material.dart';

class DiscardItem {
  final CardModel card;
  final double startX;
  final double startY;

  const DiscardItem(this.card, this.startX, this.startY);
}

class DiscardAnimation extends StatelessWidget {
  final List<DiscardItem> items;
  final AnimationController controller;
  final bool isPlayer;
  final Offset? deckCenter;

  const DiscardAnimation({
    super.key,
    required this.items,
    required this.controller,
    this.isPlayer = true,
    this.deckCenter,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        final deckX = deckCenter?.dx ?? MediaQuery.of(context).size.width / 2;
        final deckY = deckCenter?.dy ?? 260.0;

        return Stack(
          children: List.generate(items.length, (i) {
            final item = items[i];

            // Stagger for each card
            final staggerStart = i * 0.1;
            final staggerEnd = (staggerStart + 0.6).clamp(0.0, 1.0);
            final rawT =
                ((controller.value - staggerStart) /
                        (staggerEnd - staggerStart))
                    .clamp(0.0, 1.0);
            final t = Curves.easeInBack.transform(rawT);

            // Fly towards deck
            final dx = lerpDouble(item.startX, deckX - 45, t)!;
            final dy = lerpDouble(item.startY, deckY - 65, t)!;

            final opacity = (1.0 - (t * 1.5)).clamp(0.0, 1.0);
            final rotation = t * (i % 2 == 0 ? 2 : -2);
            final scale = 1.0 - (t * 0.5);

            return Positioned(
              left: dx,
              top: dy,
              child: Transform.rotate(
                angle: rotation,
                child: Transform.scale(
                  scale: isPlayer ? scale : scale * 0.8,
                  child: Opacity(
                    opacity: opacity,
                    child: PlayingCard(card: item.card),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
