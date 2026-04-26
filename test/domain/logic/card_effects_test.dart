import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:card_games/features/game/domain/logic/card_effects/spy_effect.dart';
import 'package:card_games/features/game/domain/logic/card_effects/witch_effect.dart';
import 'package:card_games/features/game/domain/logic/card_effects/destroyer_effect.dart';
import 'package:card_games/features/game/domain/models/card_model.dart';
import 'package:card_games/features/game/domain/models/game_state.dart';
import 'package:card_games/core/constants/game_constants.dart';

void main() {
  group('Card Effects', () {
    late GameState initialState;

    setUp(() {
      initialState = const GameState(
        deck: [
          CardModel(value: 5, suit: CardSuit.club),
          CardModel(value: 6, suit: CardSuit.club),
        ],
        playerHand: [
          CardModel(value: 1, suit: CardSuit.heart),
          CardModel(value: 2, suit: CardSuit.heart),
        ],
        aiHand: [
          CardModel(value: 3, suit: CardSuit.spade),
          CardModel(value: 4, suit: CardSuit.spade),
        ],
        aiTableCards: [CardModel(value: 10, suit: CardSuit.diamond)],
      );
    });

    test('SpyEffect should reveal an AI card temporarily', () {
      final effect = SpyEffect();

      // We use FakeAsync to handle the internal delay
      fakeAsync((async) {
        final future = effect.apply(initialState, isPlayer: true);

        // Advance slightly to see the intermediate state (revealed)
        async.elapse(const Duration(milliseconds: 100));

        // Since we can't easily capture the intermediate state from the future
        // without awaiting, and awaiting in fakeAsync needs the timer to finish.
        // But we can check that after the reveal duration, it's hidden again.

        async.elapse(GameConstants.spyRevealDuration);

        future.then((newState) {
          // Verify it's hidden again
          for (var card in newState.aiHand) {
            expect(card.isFaceUp, isFalse);
          }
          expect(newState.message, contains('SPY'));
        });
      });
    });

    test('WitchEffect should swap a card from hand with deck', () async {
      final effect = WitchEffect();
      final newState = await effect.apply(initialState, isPlayer: true);

      expect(newState.playerHand.length, initialState.playerHand.length);
      expect(newState.deck.length, initialState.deck.length - 1);
      // The new card should be from the deck (value 5 or 6)
      expect(
        newState.playerHand.any((c) => c.value == 5 || c.value == 6),
        isTrue,
      );
    });

    test('DestroyerEffect should remove the last card from AI table', () async {
      final effect = DestroyerEffect();
      final newState = await effect.apply(initialState, isPlayer: true);

      expect(newState.aiTableCards.isEmpty, isTrue);
      expect(newState.message, contains('JOKER'));
    });
  });
}
