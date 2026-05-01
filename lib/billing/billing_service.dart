import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import 'finder_products.dart';

class BillingService {
  BillingService({InAppPurchase? iap}) : _iap = iap ?? InAppPurchase.instance;

  final InAppPurchase _iap;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  List<ProductDetails> _products = const [];
  List<ProductDetails> get products => _products;

  Future<void> initialize({
    required Future<void> Function(PurchaseDetails purchase) onPurchase,
  }) async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) return;

    final response = await _iap.queryProductDetails(FinderProducts.all);
    _products = response.productDetails;

    _purchaseSub = _iap.purchaseStream.listen((purchases) async {
      for (final purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          await onPurchase(purchase);
        }

        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      }
    });
  }

  ProductDetails? findProduct(String id) {
    for (final product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }

  Future<bool> buyProduct(String productId) async {
    final product = findProduct(productId);
    if (product == null) return false;

    final param = PurchaseParam(productDetails: product);
    if (product.id == FinderProducts.plusSubscription) {
      return _iap.buyNonConsumable(purchaseParam: param);
    }
    return _iap.buyConsumable(purchaseParam: param);
  }

  Future<void> restorePurchases() => _iap.restorePurchases();

  Future<void> dispose() async {
    await _purchaseSub?.cancel();
  }
}
