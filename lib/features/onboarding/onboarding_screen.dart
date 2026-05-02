import 'package:flutter/material.dart';

import '../common/ui_feedback.dart';

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
  int _step = 0;

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tu perfil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                          3,
                          (index) => Expanded(
                            child: Container(
                              height: 6,
                              margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
                              decoration: BoxDecoration(
                                color: _step >= index ? const Color(0xFFE11D48) : const Color(0xFFE2DDEF),
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(_stepTitle(), style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(_stepSubtitle(), style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _buildStepContent(),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _saving ? null : _handlePrimaryAction,
                icon: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_step == 2 ? Icons.check_circle_outline : Icons.arrow_forward_rounded),
                label: Text(_step == 2 ? 'Guardar y continuar' : 'Continuar'),
              ),
              if (_step > 0) ...[
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _saving
                      ? null
                      : () {
                          setState(() => _step -= 1);
                        },
                  child: const Text('Volver'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    if (_step == 0) {
      return Card(
        key: const ValueKey('step_0'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Edad',
                  prefixIcon: Icon(Icons.cake_outlined),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_step == 1) {
      return Card(
        key: const ValueKey('step_1'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: TextField(
            controller: _bioController,
            textInputAction: TextInputAction.newline,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Bio',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.edit_note_outlined),
            ),
          ),
        ),
      );
    }

    return Card(
      key: const ValueKey('step_2'),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            TextField(
              controller: _distanceController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Distancia maxima (km)',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 10),
            const ListTile(
              leading: Icon(Icons.auto_awesome),
              title: Text('Tip'),
              subtitle: Text('Completa bien tu bio y vas a mejorar tus matches iniciales.'),
            ),
          ],
        ),
      ),
    );
  }

  String _stepTitle() {
    if (_step == 0) return 'Arranquemos con vos';
    if (_step == 1) return 'Mostra tu estilo';
    return 'Ajusta tu zona';
  }

  String _stepSubtitle() {
    if (_step == 0) return 'Nombre y edad para presentarte en Finder.';
    if (_step == 1) return 'Una bio corta y autentica atrae mejores conversaciones.';
    return 'Define hasta donde queres descubrir gente.';
  }

  Future<void> _handlePrimaryAction() async {
    if (_step == 0) {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        UiFeedback.warning();
        _showValidation('Escribe tu nombre para continuar.');
        return;
      }
      UiFeedback.selection();
      setState(() => _step = 1);
      return;
    }

    if (_step == 1) {
      final bio = _bioController.text.trim();
      if (bio.isEmpty) {
        UiFeedback.warning();
        _showValidation('Escribe una bio para continuar.');
        return;
      }
      UiFeedback.selection();
      setState(() => _step = 2);
      return;
    }

    await _save();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final age = (int.tryParse(_ageController.text.trim()) ?? 18).clamp(18, 99).toInt();
    final bio = _bioController.text.trim();
    final distanceKm =
        (int.tryParse(_distanceController.text.trim()) ?? 10).clamp(1, 200).toInt();

    if (name.isEmpty || bio.isEmpty) {
      UiFeedback.warning();
      _showValidation('Completa nombre y bio.');
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.onSave(name: name, age: age, bio: bio, distanceKm: distanceKm);
      UiFeedback.success();
    } catch (_) {
      UiFeedback.warning();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar el perfil. Intenta otra vez.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showValidation(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
