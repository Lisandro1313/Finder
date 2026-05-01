String displayNameFromId(String raw) {
  final clean = raw.trim().replaceAll('_', ' ').replaceAll('-', ' ');
  if (clean.isEmpty) return 'Usuario';

  return clean
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
