import 'package:card_games/features/game/domain/logic/card_effects/destroyer_effect.dart';
import 'package:card_games/features/game/domain/logic/card_effects/i_card_effect.dart';
import 'package:card_games/features/game/domain/logic/card_effects/spy_effect.dart';
import 'package:card_games/features/game/domain/logic/card_effects/witch_effect.dart';
import 'package:card_games/features/game/domain/models/card_model.dart';
import 'package:card_games/features/game/domain/models/game_state.dart';

class CardEffectHandler {
  final Map<String, ICardEffect> _effects = {};

  CardEffectHandler() {
    _registerEffect(SpyEffect());
    _registerEffect(WitchEffect());
    _registerEffect(DestroyerEffect());
  }

  void _registerEffect(ICardEffect effect) {
    _effects[effect.triggerLabel] = effect;
  }

  bool hasEffect(CardModel card) {
    if (card.isJoker) return _effects.containsKey('Joker');
    return _effects.containsKey(card.valueLabel);
  }

  Future<GameState> applyEffect(
    CardModel card,
    GameState currentState, {
    required bool isPlayer,
  }) async {
    final label = card.isJoker ? 'Joker' : card.valueLabel;
    final effect = _effects[label];

    if (effect == null) return currentState;
    return await effect.apply(currentState, isPlayer: isPlayer);
  }
}
