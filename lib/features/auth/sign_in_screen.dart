import 'package:flutter/material.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({
    super.key,
    required this.onContinue,
    required this.isLoading,
  });

  final Future<void> Function() onContinue;
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
                onPressed: isLoading ? null : onContinue,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Continuar'),
              ),
              const SizedBox(height: 12),
              const Text(
                'Siguiente paso: Google Sign-In / telefono con Firebase Auth.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
