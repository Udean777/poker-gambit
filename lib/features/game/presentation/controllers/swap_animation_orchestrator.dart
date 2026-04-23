import 'package:card_games/core/constants/game_constants.dart';
import 'package:card_games/features/game/presentation/widgets/animations/discard_animation.dart';
import 'package:card_games/features/game/presentation/widgets/animations/draw_animation.dart';
import 'package:flutter/material.dart';

/// Orchestrates the two-phase swap animation (discard → draw).
///
/// Extracted from [GameScreen] to follow the Single Responsibility Principle.
/// The screen delegates all animation sequencing to this class, keeping
/// the widget tree focused on layout and state management.
class SwapAnimationOrchestrator {
  final TickerProvider _vsync;

  SwapAnimationOrchestrator(this._vsync);

  /// Runs the full swap sequence: discard selected cards, then draw new ones.
  ///
  /// [discardItems] — cards to animate flying away.
  /// [drawCount] — number of new cards to animate arriving.
  /// [deckCenter] — screen position of the deck pile widget.
  /// [handCenter] — screen position of the target hand widget.
  /// [currentHandLength] — cards remaining after discard (for positioning).
  /// [cardSpacing] — horizontal spacing between cards in the hand.
  /// [cardHeight] — visual height of cards (used for Y positioning).
  /// [isPlayer] — true for player animations, false for AI.
  /// [onDiscardComplete] — called after discard animation + state update.
  /// [onDrawComplete] — called after draw animation + state update.
  Future<void> runSwapSequence({
    required BuildContext context,
    required List<DiscardItem> discardItems,
    required int drawCount,
    required Offset? deckCenter,
    required Offset? handCenter,
    required int currentHandLength,
    required double cardSpacing,
    required double cardHeight,
    required bool isPlayer,
    required VoidCallback onDiscardComplete,
    required VoidCallback onDrawComplete,
  }) async {
    final overlay = Overlay.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // ── Phase 1: Discard animation (cards fly away) ──────────────────
    if (discardItems.isNotEmpty) {
      await _playOverlayAnimation(
        overlay: overlay,
        duration: GameConstants.discardAnimDuration,
        builder: (controller) => DiscardAnimation(
          items: discardItems,
          controller: controller,
          isPlayer: isPlayer,
        ),
      );
    }

    onDiscardComplete();

    // Wait for AnimatedPositioned gap-closing in the hand widget
    await Future.delayed(GameConstants.gapCloseDelay);

    // ── Phase 2: Draw animation (card backs fly from deck to hand) ───
    if (deckCenter != null && handCenter != null && drawCount > 0) {
      final drawItems = _buildDrawItems(
        screenWidth: screenWidth,
        handCenter: handCenter,
        currentHandLength: currentHandLength,
        drawCount: drawCount,
        cardSpacing: cardSpacing,
        cardHeight: cardHeight,
      );

      await _playOverlayAnimation(
        overlay: overlay,
        duration: GameConstants.drawAnimDuration,
        builder: (controller) => DrawAnimation(
          items: drawItems,
          fromOffset: deckCenter,
          controller: controller,
          isPlayer: isPlayer,
        ),
      );
    }

    onDrawComplete();
  }

  /// Builds target positions for drawn cards in the hand.
  List<DrawItem> _buildDrawItems({
    required double screenWidth,
    required Offset handCenter,
    required int currentHandLength,
    required int drawCount,
    required double cardSpacing,
    required double cardHeight,
  }) {
    final newHandLength = currentHandLength + drawCount;
    final newHandWidth =
        newHandLength * cardSpacing + GameConstants.cardHandPadding;
    final targetXBase = screenWidth / 2 - newHandWidth / 2;

    return List.generate(drawCount, (i) {
      final targetX = targetXBase + (currentHandLength + i) * cardSpacing;
      final targetY = handCenter.dy - (cardHeight / 2);
      return DrawItem(targetX, targetY);
    });
  }

  /// Plays a single overlay animation and cleans up after completion.
  Future<void> _playOverlayAnimation({
    required OverlayState overlay,
    required Duration duration,
    required Widget Function(AnimationController controller) builder,
  }) async {
    final controller = AnimationController(vsync: _vsync, duration: duration);

    OverlayEntry? entry;
    entry = OverlayEntry(builder: (_) => builder(controller));
    overlay.insert(entry);

    await controller.forward();

    entry.remove();
    controller.dispose();
  }
}
