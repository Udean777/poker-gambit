import 'package:card_games/features/game/domain/logic/i_poker_evaluator.dart';
import 'package:card_games/features/game/domain/models/card_model.dart';
import 'package:card_games/features/game/domain/models/poker_hand.dart';

class PokerEvaluator implements IPokerEvaluator {
  @override
  HandResult evaluate(List<CardModel> hand) {
    if (hand.length < 5) {
      return HandResult(rank: PokerHandRank.highCard, kickers: []);
    }

    // Pre-process hand for modifiers
    final processedHand = List<CardModel>.from(hand);

    // Apply Slot 3 (index 2) "x2 Power" modifier
    if (!processedHand[2].isJoker && processedHand[2].value > 0) {
      final originalVal = processedHand[2].value;
      // We use 20 + original value to ensure it's higher than any Ace (14)
      // but still maintains relative order.
      processedHand[2] = processedHand[2].copyWith(value: 20 + originalVal);
    }

    // Filter out cards invalidated by Suit Lock (value 0)
    // We treat them as "blank" cards that don't contribute to combos
    final activeCards = processedHand.where((c) => c.value > 0).toList();

    // If we have less than 5 active cards, evaluation continues with fewer cards
    // which naturally results in a lower rank.
    return _evaluateWithJokers(activeCards);
  }

  HandResult _evaluateWithJokers(List<CardModel> hand) {
    final jokersCount = hand.where((c) => c.suit == CardSuit.joker).length;
    if (jokersCount == 0) {
      return _evaluateStandard(hand);
    }

    // Optimization: If we have Jokers, the best rank is at least what we have now.
    // For 5 cards, we can iterate through possible replacements.
    // To keep it fast, we only test ranks that are likely to be improved.

    final nonJokers = hand.where((c) => c.suit != CardSuit.joker).toList();

    // Special case: Five of a Kind (Only possible with Joker)
    Map<int, int> counts = {};
    for (var c in nonJokers) {
      int val = c.value == 1 ? 14 : c.value;
      counts[val] = (counts[val] ?? 0) + 1;
    }

    int maxFreq = 0;
    int bestVal = 0;
    counts.forEach((val, freq) {
      if (freq > maxFreq) {
        maxFreq = freq;
        bestVal = val;
      }
    });

    if (maxFreq + jokersCount >= 5) {
      return HandResult(
        rank: PokerHandRank.fiveOfAKind,
        kickers: [bestVal != 0 ? bestVal : 14],
      );
    }
    if (nonJokers.isEmpty && jokersCount >= 5) {
      return HandResult(rank: PokerHandRank.fiveOfAKind, kickers: [14]);
    }

    // For other ranks, we can use a recursive approach but limited to useful cards.
    return _findBestReplacement(hand);
  }

  HandResult _findBestReplacement(List<CardModel> hand) {
    int jokerIndex = hand.indexWhere((c) => c.suit == CardSuit.joker);
    if (jokerIndex == -1) {
      return _evaluateStandard(hand);
    }

    HandResult bestResult = HandResult(
      rank: PokerHandRank.highCard,
      kickers: [],
    );

    // Instead of all 52, just try suits of existing cards and values of existing cards
    // Plus a few edge cases for straights.
    Set<CardSuit> suitsToTry = hand
        .where((c) => c.suit != CardSuit.joker)
        .map((c) => c.suit)
        .toSet();
    if (suitsToTry.isEmpty) suitsToTry.add(CardSuit.heart);

    Set<int> valuesToTry = hand
        .where((c) => c.suit != CardSuit.joker)
        .map((c) => c.value)
        .toSet();
    if (valuesToTry.isEmpty) valuesToTry.add(1);

    // Add missing values for potential straights
    for (int i = 1; i <= 13; i++) {
      valuesToTry.add(i);
    }

    for (var suit in suitsToTry) {
      for (var val in valuesToTry) {
        final newHand = List<CardModel>.from(hand);
        newHand[jokerIndex] = CardModel(value: val, suit: suit);
        final result = _findBestReplacement(newHand);

        if (result.rank.power > bestResult.rank.power) {
          bestResult = result;
        } else if (result.rank.power == bestResult.rank.power) {
          // Compare kickers
          for (
            int i = 0;
            i < result.kickers.length && i < bestResult.kickers.length;
            i++
          ) {
            if (result.kickers[i] > bestResult.kickers[i]) {
              bestResult = result;
              break;
            } else if (result.kickers[i] < bestResult.kickers[i]) {
              break;
            }
          }
        }
      }
    }
    return bestResult;
  }

  HandResult _evaluateStandard(List<CardModel> hand) {
    final sortedCards = List<CardModel>.from(hand)
      ..sort((a, b) {
        int aVal = a.value == 1 ? 14 : a.value;
        int bVal = b.value == 1 ? 14 : b.value;
        return bVal.compareTo(aVal);
      });

    final values = sortedCards.map((c) => c.value == 1 ? 14 : c.value).toList();
    final suits = sortedCards.map((c) => c.suit).toSet();

    bool isFlush = suits.length == 1 && hand.length == 5;
    bool isStraight = hand.length == 5 && _checkStraight(values);

    Map<int, int> counts = {};
    for (var v in values) {
      counts[v] = (counts[v] ?? 0) + 1;
    }

    final sortedValuesByFreq = counts.keys.toList()
      ..sort((a, b) {
        int freqA = counts[a]!;
        int freqB = counts[b]!;
        if (freqA != freqB) return freqB.compareTo(freqA);
        return b.compareTo(a);
      });

    final frequencies = sortedValuesByFreq.map((v) => counts[v]!).toList();

    if (isFlush && isStraight && values.first == 14 && values.last == 10) {
      return HandResult(rank: PokerHandRank.royalFlush, kickers: values);
    }
    if (isFlush && isStraight) {
      if (values[0] == 14 && values[1] == 5) {
        return HandResult(rank: PokerHandRank.straightFlush, kickers: [5]);
      }
      return HandResult(
        rank: PokerHandRank.straightFlush,
        kickers: [values.first],
      );
    }
    if (frequencies[0] == 4) {
      return HandResult(
        rank: PokerHandRank.fourOfAKind,
        kickers: sortedValuesByFreq,
      );
    }
    if (frequencies[0] == 3 && frequencies[1] == 2) {
      return HandResult(
        rank: PokerHandRank.fullHouse,
        kickers: sortedValuesByFreq,
      );
    }
    if (isFlush) {
      return HandResult(rank: PokerHandRank.flush, kickers: values);
    }
    if (isStraight) {
      if (values[0] == 14 && values[1] == 5) {
        return HandResult(rank: PokerHandRank.straight, kickers: [5]);
      }
      return HandResult(rank: PokerHandRank.straight, kickers: [values.first]);
    }
    if (frequencies[0] == 3) {
      return HandResult(
        rank: PokerHandRank.threeOfAKind,
        kickers: sortedValuesByFreq,
      );
    }
    if (frequencies[0] == 2 && frequencies[1] == 2) {
      return HandResult(
        rank: PokerHandRank.twoPair,
        kickers: sortedValuesByFreq,
      );
    }
    if (frequencies[0] == 2) {
      return HandResult(
        rank: PokerHandRank.onePair,
        kickers: sortedValuesByFreq,
      );
    }

    return HandResult(rank: PokerHandRank.highCard, kickers: values);
  }

  bool _checkStraight(List<int> values) {
    // Standard straight check
    bool standard = true;
    for (int i = 0; i < values.length - 1; i++) {
      if (values[i] - values[i + 1] != 1) {
        standard = false;
        break;
      }
    }
    if (standard) return true;

    // Wheel straight (A-2-3-4-5)
    if (values[0] == 14 &&
        values[1] == 5 &&
        values[2] == 4 &&
        values[3] == 3 &&
        values[4] == 2) {
      return true;
    }
    return false;
  }
}
