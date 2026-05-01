import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../billing/billing_service.dart';
import '../../billing/finder_products.dart';
import '../../data/models/purchase_event_item.dart';
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
    try {
      await widget.entitlementRepository.applyPurchase(
        userId: widget.userId,
        productId: purchase.productID,
        purchaseId: purchase.purchaseID,
        verificationData: purchase.verificationData.serverVerificationData,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compra enviada a verificacion de servidor.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pudimos procesar la compra. Intenta de nuevo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) return const Center(child: CircularProgressIndicator());

    return StreamBuilder<UserEntitlements>(
      stream: widget.entitlementRepository.watchEntitlements(widget.userId),
      builder: (context, snapshot) {
        final ent = snapshot.data ?? UserEntitlements.empty;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
          children: [
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFE11D48), Color(0xFFFF8A65)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ent.plusActive ? 'Finder Plus activo' : 'Activa Finder Plus',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Mas alcance, mas visibilidad, mas chances reales de conectar.',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.92)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: _CounterCard(
                            label: 'Boosts',
                            value: '${ent.boostCount}',
                            icon: Icons.local_fire_department_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _CounterCard(
                            label: 'Super Likes',
                            value: '${ent.superLikeCount}',
                            icon: Icons.star_outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (!_billingService.isAvailable)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2F4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text('Google Play Billing no disponible en este entorno.'),
              ),
            _PremiumProductTile(
              title: 'Finder Plus',
              subtitle: 'Ver likes, undo y mas intentos diarios',
              productId: FinderProducts.plusSubscription,
              billingService: _billingService,
              icon: Icons.workspace_premium_outlined,
            ),
            _PremiumProductTile(
              title: 'Boost',
              subtitle: 'Mas visibilidad durante 30 minutos',
              productId: FinderProducts.boostPack,
              billingService: _billingService,
              icon: Icons.local_fire_department_outlined,
            ),
            _PremiumProductTile(
              title: 'Super Like',
              subtitle: 'Apareces con prioridad',
              productId: FinderProducts.superLikePack,
              billingService: _billingService,
              icon: Icons.star_border,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _billingService.restorePurchases,
              child: const Text('Restaurar compras'),
            ),
            const SizedBox(height: 16),
            Text('Estado de compras', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            StreamBuilder<List<PurchaseEventItem>>(
              stream: widget.entitlementRepository.watchPurchaseEvents(widget.userId),
              builder: (context, eventSnapshot) {
                final events = eventSnapshot.data ?? const [];
                if (events.isEmpty) {
                  return const Text('Sin eventos de compra recientes.');
                }

                return Column(
                  children: events.map((event) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        dense: true,
                        leading: const Icon(Icons.receipt_long_outlined),
                        title: Text(event.productId),
                        subtitle: Text(
                          event.reason == null
                              ? 'Estado: ${event.status}'
                              : 'Estado: ${event.status} | Motivo: ${event.reason}',
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
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
    final theme = Theme.of(context);
    final product = billingService.findProduct(productId);
    final price = product?.price ?? 'Configurar en Play Console';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFE11D48)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: product == null ? null : () => billingService.buyProduct(productId),
              child: Text(price),
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterCard extends StatelessWidget {
  const _CounterCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE11D48)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6A607F))),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
