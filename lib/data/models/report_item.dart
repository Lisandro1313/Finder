class ReportItem {
  const ReportItem({
    required this.id,
    required this.byUserId,
    required this.targetUserId,
    required this.reason,
    required this.status,
  });

  final String id;
  final String byUserId;
  final String targetUserId;
  final String reason;
  final String status;
}
