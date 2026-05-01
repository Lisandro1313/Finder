import 'package:flutter/material.dart';

class FinderAtmosphere extends StatelessWidget {
  const FinderAtmosphere({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF9F4FF),
                Color(0xFFFDF8F8),
                Color(0xFFF4FBFF),
              ],
              stops: [0, 0.5, 1],
            ),
          ),
        ),
        const Positioned(
          top: -90,
          left: -60,
          child: _GlowBlob(
            size: 220,
            colors: [Color(0x80FF6B8A), Color(0x00FF6B8A)],
          ),
        ),
        const Positioned(
          bottom: -130,
          right: -70,
          child: _GlowBlob(
            size: 260,
            colors: [Color(0x809CCBFF), Color(0x009CCBFF)],
          ),
        ),
        child,
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({
    required this.size,
    required this.colors,
  });

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: colors,
          stops: const [0.2, 1],
        ),
      ),
    );
  }
}
