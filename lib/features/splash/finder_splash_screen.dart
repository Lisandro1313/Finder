import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../common/finder_atmosphere.dart';
import '../common/finder_logo_mark.dart';

class FinderSplashScreen extends StatefulWidget {
  const FinderSplashScreen({super.key});

  @override
  State<FinderSplashScreen> createState() => _FinderSplashScreenState();
}

class _FinderSplashScreenState extends State<FinderSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: FinderAtmosphere(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = Curves.easeInOut.transform(_controller.value);
              final scale = 0.97 + (t * 0.06);
              final tilt = math.sin(t * math.pi) * 0.01;

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateZ(tilt),
                child: Transform.scale(scale: scale, child: child),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FinderLogoMark(size: 74, iconSize: 35, showShadow: true),
                const SizedBox(height: 18),
                Text('Finder', style: theme.textTheme.displaySmall),
                const SizedBox(height: 8),
                Text(
                  'Conectando personas cerca tuyo...',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
