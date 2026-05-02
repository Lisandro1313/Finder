class FinderProfile {
  const FinderProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.distanceKm,
    required this.bio,
    this.photoUrl,
  });

  final String id;
  final String name;
  final int age;
  final int distanceKm;
  final String bio;
  final String? photoUrl;
}
