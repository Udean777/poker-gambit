import 'dart:math';
import 'package:card_games/features/game/domain/models/card_model.dart';
import 'package:card_games/features/game/presentation/widgets/card_container.dart';
import 'package:flutter/material.dart';

class PlayingCard extends StatelessWidget {
  final CardModel card;
  final bool isDraggable;

  const PlayingCard({super.key, required this.card, this.isDraggable = false});

  @override
  Widget build(BuildContext context) {
    Widget cardContent = TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: card.isFaceUp ? pi : 0),
      duration: const Duration(milliseconds: 500),
      builder: (context, double value, child) {
        final isBack = value < pi / 2;
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(value),
          alignment: Alignment.center,
          child: isBack ? _buildBack() : _buildFront(),
        );
      },
    );

    if (isDraggable) {
      return Draggable<CardModel>(
        data: card,
        feedback: Material(
          color: Colors.transparent,
          child: Opacity(opacity: 0.8, child: cardContent),
        ),
        childWhenDragging: Opacity(opacity: 0.3, child: cardContent),
        child: cardContent,
      );
    }

    return cardContent;
  }

  Widget _buildFront() {
    return Transform(
      transform: Matrix4.identity()..rotateY(pi),
      alignment: Alignment.center,
      child: CardContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(card.suitIcon, style: const TextStyle(fontSize: 24)),
            Text(
              card.valueLabel,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBack() {
    return CardContainer(
      color: Colors.blue.shade900,
      child: const Center(
        child: Icon(Icons.style, size: 40, color: Colors.white24),
      ),
    );
  }
}
