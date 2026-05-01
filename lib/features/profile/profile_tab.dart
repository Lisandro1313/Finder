import 'package:flutter/material.dart';

import '../../data/models/report_item.dart';
import '../../data/models/user_preferences.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/safety_repository.dart';
import '../common/empty_state_panel.dart';
import '../common/identity_avatar.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.currentUserId,
    required this.profileRepository,
    required this.safetyRepository,
    required this.sessionLabel,
    required this.onLogout,
    required this.onResetFeed,
  });

  final String currentUserId;
  final ProfileRepository profileRepository;
  final SafetyRepository safetyRepository;
  final String sessionLabel;
  final Future<void> Function() onLogout;
  final Future<void> Function() onResetFeed;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _targetController = TextEditingController();
  final _reasonController = TextEditingController(text: 'comportamiento inapropiado');
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  final _maxDistanceController = TextEditingController();

  @override
  void dispose() {
    _targetController.dispose();
    _reasonController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _maxDistanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<UserProfile?>(
      stream: widget.profileRepository.watchProfile(widget.currentUserId),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        if (profile == null) {
          return const EmptyStatePanel(
            icon: Icons.person_search_outlined,
            title: 'Tu perfil todavia no cargo',
            subtitle: 'Reintenta en unos segundos o vuelve a iniciar sesion.',
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Tu cuenta', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    ListTile(
                      leading: IdentityAvatar(
                        seed: widget.currentUserId,
                        label: profile.name,
                        radius: 22,
                        showRing: true,
                      ),
                      title: Text(profile.name),
                      subtitle: const Text('Tu presencia en Finder'),
                    ),
                    ListTile(title: const Text('Sesion'), subtitle: Text(widget.sessionLabel)),
                    ListTile(title: const Text('User ID'), subtitle: Text(widget.currentUserId)),
                    const SizedBox(height: 6),
                    FilledButton.tonal(onPressed: _logout, child: const Text('Cerrar sesion')),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _confirmResetFeed,
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Resetear feed'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Perfil', style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            Card(
              child: Column(
                children: [
                  ListTile(title: const Text('Nombre'), subtitle: Text(profile.name)),
                  ListTile(title: const Text('Edad'), subtitle: Text('${profile.age}')),
                  ListTile(title: const Text('Bio'), subtitle: Text(profile.bio)),
                  ListTile(title: const Text('Distancia max'), subtitle: Text('${profile.distanceKm} km')),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildPreferencesEditor(),
            const SizedBox(height: 20),
            Text('Seguridad', style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    TextField(
                      controller: _targetController,
                      decoration: const InputDecoration(labelText: 'ID de usuario a bloquear/reportar'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _reasonController,
                      decoration: const InputDecoration(labelText: 'Motivo de reporte'),
                    ),
                    const SizedBox(height: 10),
                    FilledButton(onPressed: _blockUser, child: const Text('Bloquear usuario')),
                    const SizedBox(height: 8),
                    OutlinedButton(onPressed: _reportUser, child: const Text('Reportar usuario')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildAdminPanel(),
          ],
        );
      },
    );
  }

  Widget _buildPreferencesEditor() {
    return StreamBuilder<UserPreferences>(
      stream: widget.profileRepository.watchPreferences(widget.currentUserId),
      builder: (context, snapshot) {
        final prefs = snapshot.data ?? UserPreferences.defaults;
        _syncController(_minAgeController, prefs.minAge.toString());
        _syncController(_maxAgeController, prefs.maxAge.toString());
        _syncController(_maxDistanceController, prefs.maxDistanceKm.toString());

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Preferencias de busqueda', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(controller: _minAgeController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Edad minima')),
                const SizedBox(height: 10),
                TextField(controller: _maxAgeController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Edad maxima')),
                const SizedBox(height: 10),
                TextField(controller: _maxDistanceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Distancia maxima (km)')),
                const SizedBox(height: 10),
                FilledButton.tonal(onPressed: _savePreferences, child: const Text('Guardar preferencias')),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdminPanel() {
    return StreamBuilder<bool>(
      stream: widget.safetyRepository.watchIsAdmin(widget.currentUserId),
      builder: (context, snapshot) {
        final isAdmin = snapshot.data == true;
        if (!isAdmin) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Moderacion (Admin)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            StreamBuilder<List<ReportItem>>(
              stream: widget.safetyRepository.watchRecentReports(),
              builder: (context, reportSnap) {
                final reports = reportSnap.data ?? const [];
                if (reports.isEmpty) return const Text('No hay reportes por revisar.');

                return Column(
                  children: reports.map((report) {
                    return Card(
                      child: ListTile(
                        title: Text('Target: ${report.targetUserId}'),
                        subtitle: Text('By: ${report.byUserId}\n${report.reason}\nEstado: ${report.status}'),
                        isThreeLine: true,
                        trailing: report.status == 'reviewed'
                            ? const Icon(Icons.check, color: Colors.green)
                            : OutlinedButton(
                                onPressed: () => _markReviewed(report.id),
                                child: const Text('Revisado'),
                              ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    await widget.onLogout();
  }

  Future<void> _confirmResetFeed() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset feed'),
          content: const Text('Se volveran a mostrar perfiles ya vistos. Deseas continuar?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Resetear')),
          ],
        );
      },
    );

    if (confirm != true) return;
    await widget.onResetFeed();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feed reseteado.')));
  }

  Future<void> _savePreferences() async {
    final minAge = int.tryParse(_minAgeController.text.trim()) ?? UserPreferences.defaults.minAge;
    final maxAge = int.tryParse(_maxAgeController.text.trim()) ?? UserPreferences.defaults.maxAge;
    final maxDistance = int.tryParse(_maxDistanceController.text.trim()) ?? UserPreferences.defaults.maxDistanceKm;

    final normalizedMin = minAge < 18 ? 18 : minAge;
    final normalizedMax = maxAge < normalizedMin ? normalizedMin : maxAge;
    final normalizedDistance = maxDistance < 1 ? 1 : maxDistance;

    await widget.profileRepository.savePreferences(
      userId: widget.currentUserId,
      preferences: UserPreferences(
        minAge: normalizedMin,
        maxAge: normalizedMax,
        maxDistanceKm: normalizedDistance,
      ),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferencias guardadas.')));
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

  Future<void> _markReviewed(String reportId) async {
    await widget.safetyRepository.markReportReviewed(reportId, widget.currentUserId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reporte marcado como revisado.')));
  }

  void _syncController(TextEditingController controller, String nextValue) {
    if (controller.text == nextValue) return;
    controller.value = controller.value.copyWith(
      text: nextValue,
      selection: TextSelection.collapsed(offset: nextValue.length),
    );
  }
}
