import 'package:poker_gambit/core/constants/game_constants.dart';
import 'package:poker_gambit/features/game/domain/models/game_state.dart';
import 'package:poker_gambit/features/game/presentation/controllers/swap_animation_orchestrator.dart';
import 'package:poker_gambit/features/game/presentation/providers/game_provider.dart';
import 'package:poker_gambit/features/game/presentation/widgets/animations/discard_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameSwapController {
  final WidgetRef ref;
  final BuildContext Function() getContext;
  final GlobalKey deckKey;
  final GlobalKey handKey;
  final GlobalKey aiHandKey;
  final SwapAnimationOrchestrator animOrchestrator;

  bool _isAnimating = false;
  List<int>? lastAiSelection;

  bool get isAnimating => _isAnimating;

  GameSwapController({
    required this.ref,
    required this.getContext,
    required this.deckKey,
    required this.handKey,
    required this.aiHandKey,
    required this.animOrchestrator,
  });

  Offset? _getWidgetCenter(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final pos = box.localToGlobal(Offset.zero);
    return Offset(pos.dx + box.size.width / 2, pos.dy + box.size.height / 2);
  }

  Future<void> triggerPlayerSwap() async {
    if (isAnimating) return;

    final gameState = ref.read(gameProvider);
    final selectedIndices = gameState.selectedIndices;

    if (selectedIndices.isEmpty) {
      ref.read(gameProvider.notifier).executeDraw();
      return;
    }

    _isAnimating = true;
    ref.read(gameProvider.notifier).setIsAnimating(true);
    ref.read(gameProvider.notifier).cancelTimer();

    final deckCenter = _getWidgetCenter(deckKey);
    final handCenter = _getWidgetCenter(handKey);
    final context = getContext();

    final discardItems = handCenter != null
        ? _buildPlayerDiscardItems(context, gameState, handCenter)
        : <DiscardItem>[];

    await animOrchestrator.runSwapSequence(
      context: context,
      discardItems: discardItems,
      drawCount: selectedIndices.length,
      deckCenter: deckCenter,
      handCenter: handCenter,
      currentHandLength: gameState.playerHand.length - selectedIndices.length,
      cardSpacing: GameConstants.playerCardSpacing,
      cardHeight: GameConstants.cardHeight,
      isPlayer: true,
      onDiscardComplete: () {
        ref.read(gameProvider.notifier).discardSelectedCards();
        ref.read(gameProvider.notifier).setIsAnimating(false);
      },
      onDrawComplete: () {
        ref.read(gameProvider.notifier).drawNewCards();
      },
    );

    _isAnimating = false;
  }

  Future<void> triggerAiSwap(List<int> indices) async {
    if (indices.isEmpty) return;

    ref.read(gameProvider.notifier).setIsAnimating(true);

    final deckCenter = _getWidgetCenter(deckKey);
    final aiHandCenter = _getWidgetCenter(aiHandKey);
    final gameState = ref.read(gameProvider);
    final context = getContext();

    final discardItems = aiHandCenter != null
        ? _buildAiDiscardItems(context, gameState, indices, aiHandCenter)
        : <DiscardItem>[];

    await animOrchestrator.runSwapSequence(
      context: context,
      discardItems: discardItems,
      drawCount: indices.length,
      deckCenter: deckCenter,
      handCenter: aiHandCenter,
      currentHandLength: gameState.aiHand.length - indices.length,
      cardSpacing: GameConstants.aiCardSpacing,
      cardHeight: GameConstants.aiScaledCardHeight,
      isPlayer: false,
      onDiscardComplete: () {
        ref.read(gameProvider.notifier).aiDiscardSelectedCards();
        ref.read(gameProvider.notifier).setIsAnimating(false);
      },
      onDrawComplete: () {
        ref.read(gameProvider.notifier).aiDrawNewCards();
      },
    );
  }

  List<DiscardItem> _buildPlayerDiscardItems(
    BuildContext context,
    GameState gameState,
    Offset handCenter,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final handWidth =
        gameState.playerHand.length * GameConstants.playerCardSpacing +
        GameConstants.cardHandPadding;
    final startXBase = screenWidth / 2 - handWidth / 2;

    return gameState.selectedIndices.map((index) {
      final card = gameState.playerHand[index];
      final startX = startXBase + index * GameConstants.playerCardSpacing;
      final startY =
          handCenter.dy -
          (GameConstants.cardHeight / 2) -
          GameConstants.selectedCardOffset;
      return DiscardItem(card, startX, startY);
    }).toList();
  }

  List<DiscardItem> _buildAiDiscardItems(
    BuildContext context,
    GameState gameState,
    List<int> indices,
    Offset aiHandCenter,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final handWidth =
        gameState.aiHand.length * GameConstants.aiCardSpacing +
        GameConstants.cardHandPadding;
    final startXBase = screenWidth / 2 - handWidth / 2;

    return indices.map((index) {
      final card = gameState.aiHand[index];
      final startX = startXBase + index * GameConstants.aiCardSpacing;
      final startY = aiHandCenter.dy - (GameConstants.aiScaledCardHeight / 2);
      return DiscardItem(card, startX, startY);
    }).toList();
  }
}
