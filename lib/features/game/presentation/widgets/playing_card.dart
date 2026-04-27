import 'dart:math';
import 'package:poker_gambit/features/game/domain/models/card_model.dart';
import 'package:poker_gambit/features/game/presentation/widgets/card_container.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PlayingCard extends StatelessWidget {
  final CardModel card;
  final bool isDraggable;
  final double? width;
  final double? height;

  const PlayingCard({
    super.key,
    required this.card,
    this.isDraggable = false,
    this.width,
    this.height,
  });

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
      child: Opacity(
        opacity: card.isInvalid ? 0.4 : 1.0,
        child: CardContainer(
          width: width,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: CachedNetworkImage(
              imageUrl: card.remoteUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              fadeOutDuration: const Duration(milliseconds: 300),
              fadeInDuration: const Duration(milliseconds: 500),
              useOldImageOnUrlChange: true,
              placeholder: (context, url) => Image.asset(
                'assets/images/cards/card-back.png',
                fit: BoxFit.cover,
              ),
              errorWidget: (context, url, error) => const Center(
                child: Icon(Icons.error_outline, color: Colors.redAccent),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBack() {
    return CardContainer(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Image.asset(
          'assets/images/cards/card-back.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
