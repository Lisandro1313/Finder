String formatTimeAgo(DateTime? when) {
  if (when == null) return 'recien';

  final diff = DateTime.now().difference(when);
  if (diff.inSeconds < 45) return 'recien';
  if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'hace ${diff.inHours} h';
  if (diff.inDays < 7) return 'hace ${diff.inDays} d';
  return 'hace ${(diff.inDays / 7).floor()} sem';
}
