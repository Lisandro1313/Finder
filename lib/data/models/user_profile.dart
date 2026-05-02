class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.bio,
    required this.distanceKm,
    this.photoUrl,
  });

  final String id;
  final String name;
  final int age;
  final String bio;
  final int distanceKm;
  final String? photoUrl;
}
