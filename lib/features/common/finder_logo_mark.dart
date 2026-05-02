import 'package:flutter/material.dart';

class FinderLogoMark extends StatelessWidget {
  const FinderLogoMark({
    super.key,
    this.size = 56,
    this.iconSize = 28,
    this.showShadow = false,
  });

  final double size;
  final double iconSize;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE11D48), Color(0xFFFF6B6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: showShadow
            ? const [
                BoxShadow(
                  color: Color(0x40E11D48),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.favorite, color: Colors.white, size: iconSize),
          Positioned(
            bottom: size * 0.18,
            child: Container(
              width: size * 0.42,
              height: size * 0.08,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.86),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
