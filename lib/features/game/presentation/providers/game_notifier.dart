import 'dart:async';
import 'package:poker_gambit/core/constants/game_constants.dart';
import 'package:poker_gambit/core/utils/card_utils.dart';
import 'package:poker_gambit/features/game/domain/logic/i_poker_evaluator.dart';
import 'package:poker_gambit/features/game/domain/models/card_model.dart';
import 'package:poker_gambit/features/game/domain/models/game_state.dart';
import 'package:poker_gambit/features/game/domain/services/i_deck_service.dart';
import 'package:poker_gambit/features/game/domain/services/i_poker_ai_service.dart';
import 'package:poker_gambit/features/game/domain/usecases/apply_card_effect_usecase.dart';
import 'package:poker_gambit/features/game/domain/usecases/evaluate_round_usecase.dart';
import 'package:poker_gambit/features/game/domain/usecases/execute_ai_turn_usecase.dart';
import 'package:poker_gambit/features/game/domain/usecases/get_stats_usecase.dart';
import 'package:poker_gambit/features/game/domain/usecases/play_card_usecase.dart';
import 'package:poker_gambit/features/game/domain/usecases/save_game_result_usecase.dart';
import 'package:poker_gambit/features/game/domain/usecases/start_new_game_usecase.dart';
import 'package:poker_gambit/features/game/domain/usecases/swap_cards_usecase.dart';
import 'package:poker_gambit/features/game/presentation/providers/mixins/game_timer_mixin.dart';
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
  final IPokerEvaluator _evaluator;

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
    required IPokerEvaluator evaluator,
  }) : _startNewGameUseCase = startNewGameUseCase,
       _swapCardsUseCase = swapCardsUseCase,
       _playCardUseCase = playCardUseCase,
       _evaluateRoundUseCase = evaluateRoundUseCase,
       _executeAiTurnUseCase = executeAiTurnUseCase,
       _applyCardEffectUseCase = applyCardEffectUseCase,
       _getStatsUseCase = getStatsUseCase,
       _saveGameResultUseCase = saveGameResultUseCase,
       _aiService = aiService,
       _deckService = deckService,
       _evaluator = evaluator,
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
    } else if (state.phase == GamePhase.playing) {
      // Both Player and AI have a visible timer during their turn
      startTimer(GameConstants.playPhaseSeconds, onTimeout: _onPlayTimeout);
    }
  }

  void _onPlayTimeout() {
    if (state.phase == GamePhase.playing) {
      if (state.isPlayerTurn && state.playerHand.isNotEmpty) {
        playCard(state.playerHand.first);
      }
      // For AI, it usually completes its turn via API before the timer runs out.
      // If it times out, the API call might still be pending, so we don't force a card play here
      // to avoid race conditions with the actual AI response.
    }
  }

  void onWitchCardSelected(CardModel selected) {
    if (!state.isWitchPicking) return;

    final isPlayerSource = state.witchSourceIsPlayer ?? false;
    final targetHand = isPlayerSource ? state.aiHand : state.playerHand;
    if (targetHand.isEmpty) return;

    final randomIndex = DateTime.now().millisecond % targetHand.length;
    final newHand = List<CardModel>.from(targetHand);
    final oldCard = newHand[randomIndex];

    // Sabotage: card replaces a random card in opponent's hand
    newHand[randomIndex] = selected.copyWith(isFaceUp: oldCard.isFaceUp);

    // Other cards go back to bottom of deck
    final otherCards = state.witchOptions.where((c) => c != selected).toList();
    final newDeck = [...state.deck, ...otherCards];

    state = state.copyWith(
      aiHand: isPlayerSource ? newHand : state.aiHand,
      playerHand: isPlayerSource ? state.playerHand : newHand,
      deck: newDeck,
      isWitchPicking: false,
      witchOptions: [],
      message: isPlayerSource
          ? 'WITCH: AI tersabotase!'
          : 'AI WITCH: Anda tersabotase!',
    );
  }

  void onSpyCardSelected(CardModel selected) {
    if (!state.isSpyPicking) return;

    state = state.copyWith(spySelectedCard: selected);

    // Close overlay after 5 seconds
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        state = state.copyWith(
          isSpyPicking: false,
          spyOptions: [],
          spySelectedCard: null,
        );
      }
    });
  }

  void dismissRoundResult() {
    state = state.copyWith(showRoundResult: false);
    // After result is dismissed, we check if game should end or start new round
    if (state.deck.isEmpty &&
        state.playerHand.isEmpty &&
        state.aiHand.isEmpty) {
      // Game over logic is already handled in evaluateRound via UseCase
    } else {
      // Logic for next turn/round could go here
    }
  }

  void onDestroyCardSelected(CardModel selected) async {
    if (!state.isDestroyPicking) return;

    final isPlayerSource = state.destroySourceIsPlayer ?? false;

    // Set the card being destroyed to trigger animation
    state = state.copyWith(cardBeingDestroyed: selected);

    // Wait for "Burn" animation
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final targetTable = isPlayerSource
        ? state.aiTableCards
        : state.playerTableCards;
    final newTable = targetTable.where((c) => c != selected).toList();

    state = state.copyWith(
      aiTableCards: isPlayerSource ? newTable : state.aiTableCards,
      playerTableCards: isPlayerSource ? state.playerTableCards : newTable,
      isDestroyPicking: false,
      cardBeingDestroyed: null,
      message: isPlayerSource
          ? 'JOKER: Kartu AI dihancurkan!'
          : 'AI JOKER: Kartu Anda dihancurkan!',
    );
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
      // Start a visual timer for the AI's turn to swap
      startTimer(GameConstants.drawPhaseSeconds, onTimeout: () {});
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
      startTurnTimer(); // Start timer for AI turn
      Future.delayed(GameConstants.aiPlayDelay, _executeAiTurn);
    }
  }

  // ─── AI Orchestration ─────────────────────────────────────────────

  Future<void> _executeAiSwapPhase() async {
    // Berikan jeda berpikir agar tidak terlalu kaku
    await Future.delayed(const Duration(milliseconds: 1200));

    final decision = await _aiService.decideDiscard(
      state.aiHand,
      canWait: true,
      timeLeft: state.timeLeft,
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
      startTurnTimer(); // Start timer for chained AI turn
      Future.delayed(GameConstants.aiPlayDelay, _executeAiTurn);
    } else {
      state = state.copyWith(isPlayerTurn: true, phase: GamePhase.playing);
      startTurnTimer();
    }
  }

  // ─── Card Effects & Evaluation ────────────────────────────────────

  Future<void> _applyCardEffect(CardModel card, bool isPlayer) async {
    // Skills now apply directly as part of the "punish" mechanic
    bool shouldApply = true;

    if (shouldApply) {
      state = await _applyCardEffectUseCase.execute(
        card,
        state,
        isPlayer: isPlayer,
      );

      // Handle AI Spy Selection
      if (state.isSpyPicking && state.spySourceIsPlayer == false) {
        await Future.delayed(const Duration(milliseconds: 2000));
        if (mounted && state.isSpyPicking) {
          // AI selects a random card to peek at
          final randomIndex =
              DateTime.now().millisecond % state.spyOptions.length;
          onSpyCardSelected(state.spyOptions[randomIndex]);
        }
      }

      // Handle AI Destroyer Selection
      if (state.isDestroyPicking && state.destroySourceIsPlayer == false) {
        await Future.delayed(const Duration(milliseconds: 2000));
        if (mounted && state.isDestroyPicking) {
          final targetTable = state.playerTableCards;
          if (targetTable.isNotEmpty) {
            // AI targets the highest value card or just the last one
            final target = targetTable.last;
            onDestroyCardSelected(target);
          }
        }
      }

      // Handle AI Witch Selection
      if (state.isWitchPicking && state.witchSourceIsPlayer == false) {
        // AI thinking time is handled by the overlay's internal logic for UX,
        // but here we trigger the logic after a delay.
        await Future.delayed(
          const Duration(milliseconds: 2500),
        ); // Time for AI to "think"
        if (mounted && state.isWitchPicking) {
          final worstCard = await _aiService.selectWorstCard(
            state.witchOptions,
          );
          onWitchCardSelected(worstCard);
        }
      }
    }
  }

  Future<void> evaluateRound() async {
    while (state.isPaused) {
      await Future.delayed(GameConstants.pauseCheckDelay);
    }

    final hasJoker = state.playerTableCards.any((c) => c.isJoker);

    state = _evaluateRoundUseCase.execute(state);

    if (hasJoker) {
      state = state.copyWith(wildcardRankName: state.lastPlayerHandRank?.label);
    }

    state = state.copyWith(showRoundResult: true);

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

    // Check for Joker in player table to show notification
    final playerResult = _evaluator.evaluate(state.playerTableCards);
    final hasJoker = state.playerTableCards.any((c) => c.isJoker);
    if (hasJoker) {
      state = state.copyWith(
        showWildcardNotify: true,
        wildcardRankName: playerResult.rank.label,
      );
      // Auto-hide after 3 seconds
      Timer(const Duration(seconds: 3), () {
        if (mounted) state = state.copyWith(showWildcardNotify: false);
      });
    }

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
