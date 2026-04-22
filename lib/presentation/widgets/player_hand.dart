import 'package:card_games/domain/models/card_model.dart';
import 'package:card_games/domain/models/game_state.dart';
import 'package:card_games/presentation/providers/game_provider.dart';
import 'package:card_games/presentation/widgets/playing_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerHand extends ConsumerWidget {
  final List<CardModel> playerHand;
  final bool isPlayerTurn;

  const PlayerHand({
    super.key,
    required this.playerHand,
    required this.isPlayerTurn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndices = ref.watch(
      gameProvider.select((s) => s.selectedIndices),
    );
    final canSwap = ref.watch(gameProvider.select((s) => s.playerCanSwap));
    final phase = ref.watch(gameProvider.select((s) => s.phase));
    final isAnimating = ref.watch(gameProvider.select((s) => s.isAnimating));

    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Center(
        child: SizedBox(
          // Constrain width to keep cards centered
          width: (playerHand.length * 70.0) + 20,
          child: Stack(
            clipBehavior: Clip.none,
            children: List.generate(playerHand.length, (index) {
              final card = playerHand[index];
              final isSelected = selectedIndices.contains(index);

              // Horizontal position logic: overlapping
              final double leftPos = index * 70.0;

              return AnimatedPositioned(
                key: ValueKey("${card.suit}_${card.value}"),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                left: leftPos,
                bottom: isSelected ? 30 : 0,
                child: GestureDetector(
                  onTap: () {
                    if (phase == GamePhase.drawing ||
                        (phase == GamePhase.playing && canSwap)) {
                      ref
                          .read(gameProvider.notifier)
                          .toggleCardSelection(index);
                    }
                  },
                  child: Draggable<CardModel>(
                    data: card,
                    feedback: Transform.scale(
                      scale: 1.1,
                      child: PlayingCard(card: card),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: PlayingCard(card: card),
                    ),
                    ignoringFeedbackSemantics: false,
                    maxSimultaneousDrags:
                        (isPlayerTurn && phase == GamePhase.playing) ? 1 : 0,
                    child: Opacity(
                      opacity: (isSelected && isAnimating) ? 0.0 : 1.0,
                      child: Stack(
                        children: [
                          PlayingCard(card: card),
                          if (isSelected && !isAnimating)
                            const Positioned(
                              top: 0,
                              right: 0,
                              child: Icon(
                                Icons.change_circle,
                                color: Colors.amber,
                                size: 24,
                              ),
                            ),
                        ],
                      ),
                    ),
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
