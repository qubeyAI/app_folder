import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:qubeyai/screens/main_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool _available = false;
  List<ProductDetails> _products = [];
  bool _isLoading = true;

  static const List<String> _kProductIds = <String>[
    'monthly_subscription', // Replace with your real product ID from Play Console
    'yearly_subscription',  // Replace with your real product ID from Play Console
  ];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  /// Initialize In-App Purchase connection and get available products
  Future<void> _initialize() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      setState(() {
        _available = false;
        _isLoading = false;
      });
      return;
    }

    final ProductDetailsResponse response =
    await _inAppPurchase.queryProductDetails(_kProductIds.toSet());

    if (response.error != null || response.productDetails.isEmpty) {
      setState(() {
        _available = false;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _available = true;
      _products = response.productDetails;
      _isLoading = false;
    });

    // Listen to purchase updates
    _subscription = _inAppPurchase.purchaseStream.listen(_onPurchaseUpdated);
  }

  /// Handle purchases after user completes payment
  void _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        await _verifyAndDeliverPurchase(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase error: ${purchase.error}')),
        );
      }
    }
  }

  /// Verify purchase and deliver subscription content
  Future<void> _verifyAndDeliverPurchase(PurchaseDetails purchase) async {
    // In real apps, verify this purchase from your backend server using Google APIs.
    bool valid = true;

    if (valid) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isSubscribed', true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subscription active! Redirecting...')),
      );

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainHomeScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid purchase. Please try again.')),
      );
    }
  }

  Future<void> _buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ✅ Preview mode: For local test or no billing available
    if (!_available || _products.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Subscription Preview')),
        backgroundColor: Colors.black,
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              '🔧 Preview Mode (Local Test)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                title: const Text('₹992 / month (Refundable)'),
                subtitle: const Text('Billed monthly. Cancel anytime.'),
                trailing: ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isSubscribed', true);
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainHomeScreen(),
                        ),
                      );
                    }
                  },
                  child: const Text('Subscribe'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text('₹3192 / year (3-day trial)'),
                subtitle: const Text('Best value plan'),
                trailing: ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isSubscribed', true);
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainHomeScreen(),
                        ),
                      );
                    }
                  },
                  child: const Text('Subscribe'),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ✅ Real purchase mode
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose your plan'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),
          const Text(
            'Unlock Premium Access',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ..._products.map((product) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: ListTile(
                title: Text(product.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(product.description),
                trailing: ElevatedButton(
                  onPressed: () => _buyProduct(product),
                  child: Text(product.price),
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          const Text(
            'By subscribing, you agree to our Terms of Service and Privacy Policy.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}