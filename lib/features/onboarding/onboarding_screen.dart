import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.onSave,
  });

  final Future<void> Function({
    required String name,
    required int age,
    required String bio,
    required int distanceKm,
  }) onSave;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController(text: '25');
  final _bioController = TextEditingController();
  final _distanceController = TextEditingController(text: '10');
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completa tu perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Edad'),
            ),
            TextField(controller: _bioController, decoration: const InputDecoration(labelText: 'Bio')),
            TextField(
              controller: _distanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Distancia max (km)'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Guardar y continuar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim()) ?? 18;
    final bio = _bioController.text.trim();
    final distanceKm = int.tryParse(_distanceController.text.trim()) ?? 10;

    if (name.isEmpty || bio.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa nombre y bio.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.onSave(name: name, age: age, bio: bio, distanceKm: distanceKm);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar el perfil. Intenta otra vez.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
