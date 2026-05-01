import 'package:flutter/material.dart';

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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text('Finder', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 8),
              Text(
                'Conecta con gente cerca, haz match y chatea en tiempo real.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              FilledButton(
                onPressed: isLoading ? null : onContinueWithGoogle,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Continuar con Google'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: isLoading ? null : onContinueAsGuest,
                child: const Text('Entrar como invitado'),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tip: si Google falla en local, usa invitado para seguir testeando.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
