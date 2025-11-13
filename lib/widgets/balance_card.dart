import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/wallet_service.dart'; // Only this import needed

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<WalletService>(
          builder: (context, wallet, child) {
            return Text(
              'Balance: ${wallet.balance}',
              style: const TextStyle(fontSize: 24),
            );
          },
        ),
      ),
    );
  }
}