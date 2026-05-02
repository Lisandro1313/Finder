class RetentionMission {
  const RetentionMission({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.target,
    required this.claimed,
    required this.rewardSuperLikes,
    required this.rewardBoosts,
  });

  final String id;
  final String title;
  final String description;
  final int progress;
  final int target;
  final bool claimed;
  final int rewardSuperLikes;
  final int rewardBoosts;

  bool get completed => progress >= target;
}

class RetentionState {
  const RetentionState({
    required this.earlyAccess,
    required this.dateKey,
    required this.streakDays,
    required this.likesToday,
    required this.superLikesToday,
    required this.chatsOpenedToday,
    required this.missions,
  });

  final bool earlyAccess;
  final String dateKey;
  final int streakDays;
  final int likesToday;
  final int superLikesToday;
  final int chatsOpenedToday;
  final List<RetentionMission> missions;

  static RetentionState emptyForDate(String dateKey) {
    return RetentionState(
      earlyAccess: true,
      dateKey: dateKey,
      streakDays: 1,
      likesToday: 0,
      superLikesToday: 0,
      chatsOpenedToday: 0,
      missions: const [],
    );
  }
}
