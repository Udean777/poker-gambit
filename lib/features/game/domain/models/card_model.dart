import 'package:poker_gambit/core/config/app_config.dart';
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

  String get _folder {
    switch (suit) {
      case CardSuit.heart:
        return 'hearts';
      case CardSuit.diamond:
        return 'diamond';
      case CardSuit.club:
        return 'clubs';
      case CardSuit.spade:
        return 'spades';
      case CardSuit.joker:
        return '';
    }
  }

  String get _suitChar {
    switch (suit) {
      case CardSuit.heart:
        return 'H';
      case CardSuit.diamond:
        return 'D';
      case CardSuit.club:
        return 'C';
      case CardSuit.spade:
        return 'S';
      case CardSuit.joker:
        return '';
    }
  }

  String get _valString {
    if (value == 1) return "A";
    if (value == 10) return "T";
    if (value == 11) return "J";
    if (value == 12) return "Q";
    if (value == 13) return "K";
    return value.toString();
  }

  String get assetPath {
    if (suit == CardSuit.joker) {
      return 'assets/images/cards/joker@2x.png';
    }
    return 'assets/images/cards/$_folder/$_valString$_suitChar@2x.png';
  }

  String get remoteUrl {
    if (suit == CardSuit.joker) {
      return '${AppConfig.assetBaseUrl}/joker@2x.png';
    }
    return '${AppConfig.assetBaseUrl}/$_folder/$_valString$_suitChar@2x.png';
  }

  CardModel copyWith({
    int? value,
    CardSuit? suit,
    bool? isFaceUp,
    bool? isInvalid,
  }) {
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
  int get hashCode =>
      value.hashCode ^ suit.hashCode ^ isFaceUp.hashCode ^ isInvalid.hashCode;
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
