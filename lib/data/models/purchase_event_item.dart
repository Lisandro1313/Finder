class PurchaseEventItem {
  const PurchaseEventItem({
    required this.id,
    required this.productId,
    required this.status,
    required this.reason,
  });

  final String id;
  final String productId;
  final String status;
  final String? reason;
}
