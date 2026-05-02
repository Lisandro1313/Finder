import 'dart:math' as math;

import 'package:flutter/material.dart';

class FinderAtmosphere extends StatefulWidget {
  const FinderAtmosphere({super.key, required this.child});

  final Widget child;

  @override
  State<FinderAtmosphere> createState() => _FinderAtmosphereState();
}

class _FinderAtmosphereState extends State<FinderAtmosphere>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value * (2 * math.pi);
        final topDx = math.sin(t) * 14;
        final topDy = math.cos(t * 0.8) * 10;
        final bottomDx = math.cos(t * 0.9) * 16;
        final bottomDy = math.sin(t * 1.1) * 11;

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
            Positioned.fill(
              child: CustomPaint(
                painter: _ParticlePainter(progress: _controller.value),
              ),
            ),
            Positioned(
              top: -90 + topDy,
              left: -60 + topDx,
              child: const _GlowBlob(
                size: 220,
                colors: [Color(0x80FF6B8A), Color(0x00FF6B8A)],
              ),
            ),
            Positioned(
              bottom: -130 + bottomDy,
              right: -70 + bottomDx,
              child: const _GlowBlob(
                size: 260,
                colors: [Color(0x809CCBFF), Color(0x009CCBFF)],
              ),
            ),
            widget.child,
          ],
        );
      },
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

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final particles = List.generate(11, (index) => index);
    for (final i in particles) {
      final fx = (i * 0.17 + progress) % 1;
      final fy = (i * 0.23 + (progress * 1.2)) % 1;
      final x = size.width * fx;
      final y = size.height * fy;
      final radius = 1.8 + (i % 3);
      final alpha = 0.10 + ((i % 4) * 0.03);

      final paint = Paint()
        ..color = i.isEven
            ? const Color(0xFFE11D48).withOpacity(alpha)
            : const Color(0xFF60A5FA).withOpacity(alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
