import 'dart:convert';
import 'package:card_games/domain/models/card_model.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class PokerAiService {
  final String apiKey;
  late final GenerativeModel _model;

  PokerAiService({required this.apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
  }

  Future<Map<String, dynamic>> decideDiscard(
    List<CardModel> aiHand, {
    bool canWait = true,
  }) async {
    final handString = aiHand
        .asMap()
        .entries
        .map((e) => "[${e.key}] ${e.value.valueLabel} of ${e.value.suit.name}")
        .join(", ");

    final prompt =
        """
You are a HIGHLY AGGRESSIVE Poker AI playing 5-Card Draw with a Wild Joker.

RULES:
- Joker is a Wild Card that can become ANY card. NEVER discard a Joker.
- Hand ranks from lowest to highest: High Card, One Pair, Two Pair, Three of a Kind, Straight, Flush, Full House, Four of a Kind, Straight Flush, Royal Flush, Five of a Kind.

YOUR CURRENT HAND (index: card): $handString

STRATEGY — Be very aggressive. Swap cards to improve your hand unless it is already strong:
- If you have High Card or One Pair → ALWAYS swap the worst ${canWait ? "2-3" : "1-3"} cards.
- If you have Two Pair → swap the 5th unmatched card (1 card).
- If you have Three of a Kind → swap the 2 non-matching cards.
- If you have 4 cards toward a Straight or Flush → swap the 1 missing card.
- If you have Full House, Four of a Kind, or better → ${canWait ? "'wait' or 'pass'" : "'pass'"}, hand is already excellent.
- NEVER keep a hand weaker than Two Pair if you can improve it.

${canWait ? "You MAY choose 'wait' ONLY if your hand is already Full House or better." : "If hand is strong enough, choose 'pass'."}

Respond with ONLY this JSON (no markdown, no explanation):
{
  "action": "${canWait ? "swap\" | \"wait" : "swap\" | \"pass"}",
  "indices": [],
  "message": "Alasan singkat dalam Bahasa Indonesia (maks 8 kata)"
}

IMPORTANT: 'indices' must be an array of card indices (0-4) to discard. Maximum 3 indices. Empty array [] if action is not 'swap'.
""";

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final text = response.text ?? "{}";
      final jsonResponse = jsonDecode(text);

      if (jsonResponse is Map) {
        final action =
            jsonResponse['action']?.toString() ?? (canWait ? 'wait' : 'pass');
        final indices =
            (jsonResponse['indices'] as List?)
                ?.map((e) => int.tryParse(e.toString()) ?? -1)
                .where((i) => i >= 0 && i < 5)
                .take(3)
                .toList() ??
            [];
        final message = jsonResponse['message']?.toString() ?? "";

        return {'action': action, 'indices': indices, 'message': message};
      }
    } catch (e) {
      debugPrint("Gemini Error (decideDiscard): $e");
    }

    // Fallback: jika API gagal, AI akan swap kartu pertama (agresif)
    return {
      'action': 'swap',
      'indices': [0, 1],
      'message': "Mencoba peruntungan dengan kartu baru.",
    };
  }

  Future<List<int>> decidePlayOrder(
    List<CardModel> aiHand,
    List<CardModel> playerCardsOnTable,
  ) async {
    final handString = aiHand
        .asMap()
        .entries
        .map((e) => "[${e.key}] ${e.value.valueLabel} of ${e.value.suit.name}")
        .join(", ");

    final tableString = playerCardsOnTable.isEmpty
        ? "none yet"
        : playerCardsOnTable
              .asMap()
              .entries
              .map(
                (e) => e.value.isFaceUp
                    ? "(${e.key + 1}) ${e.value.valueLabel} of ${e.value.suit.name}"
                    : "(${e.key + 1}) [HIDDEN CARD]",
              )
              .join(", ");

    final cardsLeft = aiHand.length;
    final cardsPlayed = 5 - cardsLeft;

    final prompt =
        """
You are a STRATEGIC Poker AI playing 5-Card Draw. You must decide the order to play your cards one by one to the table to win.

YOUR REMAINING HAND (index: card): $handString
PLAYER'S CARDS ON TABLE so far: $tableString
Cards you have played: $cardsPlayed / 5. Cards left to play: $cardsLeft.

STRATEGY:
- Some of the opponent's cards on the table are [HIDDEN CARD]. You cannot see them. You must use deduction and bluffing based on their visible cards.
- Analyze what hand the opponent might be building based on their visible table cards.
- Play cards in an order that MAXIMIZES your final 5-card hand rank.
- If opponent seems to be building a Flush with their visible cards → prioritize playing non-matching suit cards early to keep your best combo.
- Play your least valuable cards first if you want to bluff, or your most strategic cards first to lock in combos.
- A Joker is your most powerful card — consider when best to reveal it.

Return ONLY a JSON array of the indices from your hand, in the order you want to play them (one per turn).
Example: [2, 0, 3, 1, 4]
""";

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final text = response.text ?? "[]";
      final jsonResponse = jsonDecode(text);
      if (jsonResponse is List) {
        final indices = jsonResponse
            .map((e) => int.tryParse(e.toString()) ?? -1)
            .where((i) => i >= 0 && i < aiHand.length)
            .toList();
        if (indices.isNotEmpty) return indices;
      }
    } catch (e) {
      debugPrint("Gemini Error (decidePlayOrder): $e");
    }

    // Fallback: urutan terbalik (mainkan kartu lemah dulu)
    return List.generate(aiHand.length, (i) => aiHand.length - 1 - i);
  }
}
