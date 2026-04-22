import 'package:flutter/material.dart';

class CardContainer extends StatelessWidget {
  final Widget child;
  final Color? color;

  const CardContainer({super.key, required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 130,
      decoration: BoxDecoration(
        color: color ?? const Color(0xFF3E2723),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: child,
    );
  }
}
