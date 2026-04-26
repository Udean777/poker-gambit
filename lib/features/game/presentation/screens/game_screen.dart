import 'package:card_games/core/theme/game_theme.dart';
import 'package:card_games/features/game/domain/models/game_state.dart';
import 'package:card_games/features/game/presentation/controllers/game_swap_controller.dart';
import 'package:card_games/features/game/presentation/controllers/swap_animation_orchestrator.dart';
import 'package:card_games/features/game/presentation/providers/game_notifier.dart';
import 'package:card_games/features/game/presentation/providers/game_provider.dart';
import 'package:card_games/features/game/presentation/widgets/deck_pile.dart';
import 'package:card_games/features/game/presentation/widgets/drawing_overlay.dart';
import 'package:card_games/features/game/presentation/widgets/game_over_dialog.dart';
import 'package:card_games/features/game/presentation/widgets/game_overlays.dart';
import 'package:card_games/features/game/presentation/widgets/opponent_area.dart';
import 'package:card_games/features/game/presentation/widgets/player_hand.dart';
import 'package:card_games/features/game/presentation/widgets/player_info.dart';
import 'package:card_games/features/game/presentation/widgets/poker_table.dart';
import 'package:card_games/features/game/presentation/widgets/score_board.dart';
import 'package:card_games/features/game/presentation/widgets/status_message.dart';
import 'package:card_games/features/game/presentation/widgets/table_background.dart';
import 'package:card_games/features/menu/presentation/widgets/rules_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  final _deckKey = GlobalKey();
  final _handKey = GlobalKey();
  final _aiHandKey = GlobalKey();

  late final GameSwapController _swapController;

  @override
  void initState() {
    super.initState();
    _swapController = GameSwapController(
      ref: ref,
      getContext: () => context,
      deckKey: _deckKey,
      handKey: _handKey,
      aiHandKey: _aiHandKey,
      animOrchestrator: SwapAnimationOrchestrator(this),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _showRulesDialog());
  }

  Future<void> _showRulesDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const RulesDialog(),
    );
    if (mounted) ref.read(gameProvider.notifier).startTurnTimer();
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

  void _listenForAiSwap() {
    ref.listen<List<int>>(gameProvider.select((s) => s.aiSelectedIndices), (
      prev,
      current,
    ) {
      if (current.isNotEmpty && current != _swapController.lastAiSelection) {
        _swapController.lastAiSelection = current;
        _swapController.triggerAiSwap(current);
      }
    });
  }

  void _listenForGameOver() {
    ref.listen<bool>(gameProvider.select((s) => s.isGameOver), (
      prev,
      isGameOver,
    ) {
      if (isGameOver && !(prev ?? false)) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _showGameOverDialog(),
        );
      }
    });
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
            _GameDeckPile(deckKey: _deckKey, gameState: gameState),
            SafeArea(
              child: _GameMainLayout(
                gameState: gameState,
                gameLogic: gameLogic,
                handKey: _handKey,
                aiHandKey: _aiHandKey,
              ),
            ),
            _GameControls(gameState: gameState, gameLogic: gameLogic),
            if (gameState.isPaused)
              PauseOverlay(
                gameLogic: gameLogic,
                onExitToMenu: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
              ),
            if (gameState.qteActive) QteOverlay(gameLogic: gameLogic),
            if (_shouldShowSwapOverlay(gameState))
              DrawingOverlay(
                selectedCount: gameState.selectedIndices.length,
                onExecute: _swapController.isAnimating
                    ? null
                    : _swapController.triggerPlayerSwap,
                isMidGame: gameState.phase == GamePhase.playing,
              ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowSwapOverlay(GameState gameState) =>
      gameState.phase == GamePhase.drawing ||
      (gameState.phase == GamePhase.playing && gameState.playerCanSwap);
}

class _GameDeckPile extends StatelessWidget {
  final GlobalKey deckKey;
  final GameState gameState;

  const _GameDeckPile({required this.deckKey, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 15,
      top: 260,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: -0.1,
          child: Transform.scale(
            scale: 0.5,
            child: DeckPile(
              key: deckKey,
              remainingCards: gameState.deck.length,
            ),
          ),
        ),
      ),
    );
  }
}

class _GameMainLayout extends StatelessWidget {
  final GameState gameState;
  final GameNotifier gameLogic;
  final GlobalKey handKey;
  final GlobalKey aiHandKey;

  const _GameMainLayout({
    required this.gameState,
    required this.gameLogic,
    required this.handKey,
    required this.aiHandKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Center(
          child: ScoreBoard(
            playerName: 'USER',
            playerScore: gameState.playerScore,
            aiName: 'AI',
            aiScore: gameState.aiScore,
          ),
        ),
        const SizedBox(height: 6),
        PlayerInfo(
          name: 'AI MASTER',
          isTurn: !gameState.isPlayerTurn,
          accentColor: GameTheme.aiRed,
          avatarIcon: Icons.psychology,
          timeLeft: !gameState.isPlayerTurn ? gameState.timeLeft : null,
        ),
        const SizedBox(height: 4),
        OpponentArea(key: aiHandKey, aiHand: gameState.aiHand),
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
          name: 'YOU',
          isTurn: gameState.isPlayerTurn,
          accentColor: GameTheme.playerBlue,
          avatarIcon: Icons.person,
          timeLeft: gameState.isPlayerTurn ? gameState.timeLeft : null,
        ),
        PlayerHand(
          key: handKey,
          playerHand: gameState.playerHand,
          isPlayerTurn: gameState.isPlayerTurn,
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _GameControls extends StatelessWidget {
  final GameState gameState;
  final GameNotifier gameLogic;

  const _GameControls({required this.gameState, required this.gameLogic});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 50,
          left: 20,
          child: IconButton(
            icon: const Icon(
              Icons.help_outline,
              color: Colors.white70,
              size: 28,
            ),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const RulesDialog(),
            ),
          ),
        ),
        Positioned(
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
        ),
      ],
    );
  }
}
