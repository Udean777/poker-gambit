import 'package:poker_gambit/features/game/domain/models/card_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImagePrecacheService {
  ImagePrecacheService._();

  static Future<void> precacheAllCards(BuildContext context) async {
    final suits = [
      CardSuit.club,
      CardSuit.heart,
      CardSuit.diamond,
      CardSuit.spade,
    ];
    final List<Future<void>> precacheTasks = [];

    // Precache normal cards
    for (final suit in suits) {
      for (int value = 1; value <= 13; value++) {
        final card = CardModel(value: value, suit: suit);
        precacheTasks.add(
          precacheImage(CachedNetworkImageProvider(card.remoteUrl), context),
        );
      }
    }

    // Precache Jokers
    precacheTasks.add(
      precacheImage(
        const CachedNetworkImageProvider(
          'https://pub-6fcbc4e0d115436c8de442a8ef77f828.r2.dev/joker@2x.png',
        ),
        context,
      ),
    );

    // Run all precaching in background
    Future.wait(precacheTasks).catchError((e) {
      debugPrint('Error precaching images: $e');
      return [];
    });
  }
}
