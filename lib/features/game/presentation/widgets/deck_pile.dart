import 'package:poker_gambit/core/config/app_config.dart';
import 'package:poker_gambit/features/game/presentation/widgets/card_container.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DeckPile extends StatefulWidget {
  final int remainingCards;

  const DeckPile({super.key, required this.remainingCards});

  @override
  State<DeckPile> createState() => _DeckPileState();
}

class _DeckPileState extends State<DeckPile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    _lastCount = widget.remainingCards;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didUpdateWidget(DeckPile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.remainingCards < _lastCount) {
      _controller.forward(from: 0);
    }
    _lastCount = widget.remainingCards;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ...List.generate(
              (widget.remainingCards / 5).clamp(1, 5).toInt(),
              (index) => Padding(
                padding: EdgeInsets.only(top: index * 2.0, left: index * 2.0),
                child: CardContainer(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/cards/card-back.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            // Animated 'flying' card when one is taken
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                if (_controller.isDismissed) return const SizedBox.shrink();
                return Positioned(
                  top: _controller.value * -20,
                  left: _controller.value * 20,
                  child: Opacity(
                    opacity: 1 - _controller.value,
                    child: Transform.scale(
                      scale: 1 + _controller.value * 0.1,
                      child: CardContainer(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl: '${AppConfig.assetBaseUrl}/card-back.png',
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: Colors.black26),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "${widget.remainingCards} CARDS",
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
