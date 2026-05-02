import 'package:flutter/material.dart';

import '../common/finder_logo_mark.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({
    super.key,
    required this.onContinueWithGoogle,
    required this.onContinueAsGuest,
    required this.isLoading,
  });

  final Future<void> Function() onContinueWithGoogle;
  final Future<void> Function() onContinueAsGuest;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: _BlurCircle(
              size: 260,
              color: theme.colorScheme.primary.withAlpha(56),
            ),
          ),
          Positioned(
            bottom: -130,
            right: -80,
            child: _BlurCircle(
              size: 300,
              color: theme.colorScheme.secondary.withAlpha(51),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const FinderLogoMark(size: 56, iconSize: 28, showShadow: true),
                  const SizedBox(height: 28),
                  Text('Finder', style: theme.textTheme.displaySmall),
                  const SizedBox(height: 8),
                  Text(
                    'Conecta con gente cerca, haz match y chatea en tiempo real.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const Spacer(),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FilledButton.icon(
                            onPressed: isLoading ? null : onContinueWithGoogle,
                            icon: const Icon(Icons.g_mobiledata, size: 24),
                            label: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Continuar con Google'),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: isLoading ? null : onContinueAsGuest,
                            icon: const Icon(Icons.person_outline),
                            label: const Text('Entrar como invitado'),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Si Google falla en local, usa invitado para seguir testeando.',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withAlpha(0)],
          stops: const [0.2, 1],
        ),
      ),
    );
  }
}
