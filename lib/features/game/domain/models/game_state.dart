import 'package:poker_gambit/features/game/domain/models/card_model.dart';
import 'package:poker_gambit/features/game/domain/models/poker_hand.dart';
import 'package:poker_gambit/features/game/domain/models/round_result_info.dart';
import 'package:flutter/foundation.dart';

enum GamePhase { drawing, playing, showdown, gameOver }

@immutable
class GameState {
  final List<CardModel> deck;
  final List<CardModel> playerHand;
  final List<CardModel> aiHand;
  final List<CardModel> playerTableCards;
  final List<CardModel> aiTableCards;
  final List<int> selectedIndices;
  final int playerScore;
  final int aiScore;
  final bool isPlayerTurn;
  final bool isGameOver;
  final GamePhase phase;
  final String message;
  final bool aiCanSwap;
  final bool playerCanSwap;
  final List<int> aiSelectedIndices;
  final bool isAnimating;
  final int timeLeft;
  final bool isPaused;
  final int highScore;
  final bool? lastRoundPlayerWon;
  final PokerHandRank? lastPlayerHandRank;
  final List<CardModel> witchOptions;
  final bool isWitchPicking;
  final bool? witchSourceIsPlayer;
  final List<CardModel> spyOptions;
  final bool isSpyPicking;
  final bool? spySourceIsPlayer;
  final CardModel? spySelectedCard;
  final bool isDestroyPicking;
  final bool? destroySourceIsPlayer;
  final CardModel? cardBeingDestroyed;
  final bool showWildcardNotify;
  final String? wildcardRankName;
  final RoundResultInfo? lastRoundResult;
  final bool showRoundResult;

  const GameState({
    required this.deck,
    required this.playerHand,
    required this.aiHand,
    this.playerTableCards = const [],
    this.aiTableCards = const [],
    this.selectedIndices = const [],
    this.playerScore = 0,
    this.aiScore = 0,
    this.isPlayerTurn = true,
    this.isGameOver = false,
    this.phase = GamePhase.drawing,
    this.message = "Pilih kartu yang ingin ditukar!",
    this.aiCanSwap = true,
    this.playerCanSwap = true,
    this.aiSelectedIndices = const [],
    this.isAnimating = false,
    this.timeLeft = 0,
    this.isPaused = false,
    this.highScore = 0,
    this.lastRoundPlayerWon,
    this.lastPlayerHandRank,
    this.witchOptions = const [],
    this.isWitchPicking = false,
    this.witchSourceIsPlayer,
    this.spyOptions = const [],
    this.isSpyPicking = false,
    this.spySourceIsPlayer,
    this.spySelectedCard,
    this.isDestroyPicking = false,
    this.destroySourceIsPlayer,
    this.cardBeingDestroyed,
    this.showWildcardNotify = false,
    this.wildcardRankName,
    this.lastRoundResult,
    this.showRoundResult = false,
  });

  int get totalTableCards => playerTableCards.length + aiTableCards.length;
  bool get isShowdown => phase == GamePhase.showdown;

  GameState copyWith({
    List<CardModel>? deck,
    List<CardModel>? playerHand,
    List<CardModel>? aiHand,
    List<CardModel>? playerTableCards,
    List<CardModel>? aiTableCards,
    List<int>? selectedIndices,
    int? playerScore,
    int? aiScore,
    bool? isPlayerTurn,
    bool? isGameOver,
    GamePhase? phase,
    String? message,
    bool? aiCanSwap,
    bool? playerCanSwap,
    List<int>? aiSelectedIndices,
    bool? isAnimating,
    int? timeLeft,
    bool? isPaused,
    int? highScore,
    bool? lastRoundPlayerWon,
    PokerHandRank? lastPlayerHandRank,
    List<CardModel>? witchOptions,
    bool? isWitchPicking,
    bool? witchSourceIsPlayer,
    List<CardModel>? spyOptions,
    bool? isSpyPicking,
    bool? spySourceIsPlayer,
    CardModel? spySelectedCard,
    bool? isDestroyPicking,
    bool? destroySourceIsPlayer,
    CardModel? cardBeingDestroyed,
    bool? showWildcardNotify,
    String? wildcardRankName,
    RoundResultInfo? lastRoundResult,
    bool? showRoundResult,
  }) {
    return GameState(
      deck: deck ?? this.deck,
      playerHand: playerHand ?? this.playerHand,
      aiHand: aiHand ?? this.aiHand,
      playerTableCards: playerTableCards ?? this.playerTableCards,
      aiTableCards: aiTableCards ?? this.aiTableCards,
      selectedIndices: selectedIndices ?? this.selectedIndices,
      playerScore: playerScore ?? this.playerScore,
      aiScore: aiScore ?? this.aiScore,
      isPlayerTurn: isPlayerTurn ?? this.isPlayerTurn,
      isGameOver: isGameOver ?? this.isGameOver,
      phase: phase ?? this.phase,
      message: message ?? this.message,
      aiCanSwap: aiCanSwap ?? this.aiCanSwap,
      playerCanSwap: playerCanSwap ?? this.playerCanSwap,
      aiSelectedIndices: aiSelectedIndices ?? this.aiSelectedIndices,
      isAnimating: isAnimating ?? this.isAnimating,
      timeLeft: timeLeft ?? this.timeLeft,
      isPaused: isPaused ?? this.isPaused,
      highScore: highScore ?? this.highScore,
      lastRoundPlayerWon: lastRoundPlayerWon ?? this.lastRoundPlayerWon,
      lastPlayerHandRank: lastPlayerHandRank ?? this.lastPlayerHandRank,
      witchOptions: witchOptions ?? this.witchOptions,
      isWitchPicking: isWitchPicking ?? this.isWitchPicking,
      witchSourceIsPlayer: witchSourceIsPlayer ?? this.witchSourceIsPlayer,
      spyOptions: spyOptions ?? this.spyOptions,
      isSpyPicking: isSpyPicking ?? this.isSpyPicking,
      spySourceIsPlayer: spySourceIsPlayer ?? this.spySourceIsPlayer,
      spySelectedCard: spySelectedCard ?? this.spySelectedCard,
      isDestroyPicking: isDestroyPicking ?? this.isDestroyPicking,
      destroySourceIsPlayer:
          destroySourceIsPlayer ?? this.destroySourceIsPlayer,
      cardBeingDestroyed: cardBeingDestroyed ?? this.cardBeingDestroyed,
      showWildcardNotify: showWildcardNotify ?? this.showWildcardNotify,
      wildcardRankName: wildcardRankName ?? this.wildcardRankName,
      lastRoundResult: lastRoundResult ?? this.lastRoundResult,
      showRoundResult: showRoundResult ?? this.showRoundResult,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameState &&
          runtimeType == other.runtimeType &&
          listEquals(deck, other.deck) &&
          listEquals(playerHand, other.playerHand) &&
          listEquals(aiHand, other.aiHand) &&
          listEquals(playerTableCards, other.playerTableCards) &&
          listEquals(aiTableCards, other.aiTableCards) &&
          listEquals(selectedIndices, other.selectedIndices) &&
          playerScore == other.playerScore &&
          aiScore == other.aiScore &&
          isPlayerTurn == other.isPlayerTurn &&
          isGameOver == other.isGameOver &&
          phase == other.phase &&
          message == other.message &&
          aiCanSwap == other.aiCanSwap &&
          playerCanSwap == other.playerCanSwap &&
          listEquals(aiSelectedIndices, other.aiSelectedIndices) &&
          isAnimating == other.isAnimating &&
          timeLeft == other.timeLeft &&
          isPaused == other.isPaused &&
          highScore == other.highScore &&
          lastRoundPlayerWon == other.lastRoundPlayerWon &&
          lastPlayerHandRank == other.lastPlayerHandRank &&
          listEquals(witchOptions, other.witchOptions) &&
          isWitchPicking == other.isWitchPicking &&
          witchSourceIsPlayer == other.witchSourceIsPlayer &&
          listEquals(spyOptions, other.spyOptions) &&
          isSpyPicking == other.isSpyPicking &&
          spySourceIsPlayer == other.spySourceIsPlayer &&
          spySelectedCard == other.spySelectedCard &&
          isDestroyPicking == other.isDestroyPicking &&
          destroySourceIsPlayer == other.destroySourceIsPlayer &&
          cardBeingDestroyed == other.cardBeingDestroyed &&
          showWildcardNotify == other.showWildcardNotify &&
          wildcardRankName == other.wildcardRankName;

  @override
  int get hashCode =>
      deck.hashCode ^
      playerHand.hashCode ^
      aiHand.hashCode ^
      playerTableCards.hashCode ^
      aiTableCards.hashCode ^
      selectedIndices.hashCode ^
      playerScore.hashCode ^
      aiScore.hashCode ^
      isPlayerTurn.hashCode ^
      isGameOver.hashCode ^
      phase.hashCode ^
      message.hashCode ^
      aiCanSwap.hashCode ^
      playerCanSwap.hashCode ^
      aiSelectedIndices.hashCode ^
      isAnimating.hashCode ^
      timeLeft.hashCode ^
      isPaused.hashCode ^
      highScore.hashCode ^
      lastRoundPlayerWon.hashCode ^
      lastPlayerHandRank.hashCode ^
      witchOptions.hashCode ^
      isWitchPicking.hashCode ^
      witchSourceIsPlayer.hashCode ^
      spyOptions.hashCode ^
      isSpyPicking.hashCode ^
      spySourceIsPlayer.hashCode ^
      spySelectedCard.hashCode ^
      isDestroyPicking.hashCode ^
      destroySourceIsPlayer.hashCode ^
      cardBeingDestroyed.hashCode ^
      showWildcardNotify.hashCode ^
      wildcardRankName.hashCode;
}
