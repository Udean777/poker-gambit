enum PokerHandRank {
  highCard("High Card", 1),
  onePair("One Pair", 2),
  twoPair("Two Pair", 3),
  threeOfAKind("Three of a Kind", 4),
  straight("Straight", 5),
  flush("Flush", 6),
  fullHouse("Full House", 7),
  fourOfAKind("Four of a Kind", 8),
  straightFlush("Straight Flush", 9),
  royalFlush("Royal Flush", 10),
  fiveOfAKind("Five of a Kind", 11);

  final String label;
  final int power;

  const PokerHandRank(this.label, this.power);
}

class HandResult {
  final PokerHandRank rank;
  final List<int> kickers;

  HandResult({required this.rank, required this.kickers});
}
