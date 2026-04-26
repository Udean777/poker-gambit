import 'package:flutter/material.dart';

/// Subtle elliptical border drawn behind the poker table area.
class TableBackground extends StatelessWidget {
  const TableBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: Container(
        width: size.width * 0.9,
        height: size.height * 0.5,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          border: Border.all(color: Colors.white10, width: 4),
          borderRadius: const BorderRadius.all(Radius.elliptical(500, 300)),
        ),
      ),
    );
  }
}
