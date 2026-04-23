import 'package:card_games/core/constants/game_constants.dart';
import 'package:card_games/core/theme/game_theme.dart';
import 'package:card_games/features/game/domain/models/game_state.dart';
import 'package:card_games/features/game/presentation/controllers/swap_animation_orchestrator.dart';
import 'package:card_games/features/game/presentation/providers/game_notifier.dart';
import 'package:card_games/features/game/presentation/providers/game_provider.dart';
import 'package:card_games/features/game/presentation/widgets/animations/discard_animation.dart';
import 'package:card_games/features/game/presentation/widgets/deck_pile.dart';
import 'package:card_games/features/game/presentation/widgets/drawing_overlay.dart';
import 'package:card_games/features/game/presentation/widgets/game_over_dialog.dart';
import 'package:card_games/features/game/presentation/widgets/opponent_area.dart';
import 'package:card_games/features/game/presentation/widgets/player_hand.dart';
import 'package:card_games/features/game/presentation/widgets/player_info.dart';
import 'package:card_games/features/game/presentation/widgets/poker_table.dart';
import 'package:card_games/features/menu/presentation/widgets/rules_dialog.dart';
import 'package:card_games/features/game/presentation/widgets/score_board.dart';
import 'package:card_games/features/game/presentation/widgets/status_message.dart';
import 'package:card_games/features/game/presentation/widgets/table_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  final GlobalKey _deckKey = GlobalKey();
  final GlobalKey _handKey = GlobalKey();
  final GlobalKey _aiHandKey = GlobalKey();

  late final SwapAnimationOrchestrator _animOrchestrator;
  bool _isAnimating = false;
  List<int>? _lastAiSelection;

  @override
  void initState() {
    super.initState();
    _animOrchestrator = SwapAnimationOrchestrator(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _showRulesDialog());
  }

  Future<void> _showRulesDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const RulesDialog(),
    );
    if (mounted) {
      ref.read(gameProvider.notifier).startTurnTimer();
    }
  }

  Future<void> _showGameOverDialog() async {
    final gameState = ref.read(gameProvider);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameOverDialog(
        playerScore: gameState.playerScore,
        aiScore: gameState.aiScore,
        onRestart: () {
          ref.read(gameProvider.notifier).startNewGame();
          ref.read(gameProvider.notifier).startTurnTimer();
        },
      ),
    );
  }

  Offset? _getWidgetCenter(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final pos = box.localToGlobal(Offset.zero);
    return Offset(pos.dx + box.size.width / 2, pos.dy + box.size.height / 2);
  }

  Future<void> _triggerPlayerSwap() async {
    if (_isAnimating) return;

    final gameState = ref.read(gameProvider);
    final selectedIndices = gameState.selectedIndices;

    if (selectedIndices.isEmpty) {
      ref.read(gameProvider.notifier).executeDraw();
      return;
    }

    setState(() => _isAnimating = true);
    ref.read(gameProvider.notifier).setIsAnimating(true);
    ref.read(gameProvider.notifier).cancelTimer();

    final deckCenter = _getWidgetCenter(_deckKey);
    final handCenter = _getWidgetCenter(_handKey);

    final discardItems = handCenter != null
        ? _buildPlayerDiscardItems(gameState, handCenter)
        : <DiscardItem>[];

    await _animOrchestrator.runSwapSequence(
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

    if (mounted) setState(() => _isAnimating = false);
  }

  List<DiscardItem> _buildPlayerDiscardItems(
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

  Future<void> _triggerAiSwap(List<int> indices) async {
    if (indices.isEmpty) return;

    ref.read(gameProvider.notifier).setIsAnimating(true);

    final deckCenter = _getWidgetCenter(_deckKey);
    final aiHandCenter = _getWidgetCenter(_aiHandKey);
    final gameState = ref.read(gameProvider);

    final discardItems = aiHandCenter != null
        ? _buildAiDiscardItems(gameState, indices, aiHandCenter)
        : <DiscardItem>[];

    await _animOrchestrator.runSwapSequence(
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

  List<DiscardItem> _buildAiDiscardItems(
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

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final gameLogic = ref.read(gameProvider.notifier);

    _listenForAiSwap();
    _listenForGameOver();

    return Scaffold(
      body: Container(
        decoration: GameTheme.tableGradient,
        child: Stack(
          children: [
            const TableBackground(),
            _buildDeckPile(gameState),
            SafeArea(child: _buildMainLayout(gameState, gameLogic)),
            _buildPauseButton(gameState, gameLogic),
            _buildRulesButton(),
            if (gameState.isPaused) _buildPauseOverlay(gameLogic),
            if (gameState.qteActive) _buildQteOverlay(gameLogic),
            if (_shouldShowSwapOverlay(gameState))
              DrawingOverlay(
                selectedCount: gameState.selectedIndices.length,
                onExecute: _isAnimating ? null : _triggerPlayerSwap,
                isMidGame: gameState.phase == GamePhase.playing,
              ),
          ],
        ),
      ),
    );
  }

  void _listenForAiSwap() {
    ref.listen<List<int>>(gameProvider.select((s) => s.aiSelectedIndices), (
      prev,
      current,
    ) {
      if (current.isNotEmpty && current != _lastAiSelection) {
        _lastAiSelection = current;
        _triggerAiSwap(current);
      }
    });
  }

  void _listenForGameOver() {
    ref.listen<bool>(gameProvider.select((s) => s.isGameOver), (
      previous,
      isGameOver,
    ) {
      if (isGameOver && !(previous ?? false)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showGameOverDialog();
        });
      }
    });
  }

  bool _shouldShowSwapOverlay(GameState gameState) {
    return gameState.phase == GamePhase.drawing ||
        (gameState.phase == GamePhase.playing && gameState.playerCanSwap);
  }

  Widget _buildDeckPile(GameState gameState) {
    return Positioned(
      left: 15,
      top: 260,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: -0.1,
          child: Transform.scale(
            scale: 0.5,
            child: DeckPile(
              key: _deckKey,
              remainingCards: gameState.deck.length,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainLayout(GameState gameState, GameNotifier gameLogic) {
    return Column(
      children: [
        const SizedBox(height: 8),

        Center(
          child: ScoreBoard(
            playerName: "USER",
            playerScore: gameState.playerScore,
            aiName: "AI",
            aiScore: gameState.aiScore,
          ),
        ),
        const SizedBox(height: 6),

        PlayerInfo(
          name: "AI MASTER",
          isTurn: !gameState.isPlayerTurn,
          accentColor: GameTheme.aiRed,
          avatarIcon: Icons.psychology,
        ),
        const SizedBox(height: 4),
        OpponentArea(key: _aiHandKey, aiHand: gameState.aiHand),
        const SizedBox(height: 4),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: PokerTable(
              playerTableCards: gameState.playerTableCards,
              aiTableCards: gameState.aiTableCards,
              isPlayerTurn: gameState.isPlayerTurn,
              isShowdown: gameState.isShowdown,
              onCardDropped: gameLogic.playCard,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: StatusMessage(message: gameState.message),
        ),

        PlayerInfo(
          name: "YOU",
          isTurn: gameState.isPlayerTurn,
          accentColor: GameTheme.playerBlue,
          avatarIcon: Icons.person,
          timeLeft: gameState.timeLeft,
        ),
        PlayerHand(
          key: _handKey,
          playerHand: gameState.playerHand,
          isPlayerTurn: gameState.isPlayerTurn,
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildRulesButton() {
    return Positioned(
      top: 50,
      left: 20,
      child: IconButton(
        icon: const Icon(Icons.help_outline, color: Colors.white70, size: 28),
        onPressed: () {
          showDialog(context: context, builder: (_) => const RulesDialog());
        },
      ),
    );
  }

  Widget _buildQteOverlay(GameNotifier gameLogic) {
    return Container(
      color: Colors.red.withValues(alpha: 0.15),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "!!! AI SKILL !!!",
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: gameLogic.onCounter,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "COUNTER!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPauseButton(GameState gameState, GameNotifier gameLogic) {
    return Positioned(
      top: 50,
      right: 20,
      child: IconButton(
        icon: Icon(
          gameState.isPaused ? Icons.play_arrow : Icons.pause,
          color: Colors.white,
          size: 28,
        ),
        onPressed: gameLogic.togglePause,
      ),
    );
  }

  Widget _buildPauseOverlay(GameNotifier gameLogic) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.pause_circle_filled,
              color: Colors.white,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              "GAME PAUSED",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: GameTheme.accentAmber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: gameLogic.togglePause,
              child: const Text("RESUME"),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text(
                "EXIT TO MENU",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
