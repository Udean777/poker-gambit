import 'package:card_games/features/game/domain/models/card_model.dart';
import 'package:card_games/features/game/presentation/providers/game_provider.dart';
import 'package:card_games/features/game/presentation/widgets/playing_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OpponentArea extends ConsumerWidget {
  final List<CardModel> aiHand;

  const OpponentArea({super.key, required this.aiHand});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiSelectedIndices = ref.watch(
      gameProvider.select((s) => s.aiSelectedIndices),
    );
    final isAnimating = ref.watch(gameProvider.select((s) => s.isAnimating));

    return SizedBox(
      height: 120,
      width: double.infinity,
      child: Center(
        child: SizedBox(
          width: (aiHand.length * 60.0) + 20,
          child: Stack(
            clipBehavior: Clip.none,
            children: List.generate(aiHand.length, (index) {
              final card = aiHand[index];
              final isSelected = aiSelectedIndices.contains(index);

              return AnimatedPositioned(
                key: ValueKey("ai_${card.suit}_${card.value}"),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                left: index * 60.0,
                top: 0,
                child: Transform.scale(
                  scale: 0.8,
                  child: Opacity(
                    opacity: (isSelected && isAnimating) ? 0.0 : 1.0,
                    child: PlayingCard(card: card),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
