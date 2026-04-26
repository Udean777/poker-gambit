import 'package:flutter/foundation.dart';

enum CardSuit { heart, diamond, club, spade, joker }

@immutable
class CardModel {
  final int value;
  final CardSuit suit;
  final bool isFaceUp;
  final bool isInvalid;

  const CardModel({
    required this.value,
    required this.suit,
    this.isFaceUp = false,
    this.isInvalid = false,
  });

  String get assetPath {
    if (suit == CardSuit.joker) {
      return 'assets/images/cards/joker@2x.png';
    }

    String folder;
    String suitChar;
    switch (suit) {
      case CardSuit.heart:
        folder = 'hearts';
        suitChar = 'H';
        break;
      case CardSuit.diamond:
        folder = 'diamond';
        suitChar = 'D';
        break;
      case CardSuit.club:
        folder = 'clubs';
        suitChar = 'C';
        break;
      case CardSuit.spade:
        folder = 'spades';
        suitChar = 'S';
        break;
      case CardSuit.joker:
        return 'assets/images/cards/joker@2x.png';
    }

    String valString;
    if (value == 1) {
      valString = "A";
    } else if (value == 10) {
      valString = "T";
    } else if (value == 11) {
      valString = "J";
    } else if (value == 12) {
      valString = "Q";
    } else if (value == 13) {
      valString = "K";
    } else {
      valString = value.toString();
    }

    return 'assets/images/cards/$folder/$valString$suitChar@2x.png';
  }

  CardModel copyWith({int? value, CardSuit? suit, bool? isFaceUp, bool? isInvalid}) {
    return CardModel(
      value: value ?? this.value,
      suit: suit ?? this.suit,
      isFaceUp: isFaceUp ?? this.isFaceUp,
      isInvalid: isInvalid ?? this.isInvalid,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardModel &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          suit == other.suit &&
          isFaceUp == other.isFaceUp &&
          isInvalid == other.isInvalid;

  @override
  int get hashCode => value.hashCode ^ suit.hashCode ^ isFaceUp.hashCode ^ isInvalid.hashCode;
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
