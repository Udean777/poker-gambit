import 'package:card_games/domain/models/card_model.dart';
import 'package:card_games/presentation/widgets/playing_card.dart';
import 'package:flutter/material.dart';

/// Data model for a card being discarded during swap animation.
class DiscardItem {
  final CardModel card;
  final double startX;
  final double startY;

  const DiscardItem(this.card, this.startX, this.startY);
}

/// Animates selected cards flying upward and fading out (discard phase).
///
/// Used for both player and AI discard sequences.
/// When [isPlayer] is false, cards are rendered at a smaller scale.
class DiscardAnimation extends StatelessWidget {
  final List<DiscardItem> items;
  final AnimationController controller;
  final bool isPlayer;

  const DiscardAnimation({
    super.key,
    required this.items,
    required this.controller,
    this.isPlayer = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        final t = Curves.easeIn.transform(controller.value);
        final screenCenterX = MediaQuery.of(context).size.width / 2;

        return Stack(
          children: items.map((item) {
            final yOffset = -t * 350;
            final opacity = (1 - t).clamp(0.0, 1.0);
            final rotationDir = item.startX > screenCenterX ? 1 : -1;
            final rotation = rotationDir * 0.002 * (1 - t) * item.startX;

            Widget cardWidget = PlayingCard(card: item.card);
            if (!isPlayer) {
              cardWidget = Transform.scale(scale: 0.8, child: cardWidget);
            }

            return Positioned(
              left: item.startX,
              top: item.startY + yOffset,
              child: Transform.rotate(
                angle: rotation,
                child: Opacity(opacity: opacity, child: cardWidget),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
