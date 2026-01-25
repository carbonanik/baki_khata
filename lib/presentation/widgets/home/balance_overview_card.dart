import 'package:flutter/material.dart';
import '../../../main.dart';

class BalanceOverviewCard extends StatelessWidget {
  final Map<String, double> stats;

  const BalanceOverviewCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),

          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Balance Overview',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(stats['due']),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 4),
            const Divider(color: Colors.black12, thickness: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                _statLabel('SELL', stats['sell']!),
                const SizedBox(width: 24),
                SizedBox(
                  height: 30,
                  child: const VerticalDivider(
                    color: Colors.black12,
                    thickness: 1,
                  ),
                ),
                const SizedBox(width: 24),
                _statLabel('PAID', stats['paid']!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statLabel(String label, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          simpleCurrencyFormat.format(amount),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
