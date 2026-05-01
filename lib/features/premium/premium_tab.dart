import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../billing/billing_service.dart';
import '../../billing/finder_products.dart';
import '../../data/models/user_entitlements.dart';
import '../../data/repositories/entitlement_repository.dart';

class PremiumTab extends StatefulWidget {
  const PremiumTab({
    super.key,
    required this.userId,
    required this.entitlementRepository,
  });

  final String userId;
  final EntitlementRepository entitlementRepository;

  @override
  State<PremiumTab> createState() => _PremiumTabState();
}

class _PremiumTabState extends State<PremiumTab> {
  late final BillingService _billingService;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _billingService = BillingService();
    _initBilling();
  }

  @override
  void dispose() {
    _billingService.dispose();
    super.dispose();
  }

  Future<void> _initBilling() async {
    await _billingService.initialize(onPurchase: _handlePurchase);
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    await widget.entitlementRepository.applyPurchase(
      userId: widget.userId,
      productId: purchase.productID,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Compra aplicada: ${purchase.productID}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return StreamBuilder<UserEntitlements>(
      stream: widget.entitlementRepository.watchEntitlements(widget.userId),
      builder: (context, snapshot) {
        final ent = snapshot.data ?? UserEntitlements.empty;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                title: Text(ent.plusActive ? 'Finder Plus activo' : 'Finder Plus inactivo'),
                subtitle: Text('Boosts: ${ent.boostCount} | SuperLikes: ${ent.superLikeCount}'),
              ),
            ),
            if (!_billingService.isAvailable)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('Google Play Billing no disponible en este entorno.'),
              ),
            _PremiumProductTile(
              title: 'Finder Plus',
              subtitle: 'Ver likes, undo y mas intentos diarios.',
              productId: FinderProducts.plusSubscription,
              billingService: _billingService,
              icon: Icons.workspace_premium_outlined,
            ),
            _PremiumProductTile(
              title: 'Boost',
              subtitle: 'Mas visibilidad durante 30 minutos.',
              productId: FinderProducts.boostPack,
              billingService: _billingService,
              icon: Icons.local_fire_department_outlined,
            ),
            _PremiumProductTile(
              title: 'Super Like',
              subtitle: 'Apareces con prioridad.',
              productId: FinderProducts.superLikePack,
              billingService: _billingService,
              icon: Icons.star_border,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _billingService.restorePurchases,
              child: const Text('Restaurar compras'),
            ),
          ],
        );
      },
    );
  }
}

class _PremiumProductTile extends StatelessWidget {
  const _PremiumProductTile({
    required this.title,
    required this.subtitle,
    required this.productId,
    required this.billingService,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String productId;
  final BillingService billingService;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final product = billingService.findProduct(productId);
    final price = product?.price ?? 'Configurar en Play Console';

    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: FilledButton(
          onPressed: product == null ? null : () => billingService.buyProduct(productId),
          child: Text(price),
        ),
      ),
    );
  }
}
