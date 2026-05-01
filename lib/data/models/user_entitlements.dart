class UserEntitlements {
  const UserEntitlements({
    required this.plusActive,
    required this.boostCount,
    required this.superLikeCount,
  });

  final bool plusActive;
  final int boostCount;
  final int superLikeCount;

  int dailyLikesLimit() => plusActive ? 50 : 10;

  UserEntitlements copyWith({
    bool? plusActive,
    int? boostCount,
    int? superLikeCount,
  }) {
    return UserEntitlements(
      plusActive: plusActive ?? this.plusActive,
      boostCount: boostCount ?? this.boostCount,
      superLikeCount: superLikeCount ?? this.superLikeCount,
    );
  }

  static const empty = UserEntitlements(
    plusActive: false,
    boostCount: 0,
    superLikeCount: 0,
  );
}
