import 'dart:ui' show lerpDouble;

import 'package:card_games/features/game/presentation/widgets/animations/mini_card_back.dart';
import 'package:flutter/material.dart';

/// Data model for a card being drawn during swap animation.
class DrawItem {
  final double targetX;
  final double targetY;

  const DrawItem(this.targetX, this.targetY);
}

/// Animates card backs flying from the deck position to the hand (draw phase).
///
/// Uses staggered animation so cards arrive one by one with an arc trajectory.
/// When [isPlayer] is false, cards scale to a smaller final size.
class DrawAnimation extends StatelessWidget {
  final List<DrawItem> items;
  final Offset fromOffset;
  final AnimationController controller;
  final bool isPlayer;

  const DrawAnimation({
    super.key,
    required this.items,
    required this.fromOffset,
    required this.controller,
    this.isPlayer = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        return Stack(
          children: List.generate(items.length, (i) {
            final item = items[i];

            // Stagger each card's animation start
            final staggerStart = i * 0.15;
            final staggerEnd = staggerStart + 0.7;
            final rawT =
                ((controller.value - staggerStart) /
                        (staggerEnd - staggerStart))
                    .clamp(0.0, 1.0);
            final t = Curves.easeOutCubic.transform(rawT);

            // Position with arc trajectory
            final dx = lerpDouble(fromOffset.dx - 32, item.targetX, t)!;
            final dy =
                lerpDouble(fromOffset.dy - 44, item.targetY, t)! -
                60 * (1 - (2 * t - 1).abs());

            final opacity = (rawT < 0.05 ? rawT / 0.05 : 1.0).clamp(0.0, 1.0);
            final scale = 0.6 + t * (isPlayer ? 0.4 : 0.2);

            return Positioned(
              left: dx,
              top: dy,
              child: Transform.scale(
                scale: scale,
                child: Opacity(opacity: opacity, child: const MiniCardBack()),
              ),
            );
          }),
        );
      },
    );
  }
}
