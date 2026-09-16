// Copyright 2026 WITHLET11 <withlet11@gmail.com>
// SPDX-License-Identifier: MIT

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseManager extends ChangeNotifier {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  ProductDetails? fullProduct;
  bool isFullUser = false;
  bool isLoading = true;

  static const String kFullProductID =
      'io.github.withlet11.readblank.full_lifetime';

  Future<void> initialize() async {
    // Listen to purchase updates across app restarts/purchases
    final Stream<List<PurchaseDetails>> purchaseStream = _iap.purchaseStream;
    _subscription = purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription.cancel(),
      onError: (error) {
        debugPrint("Purchase Stream Error: $error");
        isLoading = false;
        notifyListeners();
      },
    );

    // Query product details from store
    final bool available = await _iap.isAvailable();
    if (available) {
      final ProductDetailsResponse response = await _iap.queryProductDetails({
        kFullProductID,
      });

      if (response.productDetails.isNotEmpty) {
        fullProduct = response.productDetails.first;
      }

      // Restore purchases
      await _iap.restorePurchases();
    }

    isLoading = false;
    notifyListeners();
  }

  // Initiate purchase
  void buyFullVersion() {
    if (fullProduct == null) return;
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: fullProduct!,
    );
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  // Restore purchases (Mandatory for App Store review)
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchase in purchaseDetailsList) {
      if (purchase.productID == kFullProductID) {
        switch (purchase.status) {
          case PurchaseStatus.purchased:
          case PurchaseStatus.restored:
            _deliverProduct(purchase);
            break;
          case PurchaseStatus.error:
            debugPrint("Purchase error: ${purchase.error}");
            break;
          case PurchaseStatus.pending:
            break;
          default:
            break;
        }

        if (purchase.pendingCompletePurchase) {
          _iap.completePurchase(purchase);
        }
      }
    }
  }

  void _deliverProduct(PurchaseDetails purchase) {
    isFullUser = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
