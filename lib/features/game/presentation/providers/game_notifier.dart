import 'dart:async';
import 'package:card_games/core/constants/game_constants.dart';
import 'package:card_games/core/utils/card_utils.dart';
import 'package:card_games/features/game/domain/models/card_model.dart';
import 'package:card_games/features/game/domain/models/game_state.dart';
import 'package:card_games/features/game/domain/services/i_deck_service.dart';
import 'package:card_games/features/game/domain/services/i_poker_ai_service.dart';
import 'package:card_games/features/game/domain/usecases/apply_card_effect_usecase.dart';
import 'package:card_games/features/game/domain/usecases/evaluate_round_usecase.dart';
import 'package:card_games/features/game/domain/usecases/execute_ai_turn_usecase.dart';
import 'package:card_games/features/game/domain/usecases/get_stats_usecase.dart';
import 'package:card_games/features/game/domain/usecases/play_card_usecase.dart';
import 'package:card_games/features/game/domain/usecases/save_game_result_usecase.dart';
import 'package:card_games/features/game/domain/usecases/start_new_game_usecase.dart';
import 'package:card_games/features/game/domain/usecases/swap_cards_usecase.dart';
import 'package:card_games/features/game/presentation/providers/mixins/game_timer_mixin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameNotifier extends StateNotifier<GameState> with GameTimerMixin {
  final StartNewGameUseCase _startNewGameUseCase;
  final SwapCardsUseCase _swapCardsUseCase;
  final PlayCardUseCase _playCardUseCase;
  final EvaluateRoundUseCase _evaluateRoundUseCase;
  final ExecuteAiTurnUseCase _executeAiTurnUseCase;
  final ApplyCardEffectUseCase _applyCardEffectUseCase;
  final GetStatsUseCase _getStatsUseCase;
  final SaveGameResultUseCase _saveGameResultUseCase;
  final IPokerAiService _aiService;
  final IDeckService _deckService;

  GameNotifier({
    required StartNewGameUseCase startNewGameUseCase,
    required SwapCardsUseCase swapCardsUseCase,
    required PlayCardUseCase playCardUseCase,
    required EvaluateRoundUseCase evaluateRoundUseCase,
    required ExecuteAiTurnUseCase executeAiTurnUseCase,
    required ApplyCardEffectUseCase applyCardEffectUseCase,
    required GetStatsUseCase getStatsUseCase,
    required SaveGameResultUseCase saveGameResultUseCase,
    required IPokerAiService aiService,
    required IDeckService deckService,
  })  : _startNewGameUseCase = startNewGameUseCase,
        _swapCardsUseCase = swapCardsUseCase,
        _playCardUseCase = playCardUseCase,
        _evaluateRoundUseCase = evaluateRoundUseCase,
        _executeAiTurnUseCase = executeAiTurnUseCase,
        _applyCardEffectUseCase = applyCardEffectUseCase,
        _getStatsUseCase = getStatsUseCase,
        _saveGameResultUseCase = saveGameResultUseCase,
        _aiService = aiService,
        _deckService = deckService,
        super(const GameState(deck: [], playerHand: [], aiHand: [])) {
    _init();
  }

  Future<void> _init() async {
    final stats = await _getStatsUseCase();
    state = _startNewGameUseCase.execute(highScore: stats.highScore);
    startTurnTimer();
  }

  void setIsAnimating(bool value) => state = state.copyWith(isAnimating: value);
  void togglePause() => state = state.copyWith(isPaused: !state.isPaused);
  void startNewGame() {
    state = _startNewGameUseCase.execute(highScore: state.highScore);
  }

  // ─── Timer Orchestration ──────────────────────────────────────────

  void startTurnTimer() {
    if (state.phase == GamePhase.drawing) {
      startTimer(
        GameConstants.drawPhaseSeconds,
        onTimeout: () {
          if (mounted) executeDraw();
        },
      );
    } else if (state.phase == GamePhase.playing && state.isPlayerTurn) {
      startTimer(GameConstants.playPhaseSeconds, onTimeout: _onPlayTimeout);
    }
  }

  void _onPlayTimeout() {
    if (state.phase == GamePhase.playing &&
        state.isPlayerTurn &&
        state.playerHand.isNotEmpty) {
      playCard(state.playerHand.first);
    }
  }

  void onCounter() {
    if (state.qteActive) {
      state = state.copyWith(qteActive: false, message: 'COUNTER SUCCESSFUL!');
    }
  }

  // ─── Player Actions ───────────────────────────────────────────────

  void toggleCardSelection(int index) {
    if (state.phase != GamePhase.drawing && state.phase != GamePhase.playing ||
        !state.playerCanSwap) {
      return;
    }
    final selection = List<int>.from(state.selectedIndices);
    if (selection.contains(index)) {
      selection.remove(index);
    } else if (selection.length < GameConstants.maxSwapCards) {
      selection.add(index);
    }
    state = state.copyWith(selectedIndices: selection);
  }

  void executeDraw() {
    if (state.phase != GamePhase.drawing && state.phase != GamePhase.playing ||
        !state.playerCanSwap) {
      return;
    }
    cancelTimer();
    discardSelectedCards();
    drawNewCards();
  }

  void discardSelectedCards() {
    if (state.phase != GamePhase.drawing && state.phase != GamePhase.playing ||
        !state.playerCanSwap) {
      return;
    }
    state = state.copyWith(
      playerHand: CardUtils.removeAtIndices(
        state.playerHand,
        state.selectedIndices,
      ),
    );
  }

  void drawNewCards() {
    if (state.phase != GamePhase.drawing && state.phase != GamePhase.playing ||
        !state.playerCanSwap) {
      return;
    }
    final isInitial = state.phase == GamePhase.drawing;
    state = _swapCardsUseCase.execute(
      currentState: state,
      selectedIndices: state.selectedIndices,
    );
    if (isInitial) {
      Future.delayed(GameConstants.aiSwapDelay, _executeAiSwapPhase);
    }
  }

  void playCard(CardModel card) async {
    if (state.phase != GamePhase.playing || !state.isPlayerTurn) return;
    cancelTimer();

    final isHidden =
        state.playerTableCards.length == 1 ||
        state.playerTableCards.length == 3;
    final playedCard = card.copyWith(isFaceUp: !isHidden);

    state = _playCardUseCase.execute(
      currentState: state,
      card: card,
      isPlayer: true,
    );
    await _applyCardEffect(playedCard, true);

    if (state.aiHand.isEmpty && state.playerHand.isEmpty) {
      _transitionToShowdown();
    } else if (state.aiHand.isEmpty) {
      state = state.copyWith(
        isPlayerTurn: true,
        message: 'AI kehabisan kartu!',
      );
      startTurnTimer();
    } else {
      Future.delayed(GameConstants.aiPlayDelay, _executeAiTurn);
    }
  }

  // ─── AI Orchestration ─────────────────────────────────────────────

  Future<void> _executeAiSwapPhase() async {
    final decision = await _aiService.decideDiscard(
      state.aiHand,
      canWait: true,
    );
    final action = decision['action'] as String;
    final indices =
        (decision['indices'] as List)
            .cast<int>()
            .toSet()
            .where((i) => i >= 0 && i < state.aiHand.length)
            .toList()
          ..sort((a, b) => b.compareTo(a));

    if (action == 'swap' && indices.isNotEmpty) {
      state = state.copyWith(
        aiSelectedIndices: indices,
        message: 'AI: ${decision['message']}',
      );
    } else {
      state = state.copyWith(
        aiCanSwap: action == 'wait',
        message: 'AI: ${decision['message']}',
        phase: GamePhase.playing,
        isPlayerTurn: true,
      );
      startTurnTimer();
    }
  }

  void aiDiscardSelectedCards() {
    state = state.copyWith(
      aiHand: CardUtils.removeAtIndices(state.aiHand, state.aiSelectedIndices),
    );
  }

  void aiDrawNewCards() {
    state = _swapCardsUseCase.execute(
      currentState: state,
      selectedIndices: state.aiSelectedIndices,
      isPlayer: false,
    );
    startTurnTimer();
  }

  Future<void> _executeAiTurn() async {
    while (state.isPaused) {
      await Future.delayed(GameConstants.pauseCheckDelay);
    }

    final result = await _executeAiTurnUseCase.execute(state);
    if (result == null) return;

    if (result.stateAfterSwap != state) {
      state = result.stateAfterSwap;
      await Future.delayed(GameConstants.aiSwapDelay);
    }

    state = result.stateAfterPlay;
    await _applyCardEffect(result.playedCard, false);

    if (state.aiHand.isEmpty && state.playerHand.isEmpty) {
      _transitionToShowdown();
    } else if (state.playerHand.isEmpty) {
      state = state.copyWith(
        isPlayerTurn: false,
        message: 'AI lanjut bermain...',
      );
      Future.delayed(GameConstants.aiPlayDelay, _executeAiTurn);
    } else {
      state = state.copyWith(isPlayerTurn: true, phase: GamePhase.playing);
      startTurnTimer();
    }
  }

  // ─── Card Effects & Evaluation ────────────────────────────────────

  Future<void> _applyCardEffect(CardModel card, bool isPlayer) async {
    bool shouldApply = true;

    if (!isPlayer &&
        (card.valueLabel == 'J' || card.valueLabel == 'Q' || card.isJoker)) {
      state = state.copyWith(qteActive: true, message: 'AI SKILL! COUNTER!');
      await Future.delayed(GameConstants.qteDuration);
      if (!state.qteActive) {
        shouldApply = false;
      }
      state = state.copyWith(qteActive: false);
    }

    if (shouldApply) {
      state = await _applyCardEffectUseCase.execute(
        card,
        state,
        isPlayer: isPlayer,
      );

      if (card.valueLabel == 'J') {
        await Future.delayed(GameConstants.spyRevealDuration);
        if (mounted) {
          final targetHand = isPlayer ? state.aiHand : state.playerHand;
          final hiddenHand = targetHand
              .map((c) => c.copyWith(isFaceUp: false))
              .toList();
          state = isPlayer
              ? state.copyWith(aiHand: hiddenHand)
              : state.copyWith(playerHand: hiddenHand);
        }
      }
    }
  }

  Future<void> evaluateRound() async {
    while (state.isPaused) {
      await Future.delayed(GameConstants.pauseCheckDelay);
    }
    state = _evaluateRoundUseCase.execute(state);

    if (state.lastPlayerHandRank != null) {
      final isWin = state.lastRoundPlayerWon ?? false;
      if (state.playerScore > state.highScore) {
        state = state.copyWith(highScore: state.playerScore);
      }
      await _saveGameResultUseCase(
        score: state.playerScore,
        isWin: isWin,
        playerHand: state.lastPlayerHandRank!,
      );
    }

    Future.delayed(GameConstants.nextRoundDelay, _startNextRound);
  }

  void _transitionToShowdown() {
    state = state.copyWith(
      playerTableCards: state.playerTableCards
          .map((c) => c.copyWith(isFaceUp: true))
          .toList(),
      aiTableCards: state.aiTableCards
          .map((c) => c.copyWith(isFaceUp: true))
          .toList(),
      phase: GamePhase.showdown,
      message: 'Showdown!',
    );
    Future.delayed(GameConstants.showdownDelay, evaluateRound);
  }

  void _startNextRound() {
    if (state.deck.length < GameConstants.minDeckForNewRound) {
      state = state.copyWith(isGameOver: true, phase: GamePhase.gameOver);
      return;
    }
    final deal = _deckService.dealInitialHands(state.deck);
    state = state.copyWith(
      deck: deal.remainingDeck,
      playerHand: deal.playerHand,
      aiHand: deal.aiHand,
      playerTableCards: [],
      aiTableCards: [],
      phase: GamePhase.drawing,
      isPlayerTurn: true,
      aiCanSwap: true,
      playerCanSwap: true,
      message: 'Ronde Baru!',
    );
    startTurnTimer();
  }
}
