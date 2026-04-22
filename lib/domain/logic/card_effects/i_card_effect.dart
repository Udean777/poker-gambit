import 'package:card_games/domain/models/game_state.dart';

abstract class ICardEffect {
  /// Unique identifier for the card that triggers this effect (e.g., 'J', 'Q', 'Joker').
  String get triggerLabel;

  /// Executes the effect and returns the updated GameState.
  Future<GameState> apply(GameState currentState, {required bool isPlayer});
}
