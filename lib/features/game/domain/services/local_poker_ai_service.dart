import 'package:poker_gambit/features/game/domain/models/card_model.dart';
import 'package:poker_gambit/features/game/domain/models/poker_hand.dart';
import 'package:poker_gambit/features/game/domain/services/i_poker_ai_service.dart';
import 'package:poker_gambit/features/game/domain/logic/i_poker_evaluator.dart';

class LocalPokerAiService implements IPokerAiService {
  final IPokerEvaluator _evaluator;

  LocalPokerAiService(this._evaluator);

  @override
  Future<Map<String, dynamic>> decideDiscard(
    List<CardModel> aiHand, {
    bool canWait = true,
    int timeLeft = 0,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final result = _evaluator.evaluate(aiHand);

    if (result.rank.power >= PokerHandRank.fullHouse.power) {
      return {
        'action': canWait ? 'wait' : 'pass',
        'indices': [],
        'message': "Tangan saya sudah sangat kuat!",
      };
    }

    final indicesToKeep = <int>[];
    for (int i = 0; i < aiHand.length; i++) {
      final card = aiHand[i];
      if (card.suit == CardSuit.joker) {
        indicesToKeep.add(i);
        continue;
      }

      final cardVal = card.value == 1 ? 14 : card.value;
      if (result.rank == PokerHandRank.highCard && indicesToKeep.isEmpty) {
        if (cardVal == result.kickers[0]) indicesToKeep.add(i);
      } else if (result.rank == PokerHandRank.onePair &&
          cardVal == result.kickers[0]) {
        indicesToKeep.add(i);
      } else if (result.rank == PokerHandRank.twoPair &&
          (cardVal == result.kickers[0] || cardVal == result.kickers[1])) {
        indicesToKeep.add(i);
      } else if (result.rank == PokerHandRank.threeOfAKind &&
          cardVal == result.kickers[0]) {
        indicesToKeep.add(i);
      } else if (result.rank == PokerHandRank.fourOfAKind &&
          cardVal == result.kickers[0]) {
        indicesToKeep.add(i);
      }
    }

    final finalDiscard = <int>[];
    for (int i = 0; i < aiHand.length; i++) {
      if (!indicesToKeep.contains(i)) finalDiscard.add(i);
    }

    final limitedDiscard = finalDiscard.take(3).toList();

    return {
      'action': limitedDiscard.isEmpty ? (canWait ? 'wait' : 'pass') : 'swap',
      'indices': limitedDiscard,
      'message': limitedDiscard.isEmpty ? "Cukup bagus." : "Menukar kartu...",
    };
  }

  @override
  Future<List<int>> decidePlayOrder(
    List<CardModel> aiHand,
    List<CardModel> playerCardsOnTable, {
    int timeLeft = 0,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final int handSize = aiHand.length;
    final int cardsAlreadyPlayed = 5 - handSize;

    // playOrder akan berisi urutan indeks (0 sampai handSize-1)
    final remainingIndices = List.generate(handSize, (i) => i);
    final List<int> orderedIndices = [];

    // Kita tentukan kartu untuk setiap slot meja yang tersisa (dari slot saat ini ke 4)
    for (int slotIndex = cardsAlreadyPlayed; slotIndex < 5; slotIndex++) {
      if (remainingIndices.isEmpty) break;

      int chosenIndexInRemaining = 0;

      if (slotIndex == 2) {
        // SLOT 2: x2 Power -> Pilih kartu tertinggi
        remainingIndices.sort((a, b) {
          if (aiHand[a].suit == CardSuit.joker) return -1;
          if (aiHand[b].suit == CardSuit.joker) return 1;
          return aiHand[b].value.compareTo(aiHand[a].value);
        });
        chosenIndexInRemaining = 0;
      } else if (slotIndex == 3) {
        // SLOT 3: Suit Lock -> Cari yang suit-nya sama dengan kartu di Slot 2
        // Kita perlu tahu kartu apa yang ada di Slot 2 (mungkin sudah di meja atau baru saja dipilih)
        if (cardsAlreadyPlayed > 2) {
          // Sudah ada di meja (aiTableCards tidak dikirim di param, kita asumsikan dari state atau fallback)
          // Karena kita tidak punya akses ke aiTableCards di sini, kita coba cari di kartu yang baru saja kita pilih
        }

        // Cari di kartu yang tersisa yang cocok dengan suit kartu sebelumnya (jika ada)
        int bestMatch = -1;
        // Sederhananya, jika kita baru saja memilih kartu untuk slot 2 di iterasi sebelumnya:
        if (orderedIndices.isNotEmpty && slotIndex == cardsAlreadyPlayed + 1) {
          final prevCard = aiHand[orderedIndices.last];
          for (int i = 0; i < remainingIndices.length; i++) {
            if (aiHand[remainingIndices[i]].suit == prevCard.suit ||
                aiHand[remainingIndices[i]].suit == CardSuit.joker) {
              bestMatch = i;
              break;
            }
          }
        }

        chosenIndexInRemaining = (bestMatch != -1) ? bestMatch : 0;
      } else {
        // Slot biasa: Urutkan dari kecil ke besar
        remainingIndices.sort(
          (a, b) => aiHand[a].value.compareTo(aiHand[b].value),
        );
        chosenIndexInRemaining = 0;
      }

      orderedIndices.add(remainingIndices.removeAt(chosenIndexInRemaining));
    }

    // Pastikan semua kartu masuk dalam list
    if (remainingIndices.isNotEmpty) {
      orderedIndices.addAll(remainingIndices);
    }

    return orderedIndices;
  }

  @override
  Future<CardModel> selectWorstCard(List<CardModel> options) async {
    // Berikan jeda seolah sedang berpikir
    await Future.delayed(const Duration(milliseconds: 1500));

    // Strategi Sabotase: Pilih kartu dengan nilai terendah yang bukan Joker
    final sorted = List<CardModel>.from(options)
      ..sort((a, b) {
        if (a.suit == CardSuit.joker) {
          return 1; // Joker adalah kartu bagus, jangan dipilih untuk sabotase
        }
        if (b.suit == CardSuit.joker) return -1;
        // Ace (1) biasanya kuat, tapi dalam urutan nilai mentah dia 1.
        // Namun kita cari yang paling tidak berguna.
        // Kartu 2-6 biasanya dianggap "sampah".
        return a.value.compareTo(b.value);
      });

    return sorted.first;
  }
}
