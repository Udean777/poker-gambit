import 'dart:async';

import 'package:card_games/core/constants/game_constants.dart';
import 'package:card_games/domain/logic/i_poker_evaluator.dart';
import 'package:card_games/domain/logic/poker_evaluator.dart';
import 'package:card_games/domain/models/card_model.dart';
import 'package:card_games/domain/models/game_state.dart';
import 'package:card_games/domain/services/deck_service.dart';
import 'package:card_games/domain/services/poker_ai_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Providers ───────────────────────────────────────────────────────────────

final pokerEvaluatorProvider = Provider<IPokerEvaluator>(
  (ref) => PokerEvaluator(),
);

final deckServiceProvider = Provider<DeckService>((ref) => DeckService());

final aiServiceProvider = Provider<PokerAiService>((ref) {
  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  return PokerAiService(apiKey: apiKey);
});

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier(
    evaluator: ref.watch(pokerEvaluatorProvider),
    aiService: ref.watch(aiServiceProvider),
    deckService: ref.watch(deckServiceProvider),
  );
});

// ─── GameNotifier ────────────────────────────────────────────────────────────

/// Central game state manager.
///
/// Orchestrates game flow by delegating:
/// - Deck operations → [DeckService]
/// - AI decisions → [PokerAiService]
/// - Hand evaluation → [IPokerEvaluator]
class GameNotifier extends StateNotifier<GameState> {
  final IPokerEvaluator _evaluator;
  final PokerAiService _aiService;
  final DeckService _deckService;
  Timer? _turnTimer;

  GameNotifier({
    required IPokerEvaluator evaluator,
    required PokerAiService aiService,
    required DeckService deckService,
  }) : _evaluator = evaluator,
       _aiService = aiService,
       _deckService = deckService,
       super(const GameState(deck: [], playerHand: [], aiHand: [])) {
    startNewGame();
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    super.dispose();
  }

  // ─── Animation State ───────────────────────────────────────────────

  /// Toggles card visibility during swap animations.
  void setIsAnimating(bool value) {
    state = state.copyWith(isAnimating: value);
  }

  // ─── Timer Logic ───────────────────────────────────────────────────

  void _startTimer(int seconds, VoidCallback onTimeout) {
    _turnTimer?.cancel();
    state = state.copyWith(timeLeft: seconds);
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (state.isPaused) return;

      if (state.timeLeft > 1) {
        state = state.copyWith(timeLeft: state.timeLeft - 1);
      } else {
        timer.cancel();
        state = state.copyWith(timeLeft: 0);
        onTimeout();
      }
    });
  }

  void _cancelTimer() {
    _turnTimer?.cancel();
    _turnTimer = null;
    if (mounted) state = state.copyWith(timeLeft: 0);
  }

  void togglePause() {
    state = state.copyWith(isPaused: !state.isPaused);
  }

  void onCounter() {
    if (state.qteActive) {
      state = state.copyWith(
        qteActive: false,
        message: 'COUNTER SUCCESSFUL! Skill AI digagalkan!',
      );
    }
  }

  /// Starts or resumes the timer for the current phase.
  void startTurnTimer() {
    if (state.phase == GamePhase.drawing) {
      _startTimer(GameConstants.drawPhaseSeconds, () {
        if (mounted) executeDraw();
      });
    } else if (state.phase == GamePhase.playing && state.isPlayerTurn) {
      _startTimer(GameConstants.playPhaseSeconds, _onPlayTimeout);
    }
  }

  // ─── Game Setup ────────────────────────────────────────────────────

  /// Resets the game with a fresh shuffled deck and dealt hands.
  void startNewGame() {
    final deck = _deckService.createShuffledDeck();
    final deal = _deckService.dealInitialHands(deck);

    state = GameState(
      deck: deal.remainingDeck,
      playerHand: deal.playerHand,
      aiHand: deal.aiHand,
      phase: GamePhase.drawing,
      message:
          'Fase Tukar: Pilih kartu yang ingin diganti (Maks ${GameConstants.maxSwapCards}).',
    );
  }

  // ─── Player Card Selection ─────────────────────────────────────────

  /// Toggles selection of a card at [index] for swapping.
  void toggleCardSelection(int index) {
    if (!_isSwapPhase || !state.playerCanSwap) return;

    final selection = List<int>.from(state.selectedIndices);

    if (selection.contains(index)) {
      selection.remove(index);
      state = state.copyWith(
        selectedIndices: selection,
        message:
            'Pilih hingga ${GameConstants.maxSwapCards} kartu untuk ditukar.',
      );
      return;
    }

    if (selection.length >= GameConstants.maxSwapCards) {
      state = state.copyWith(
        message:
            'Maksimal ${GameConstants.maxSwapCards} kartu yang boleh ditukar!',
      );
      return;
    }

    selection.add(index);
    state = state.copyWith(
      selectedIndices: selection,
      message: '${selection.length} kartu dipilih.',
    );
  }

  // ─── Player Swap ──────────────────────────────────────────────────

  /// Step 1: Remove selected cards from hand (called after discard animation).
  void discardSelectedCards() {
    if (!state.playerCanSwap) return;

    state = state.copyWith(
      playerHand: _removeAtIndices(state.playerHand, state.selectedIndices),
    );
  }

  /// Step 2: Draw replacement cards and add to hand end.
  void drawNewCards() {
    final count = state.selectedIndices.length;
    final hasSwapped = count > 0;
    final draw = _deckService.drawCards(state.deck, count, faceUp: true);
    final newHand = [...state.playerHand, ...draw.drawnCards];

    if (state.phase == GamePhase.drawing) {
      state = state.copyWith(
        deck: draw.remainingDeck,
        playerHand: newHand,
        selectedIndices: const [],
        phase: GamePhase.playing,
        isPlayerTurn: false,
        playerCanSwap: !hasSwapped,
        message: hasSwapped
            ? 'Berhasil ditukar! AI sedang menukar kartu...'
            : 'Melewati tukar kartu. AI sedang menukar...',
      );
      Future.delayed(GameConstants.aiSwapDelay, _executeAiSwapPhase);
    } else {
      state = state.copyWith(
        deck: draw.remainingDeck,
        playerHand: newHand,
        selectedIndices: const [],
        playerCanSwap: !hasSwapped,
        message: hasSwapped ? 'Kartu berhasil ditukar!' : null,
      );
    }
  }

  /// Combined discard + draw for simple triggers (e.g. skip button).
  void executeDraw() {
    _cancelTimer();
    if (!_isSwapPhase || !state.playerCanSwap) return;

    if (state.selectedIndices.isEmpty) {
      drawNewCards();
      return;
    }

    discardSelectedCards();
    drawNewCards();
  }

  // ─── AI Swap ──────────────────────────────────────────────────────

  /// Executes the AI's initial swap decision.
  Future<void> _executeAiSwapPhase() async {
    final decision = await _aiService.decideDiscard(
      state.aiHand,
      canWait: true,
    );

    final action = decision['action'] as String;
    final indices = List<int>.from(decision['indices'] as List);
    final message = decision['message'] as String;

    if (action == 'swap' && indices.isNotEmpty) {
      // Signal AI selection — GameScreen listens and triggers animation
      state = state.copyWith(
        aiSelectedIndices: indices,
        message: 'AI: $message',
      );
    } else {
      state = state.copyWith(
        aiCanSwap: action == 'wait',
        message: action == 'wait'
            ? 'AI: $message (Akan tukar nanti)'
            : 'AI: $message',
        phase: GamePhase.playing,
        isPlayerTurn: true,
      );
      _startTimer(GameConstants.playPhaseSeconds, _onPlayTimeout);
    }
  }

  /// Called by GameScreen after AI discard animation finishes.
  void aiDiscardSelectedCards() {
    state = state.copyWith(
      aiHand: _removeAtIndices(state.aiHand, state.aiSelectedIndices),
    );
  }

  /// Called by GameScreen after AI draw animation finishes.
  void aiDrawNewCards() {
    final draw = _deckService.drawCards(
      state.deck,
      state.aiSelectedIndices.length,
    );

    state = state.copyWith(
      deck: draw.remainingDeck,
      aiHand: [...state.aiHand, ...draw.drawnCards],
      aiCanSwap: false,
      aiSelectedIndices: const [],
      phase: GamePhase.playing,
      isPlayerTurn: true,
    );
    _startTimer(GameConstants.playPhaseSeconds, _onPlayTimeout);
  }

  void _onPlayTimeout() {
    if (state.phase == GamePhase.playing &&
        state.isPlayerTurn &&
        state.playerHand.isNotEmpty) {
      playCard(state.playerHand.first);
    }
  }

  // ─── Card Playing ─────────────────────────────────────────────────

  /// Plays a card from the player's hand to the table.
  void playCard(CardModel card) async {
    if (state.phase != GamePhase.playing || !state.isPlayerTurn) return;
    _cancelTimer();

    // Blind Placement: Kartu ke-2, 3, 4 ditaruh tertutup
    final isHidden =
        state.playerTableCards.length == 1 ||
        state.playerTableCards.length == 3;
    final playedCard = card.copyWith(isFaceUp: !isHidden);

    final newState = state.copyWith(
      playerHand: List.from(state.playerHand)..remove(card),
      playerTableCards: [...state.playerTableCards, playedCard],
      isPlayerTurn: false,
      message: 'AI sedang menganalisis meja...',
    );

    state = newState;
    await _applyCardEffect(playedCard, true);

    if (state.aiHand.isEmpty && state.playerHand.isEmpty) {
      _transitionToShowdown(state.deck, state.aiHand, state.aiTableCards);
    } else if (state.aiHand.isEmpty) {
      state = state.copyWith(
        isPlayerTurn: true,
        message: 'AI kehabisan kartu! Silakan main lagi.',
      );
      _startTimer(GameConstants.playPhaseSeconds, _onPlayTimeout);
    } else {
      Future.delayed(GameConstants.aiPlayDelay, _executeAiTurn);
    }
  }

  /// AI plays one card, optionally swapping first if allowed.
  Future<void> _executeAiTurn() async {
    while (state.isPaused) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
    if (state.aiHand.isEmpty) return;

    var currentDeck = List<CardModel>.from(state.deck);
    var currentAiHand = List<CardModel>.from(state.aiHand);

    // Mid-game swap opportunity
    if (state.aiCanSwap) {
      final result = await _tryAiMidGameSwap(currentDeck, currentAiHand);
      currentDeck = result.deck;
      currentAiHand = result.hand;
    }

    // Choose which card to play
    final chosenIndex = await _getAiPlayChoice(currentAiHand);
    final chosenCard = currentAiHand.removeAt(chosenIndex);

    // Blind Placement: Kartu ke-2, 3, 4 AI ditaruh tertutup
    final isHidden =
        state.aiTableCards.length == 1 || state.aiTableCards.length == 3;
    final playedCard = chosenCard.copyWith(isFaceUp: !isHidden);

    final newAiTable = [...state.aiTableCards, playedCard];

    state = state.copyWith(
      deck: currentDeck,
      aiHand: currentAiHand,
      aiTableCards: newAiTable,
    );

    _applyCardEffect(playedCard, false);

    // Update local vars after potential effect changes (like Destroyer)
    final finalAiTable = state.aiTableCards;
    final finalAiHand = state.aiHand;
    final finalDeck = state.deck;

    final isLastRound = finalAiHand.isEmpty && state.playerHand.isEmpty;

    if (isLastRound) {
      _transitionToShowdown(finalDeck, finalAiHand, finalAiTable);
    } else if (state.playerHand.isEmpty) {
      // Player out of cards, AI plays again
      state = state.copyWith(
        deck: finalDeck,
        aiHand: finalAiHand,
        aiTableCards: finalAiTable,
        isPlayerTurn: false,
        message: 'Anda kehabisan kartu! AI lanjut bermain...',
      );
      Future.delayed(GameConstants.aiPlayDelay, _executeAiTurn);
    } else {
      state = state.copyWith(
        deck: finalDeck,
        aiHand: finalAiHand,
        aiTableCards: finalAiTable,
        isPlayerTurn: true,
        phase: GamePhase.playing,
        message: 'Giliran Anda! Taruh kartu ke-${finalAiTable.length + 1}.',
      );
      _startTimer(GameConstants.playPhaseSeconds, _onPlayTimeout);
    }
  }

  // ─── Action Card Effects ──────────────────────────────────────────

  Future<void> _applyCardEffect(CardModel card, bool isPlayer) async {
    final cardLabel = card.valueLabel;
    final isSkillCard = cardLabel == 'J' || cardLabel == 'Q' || card.isJoker;

    if (!isPlayer && isSkillCard) {
      state = state.copyWith(
        qteActive: true,
        message: 'AI MENGGUNAKAN SKILL! CEPAT COUNTER!',
      );
      // Wait for QTE window (1.5s)
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!state.qteActive) {
        // Counter was successful
        _checkModifierSlots();
        return;
      }

      state = state.copyWith(qteActive: false);
    }

    // 1. Jack: The Spy (Peek 1 random card)
    if (cardLabel == 'J') {
      final targetHand = isPlayer ? state.aiHand : state.playerHand;
      if (targetHand.isNotEmpty) {
        final randomIndex = DateTime.now().millisecond % targetHand.length;
        final updatedHand = List<CardModel>.from(targetHand);
        updatedHand[randomIndex] = updatedHand[randomIndex].copyWith(
          isFaceUp: true,
        );

        state = isPlayer
            ? state.copyWith(
                aiHand: updatedHand,
                message: 'SPY: Mengintip kartu lawan!',
              )
            : state.copyWith(
                playerHand: updatedHand,
                message: 'AI SPY: Kartu Anda diintip!',
              );

        await Future.delayed(const Duration(seconds: 2));

        final resetHand = List<CardModel>.from(updatedHand);
        resetHand[randomIndex] = resetHand[randomIndex].copyWith(
          isFaceUp: false,
        );
        state = isPlayer
            ? state.copyWith(aiHand: resetHand)
            : state.copyWith(playerHand: resetHand);
      }
    }
    // 2. Queen: The Witch (Replace 1 card in hand)
    else if (cardLabel == 'Q') {
      final targetHand = isPlayer ? state.playerHand : state.aiHand;
      if (targetHand.isNotEmpty && state.deck.isNotEmpty) {
        final newDeck = List<CardModel>.from(state.deck);
        final newHand = List<CardModel>.from(targetHand);
        final randomIndex = DateTime.now().millisecond % targetHand.length;

        newHand[randomIndex] = newDeck.removeAt(0).copyWith(isFaceUp: isPlayer);

        state = isPlayer
            ? state.copyWith(
                playerHand: newHand,
                deck: newDeck,
                message: 'WITCH: Menukar kartu tangan!',
              )
            : state.copyWith(
                aiHand: newHand,
                deck: newDeck,
                message: 'AI WITCH: AI menukar kartu!',
              );
      }
    }
    // 3. Joker: The Destroyer (Remove opponent's last table card)
    else if (card.isJoker) {
      final targetTable = isPlayer
          ? state.aiTableCards
          : state.playerTableCards;
      if (targetTable.isNotEmpty) {
        final newTable = List<CardModel>.from(targetTable)..removeLast();
        state = isPlayer
            ? state.copyWith(
                aiTableCards: newTable,
                message: 'JOKER: Menghancurkan kartu AI!',
              )
            : state.copyWith(
                playerTableCards: newTable,
                message: 'AI JOKER: Kartu Anda dihancurkan!',
              );
      }
    }

    _checkModifierSlots();
  }

  void _checkModifierSlots() {
    // Slot 4: Suit Lock (must match Slot 3)
    // Slot 3 index = 2, Slot 4 index = 3

    void applySuitLock(List<CardModel> table, bool isPlayer) {
      if (table.length >= 4) {
        final card3 = table[2];
        final card4 = table[3];
        if (card3.suit != card4.suit && !card4.isJoker && !card3.isJoker) {
          // If suit lock fails, nullify card 4's value (mark it as invalid)
          // We'll treat it as a special "null" card in evaluation
          final invalidatedTable = List<CardModel>.from(table);
          invalidatedTable[3] = card4.copyWith(
            value: 0,
          ); // Value 0 = invalid in evaluation
          state = isPlayer
              ? state.copyWith(
                  playerTableCards: invalidatedTable,
                  message: 'SUIT LOCK FAILED!',
                )
              : state.copyWith(
                  aiTableCards: invalidatedTable,
                  message: 'AI SUIT LOCK FAILED!',
                );
        }
      }
    }

    applySuitLock(state.playerTableCards, true);
    applySuitLock(state.aiTableCards, false);
  }

  // ─── Evaluation ───────────────────────────────────────────────────

  /// Evaluates both hands and updates scores.
  Future<void> evaluateRound() async {
    while (state.isPaused) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
    final playerResult = _evaluator.evaluate(state.playerTableCards);
    final aiResult = _evaluator.evaluate(state.aiTableCards);

    int newPlayerScore = state.playerScore;
    int newAiScore = state.aiScore;
    final String resultMessage;

    if (playerResult.rank.power > aiResult.rank.power) {
      newPlayerScore++;
      resultMessage = 'MENANG! ${playerResult.rank.label}';
    } else if (aiResult.rank.power > playerResult.rank.power) {
      newAiScore++;
      resultMessage = 'KALAH! AI punya ${aiResult.rank.label}';
    } else {
      resultMessage = 'SERI! Keduanya ${playerResult.rank.label}';
    }

    state = state.copyWith(
      playerScore: newPlayerScore,
      aiScore: newAiScore,
      message: resultMessage,
    );

    Future.delayed(GameConstants.nextRoundDelay, _startNextRound);
  }

  // ─── Private Helpers ──────────────────────────────────────────────

  bool get _isSwapPhase =>
      state.phase == GamePhase.drawing || state.phase == GamePhase.playing;

  /// Removes cards at [indices] from [cards], handling reverse-order removal.
  List<CardModel> _removeAtIndices(List<CardModel> cards, List<int> indices) {
    final result = List<CardModel>.from(cards);
    final sorted = List<int>.from(indices)..sort((a, b) => b.compareTo(a));
    for (final index in sorted) {
      result.removeAt(index);
    }
    return result;
  }

  /// Attempts a mid-game swap for the AI. Returns updated deck and hand.
  Future<({List<CardModel> deck, List<CardModel> hand})> _tryAiMidGameSwap(
    List<CardModel> deck,
    List<CardModel> hand,
  ) async {
    final decision = await _aiService.decideDiscard(hand, canWait: false);

    if (decision['action'] == 'swap') {
      final indices = List<int>.from(decision['indices'] as List);
      if (indices.isNotEmpty) {
        final newDeck = List<CardModel>.from(deck);
        final newHand = List<CardModel>.from(hand);

        for (final index in indices) {
          if (newDeck.isNotEmpty && index < newHand.length) {
            newHand[index] = newDeck.removeAt(0);
          }
        }

        state = state.copyWith(
          deck: newDeck,
          aiHand: newHand,
          aiCanSwap: false,
          message: 'AI menukar kartu sekarang: ${decision['message']}',
        );

        await Future.delayed(GameConstants.aiSwapDelay);
        return (deck: newDeck, hand: newHand);
      }
    }

    state = state.copyWith(aiCanSwap: false);
    return (deck: deck, hand: hand);
  }

  /// Gets the AI's chosen card index to play.
  Future<int> _getAiPlayChoice(List<CardModel> aiHand) async {
    final playIndices = await _aiService.decidePlayOrder(
      aiHand,
      state.playerTableCards,
    );

    if (playIndices.isNotEmpty && playIndices.first < aiHand.length) {
      return playIndices.first;
    }
    return 0;
  }

  /// Reveals AI cards and transitions to showdown phase.
  void _transitionToShowdown(
    List<CardModel> deck,
    List<CardModel> aiHand,
    List<CardModel> aiTable,
  ) {
    // Reveal all table cards for showdown
    final revealedPlayerTable = state.playerTableCards
        .map((c) => c.copyWith(isFaceUp: true))
        .toList();
    final revealedAiTable = aiTable
        .map((c) => c.copyWith(isFaceUp: true))
        .toList();

    state = state.copyWith(
      deck: deck,
      aiHand: aiHand,
      playerTableCards: revealedPlayerTable,
      aiTableCards: revealedAiTable,
      isPlayerTurn: false,
      phase: GamePhase.showdown,
      message: 'Showdown! Menghitung hasil...',
    );

    Future.delayed(GameConstants.showdownDelay, evaluateRound);
  }

  /// Deals a new round or ends the game if deck is too small.
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
      message: 'Ronde Baru: Pilih kartu untuk ditukar.',
    );

    _startTimer(GameConstants.drawPhaseSeconds, () {
      if (mounted) executeDraw();
    });
  }
}
