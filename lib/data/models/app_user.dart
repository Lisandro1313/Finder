class AppUser {
  const AppUser({
    required this.id,
    required this.isAnonymous,
    required this.providerId,
  });

  final String id;
  final bool isAnonymous;
  final String providerId;

  String get sessionLabel {
    if (isAnonymous) return 'Anonima (MVP)';
    if (providerId == 'google.com') return 'Google';
    return providerId.isEmpty ? 'Desconocida' : providerId;
  }
}
