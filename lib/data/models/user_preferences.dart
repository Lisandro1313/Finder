class UserPreferences {
  const UserPreferences({
    required this.minAge,
    required this.maxAge,
    required this.maxDistanceKm,
  });

  final int minAge;
  final int maxAge;
  final int maxDistanceKm;

  static const defaults = UserPreferences(minAge: 18, maxAge: 40, maxDistanceKm: 30);
}
