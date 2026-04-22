import 'package:card_games/domain/models/card_model.dart';
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
  final bool qteActive;
  final int highScore;

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
    this.qteActive = false,
    this.highScore = 0,
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
    bool? qteActive,
    int? highScore,
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
      qteActive: qteActive ?? this.qteActive,
      highScore: highScore ?? this.highScore,
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
          qteActive == other.qteActive &&
          highScore == other.highScore;

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
      qteActive.hashCode ^
      highScore.hashCode;
}
