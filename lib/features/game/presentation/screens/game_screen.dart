import 'package:poker_gambit/core/theme/game_theme.dart';
import 'package:poker_gambit/core/widgets/app_scaffold.dart';
import 'package:poker_gambit/features/game/domain/models/game_state.dart';
import 'package:poker_gambit/features/game/presentation/providers/game_notifier.dart';
import 'package:poker_gambit/features/game/presentation/providers/game_provider.dart';
import 'package:poker_gambit/features/game/presentation/widgets/game_overlays.dart';
import 'package:poker_gambit/features/game/presentation/widgets/table_background.dart';
import 'package:poker_gambit/features/game/presentation/widgets/game_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final gameLogic = ref.read(gameProvider.notifier);

    return AppScaffold(
      body: Stack(
        children: [
          const TableBackground(),
          _buildPlayArea(gameState, gameLogic),
          GameHeader(
            playerScore: gameState.playerScore,
            aiScore: gameState.aiScore,
            isPlayerTurn: gameState.isPlayerTurn,
            onPause: gameLogic.togglePause,
          ),
          DeckPileSection(
            remainingCards: gameState.deck.length,
            canDraw:
                gameState.playerCanSwap && gameState.phase == GamePhase.drawing,
            onDraw: gameLogic.executeDraw,
          ),
          if (gameState.isPaused)
            PauseOverlay(
              gameLogic: gameLogic,
              onExitToMenu: () => Navigator.pop(context),
            ),
          if (gameState.isWitchPicking)
            WitchSelectionOverlay(
              options: gameState.witchOptions,
              isPlayerPicking: gameState.witchSourceIsPlayer ?? false,
              onSelected: (card) => gameLogic.onWitchCardSelected(card),
            ),
          if (gameState.isSpyPicking)
            SpySelectionOverlay(
              options: gameState.spyOptions,
              isPlayerPicking: gameState.spySourceIsPlayer ?? false,
              onSelected: (card) => gameLogic.onSpyCardSelected(card),
              selectedCard: gameState.spySelectedCard,
            ),
          if (gameState.isDestroyPicking)
            DestroySelectionOverlay(
              options: (gameState.destroySourceIsPlayer ?? false)
                  ? gameState.aiTableCards
                  : gameState.playerTableCards,
              isPlayerPicking: gameState.destroySourceIsPlayer ?? false,
              onSelected: (card) => gameLogic.onDestroyCardSelected(card),
              cardBeingDestroyed: gameState.cardBeingDestroyed,
            ),
          if (gameState.showRoundResult && gameState.lastRoundResult != null)
            RoundResultOverlay(
              result: gameState.lastRoundResult!,
              onDismiss: gameLogic.dismissRoundResult,
            ),
          if (gameState.showWildcardNotify &&
              gameState.wildcardRankName != null)
            WildcardNotification(rankName: gameState.wildcardRankName!),
        ],
      ),
    );
  }

  Widget _buildPlayArea(GameState state, GameNotifier logic) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAiArea(state),
        const SizedBox(height: 60),
        _buildPlayerArea(state, logic),
      ],
    );
  }

  Widget _buildAiArea(GameState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final card = i < state.aiHand.length ? state.aiHand[i] : null;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: CardSlot(
            card: card?.copyWith(isFaceUp: false),
            label: 'SLOT ${i + 1}',
          ),
        );
      }),
    );
  }

  Widget _buildPlayerArea(GameState state, GameNotifier logic) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final card = i < state.playerHand.length
                ? state.playerHand[i]
                : null;
            final isSelected = state.selectedIndices.contains(i);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: CardSlot(
                card: card?.copyWith(isFaceUp: true),
                label: 'SLOT ${i + 1}',
                isHighlighted: isSelected,
                onTap: () => logic.toggleCardSelection(i),
              ),
            );
          }),
        ),
        const SizedBox(height: 30),
        if (state.isPlayerTurn &&
            state.phase == GamePhase.playing &&
            state.selectedIndices.isNotEmpty)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: GameTheme.accentAmber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              final card = state.playerHand[state.selectedIndices.first];
              logic.playCard(card);
            },
            child: const Text(
              'PLAY CARD',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}
