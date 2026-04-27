import 'package:flutter/material.dart';
import 'package:poker_gambit/features/game/domain/models/card_model.dart';

class CardCombo {
  final String name;
  final String rank;
  final String description;
  final String counterTip;
  final List<CardModel> cards;
  final Color color;

  const CardCombo({
    required this.name,
    required this.rank,
    required this.description,
    required this.counterTip,
    required this.cards,
    required this.color,
  });
}

const List<CardCombo> cardCombosData = [
  CardCombo(
    name: "ROYAL FLUSH",
    rank: "Rank 1 (Ultimate)",
    description: "Kombinasi tertinggi: A, K, Q, J, 10 dengan suit yang sama.",
    counterTip:
        "Sangat jarang. Tidak bisa di-counter secara nilai, tapi bisa digagalkan dengan WITCH (Q) sebelum showdown.",
    cards: [
      CardModel(suit: CardSuit.spade, value: 1), // A
      CardModel(suit: CardSuit.spade, value: 13), // K
      CardModel(suit: CardSuit.spade, value: 12), // Q
    ],
    color: Colors.amber,
  ),
  CardCombo(
    name: "STRAIGHT FLUSH",
    rank: "Rank 2",
    description: "5 kartu berurutan dengan suit yang sama.",
    counterTip:
        "Gunakan DESTROYER (Joker) untuk menghancurkan salah satu kartu urutan lawan sebelum mereka komplit.",
    cards: [
      CardModel(suit: CardSuit.heart, value: 9),
      CardModel(suit: CardSuit.heart, value: 8),
      CardModel(suit: CardSuit.heart, value: 7),
    ],
    color: Colors.orangeAccent,
  ),
  CardCombo(
    name: "FOUR OF A KIND",
    rank: "Rank 3",
    description: "4 kartu dengan angka yang sama.",
    counterTip:
        "Sangat kuat melawan Full House. Gunakan SPY (J) untuk mengintip jika lawan punya 3 kartu kembar.",
    cards: [
      CardModel(suit: CardSuit.club, value: 5),
      CardModel(suit: CardSuit.diamond, value: 5),
      CardModel(suit: CardSuit.heart, value: 5),
    ],
    color: Colors.redAccent,
  ),
  CardCombo(
    name: "FULL HOUSE",
    rank: "Rank 4",
    description: "3 kartu angka sama + 2 kartu angka sama (Pair).",
    counterTip:
        "Vulnerable terhadap Four of a Kind. Jika lawan punya 3 kartu di meja, waspada!",
    cards: [
      CardModel(suit: CardSuit.spade, value: 10),
      CardModel(suit: CardSuit.heart, value: 10),
      CardModel(suit: CardSuit.club, value: 3),
    ],
    color: Colors.blueAccent,
  ),
  CardCombo(
    name: "FLUSH",
    rank: "Rank 5",
    description: "5 kartu dengan suit yang sama.",
    counterTip:
        "Gunakan Slot LOCK untuk mengunci suit Anda. Counter balik dengan Full House atau angka yang lebih tinggi.",
    cards: [
      CardModel(suit: CardSuit.diamond, value: 13),
      CardModel(suit: CardSuit.diamond, value: 2),
      CardModel(suit: CardSuit.diamond, value: 8),
    ],
    color: Colors.purpleAccent,
  ),
  CardCombo(
    name: "STRAIGHT",
    rank: "Rank 6",
    description: "5 kartu berurutan (suit boleh berbeda).",
    counterTip:
        "Mudah didapat dengan Joker (Wildcard). Kalahkan dengan Flush (Suit sama).",
    cards: [
      CardModel(suit: CardSuit.spade, value: 6),
      CardModel(suit: CardSuit.heart, value: 5),
      CardModel(suit: CardSuit.diamond, value: 4),
    ],
    color: Colors.greenAccent,
  ),
  CardCombo(
    name: "THREE OF A KIND",
    rank: "Rank 7",
    description: "3 kartu dengan angka yang sama.",
    counterTip:
        "Kalahkan dengan Straight. Gunakan Slot x2 Power pada kartu tertinggi Anda untuk memenangkan tie-break.",
    cards: [
      CardModel(suit: CardSuit.club, value: 8),
      CardModel(suit: CardSuit.heart, value: 8),
      CardModel(suit: CardSuit.spade, value: 8),
    ],
    color: Colors.cyanAccent,
  ),
  CardCombo(
    name: "TWO PAIR",
    rank: "Rank 8",
    description: "Dua pasang kartu dengan angka yang sama.",
    counterTip:
        "Letakkan Pair terbesar di Slot x2 Power. Sangat efektif untuk mengalahkan One Pair lawan.",
    cards: [
      CardModel(suit: CardSuit.diamond, value: 12),
      CardModel(suit: CardSuit.heart, value: 12),
      CardModel(suit: CardSuit.club, value: 4),
    ],
    color: Colors.tealAccent,
  ),
  CardCombo(
    name: "ONE PAIR",
    rank: "Rank 9",
    description: "Satu pasang kartu dengan angka yang sama.",
    counterTip:
        "Gunakan kartu As (A) sebagai Pair untuk keamanan. Pastikan Kicker Anda kuat jika hasil akhir seri.",
    cards: [
      CardModel(suit: CardSuit.spade, value: 11),
      CardModel(suit: CardSuit.heart, value: 11),
      CardModel(suit: CardSuit.diamond, value: 2),
    ],
    color: Colors.lightBlueAccent,
  ),
  CardCombo(
    name: "HIGH CARD",
    rank: "Rank 10",
    description: "Nilai kartu tertinggi yang menentukan.",
    counterTip:
        "TRICK: Taruh kartu As (A) di Slot x2 Power (+20). Total 34 bisa mengalahkan One Pair rendah lawan!",
    cards: [
      CardModel(suit: CardSuit.spade, value: 1),
      CardModel(suit: CardSuit.heart, value: 2),
      CardModel(suit: CardSuit.club, value: 5),
    ],
    color: Colors.grey,
  ),
];
