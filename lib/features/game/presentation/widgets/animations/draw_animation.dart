import 'dart:ui' show lerpDouble;
import 'package:card_games/features/game/presentation/widgets/animations/mini_card_back.dart';
import 'package:flutter/material.dart';

class DrawItem {
  final double targetX;
  final double targetY;

  const DrawItem(this.targetX, this.targetY);
}

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

            final staggerStart = i * 0.12;
            final staggerEnd = (staggerStart + 0.7).clamp(0.0, 1.0);
            final rawT =
                ((controller.value - staggerStart) /
                        (staggerEnd - staggerStart))
                    .clamp(0.0, 1.0);
            final t = Curves.easeOutBack.transform(rawT);

            // Position with dynamic arc (AI cards arc down/up depending on target)
            final dx = lerpDouble(fromOffset.dx - 32, item.targetX, t)!;

            // Adjust arc height for AI
            final arcHeight = isPlayer ? -80.0 : 40.0;
            final dy =
                lerpDouble(fromOffset.dy - 44, item.targetY, t)! +
                (arcHeight * (1 - (2 * t - 1).abs()));

            final opacity = (rawT < 0.1 ? rawT / 0.1 : 1.0).clamp(0.0, 1.0);
            final scale = 0.5 + t * (isPlayer ? 0.5 : 0.3);

            // Add a nice spin while drawing
            final rotation = (1 - t) * (i % 2 == 0 ? 0.5 : -0.5);

            return Positioned(
              left: dx,
              top: dy,
              child: Transform.rotate(
                angle: rotation,
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(opacity: opacity, child: const MiniCardBack()),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
