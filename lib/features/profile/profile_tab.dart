import 'package:flutter/material.dart';

import '../../data/models/user_profile.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/safety_repository.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.currentUserId,
    required this.profileRepository,
    required this.safetyRepository,
    required this.sessionLabel,
    required this.onLogout,
  });

  final String currentUserId;
  final ProfileRepository profileRepository;
  final SafetyRepository safetyRepository;
  final String sessionLabel;
  final Future<void> Function() onLogout;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _targetController = TextEditingController();
  final _reasonController = TextEditingController(text: 'comportamiento inapropiado');

  @override
  void dispose() {
    _targetController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfile?>(
      stream: widget.profileRepository.watchProfile(widget.currentUserId),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        if (profile == null) {
          return const Center(child: Text('Perfil no disponible.'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Cuenta', style: TextStyle(fontWeight: FontWeight.bold)),
            ListTile(title: const Text('Sesion'), subtitle: Text(widget.sessionLabel)),
            ListTile(title: const Text('User ID'), subtitle: Text(widget.currentUserId)),
            FilledButton.tonal(
              onPressed: _logout,
              child: const Text('Cerrar sesion'),
            ),
            const SizedBox(height: 20),
            const Text('Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
            ListTile(title: const Text('Nombre'), subtitle: Text(profile.name)),
            ListTile(title: const Text('Edad'), subtitle: Text('${profile.age}')),
            ListTile(title: const Text('Bio'), subtitle: Text(profile.bio)),
            ListTile(title: const Text('Distancia max'), subtitle: Text('${profile.distanceKm} km')),
            const SizedBox(height: 20),
            const Text('Seguridad', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _targetController,
              decoration: const InputDecoration(labelText: 'ID de usuario a bloquear/reportar'),
            ),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(labelText: 'Motivo de reporte'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _blockUser,
              child: const Text('Bloquear usuario'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _reportUser,
              child: const Text('Reportar usuario'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    await widget.onLogout();
  }

  Future<void> _blockUser() async {
    final target = _targetController.text.trim();
    if (target.isEmpty) return;
    await widget.safetyRepository.blockUser(byUserId: widget.currentUserId, targetUserId: target);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario bloqueado.')));
  }

  Future<void> _reportUser() async {
    final target = _targetController.text.trim();
    final reason = _reasonController.text.trim();
    if (target.isEmpty || reason.isEmpty) return;
    await widget.safetyRepository.reportUser(
      byUserId: widget.currentUserId,
      targetUserId: target,
      reason: reason,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reporte enviado.')));
  }
}
