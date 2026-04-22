import 'package:flutter/foundation.dart';

enum CardSuit { heart, diamond, club, spade, joker }

@immutable
class CardModel {
  final int value;
  final CardSuit suit;
  final bool isFaceUp;

  const CardModel({
    required this.value,
    required this.suit,
    this.isFaceUp = false,
  });

  String get assetPath {
    if (suit == CardSuit.joker) {
      return 'assets/images/cards/joker_${value == 1 ? "red" : "black"}.svg';
    }
    return 'assets/images/cards/${suit.name}_$value.svg';
  }

  CardModel copyWith({int? value, CardSuit? suit, bool? isFaceUp}) {
    return CardModel(
      value: value ?? this.value,
      suit: suit ?? this.suit,
      isFaceUp: isFaceUp ?? this.isFaceUp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardModel &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          suit == other.suit &&
          isFaceUp == other.isFaceUp;

  @override
  int get hashCode => value.hashCode ^ suit.hashCode ^ isFaceUp.hashCode;
}

extension CardDisplay on CardModel {
  String get suitIcon {
    switch (suit) {
      case CardSuit.heart:
        return "❤️";
      case CardSuit.diamond:
        return "💎";
      case CardSuit.club:
        return "♣️";
      case CardSuit.spade:
        return "♠️";
      case CardSuit.joker:
        return "🃏";
    }
  }

  bool get isJoker => suit == CardSuit.joker;

  String get valueLabel {
    if (isJoker) return "JK";
    if (value == 1) return "A";
    if (value == 11) return "J";
    if (value == 12) return "Q";
    if (value == 13) return "K";
    return value.toString();
  }
}
