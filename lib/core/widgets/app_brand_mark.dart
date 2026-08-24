import 'package:flutter/material.dart';

class AppBrandMark extends StatelessWidget {
  const AppBrandMark({
    super.key,
    this.size = 42,
    this.padding = 6,
    this.backgroundColor = Colors.white,
  });

  final double size;
  final double padding;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size * .28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/logo/10.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.architecture_rounded,
          color: Color(0xFF0D47A1),
        ),
      ),
    );
  }
}
