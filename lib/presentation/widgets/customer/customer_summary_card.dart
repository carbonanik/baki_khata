import 'package:flutter/material.dart';
import '../../../main.dart';

class CustomerSummaryCard extends StatelessWidget {
  final double totalSell;
  final double totalPaid;
  final double due;

  const CustomerSummaryCard({
    super.key,
    required this.totalSell,
    required this.totalPaid,
    required this.due,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9EACC2).withValues(alpha: 0.12),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Due',
                          style: TextStyle(
                            color: Color(0xFF778294),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          currencyFormat.format(due),
                          style: TextStyle(
                            color: due > 0
                                ? const Color(0xFFE83F3C)
                                : const Color(0xFF2FA757),
                            fontSize: 32,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEEEE),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.storefront_outlined,
                      color: Color(0xFFE83F3C),
                      size: 29,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Total sell: ${currencyFormat.format(totalSell)}',
                style: const TextStyle(color: Color(0xFF778294), fontSize: 14),
              ),
              const SizedBox(height: 3),
              Text(
                'Total paid: ${currencyFormat.format(totalPaid)}',
                style: const TextStyle(color: Color(0xFF778294), fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _TotalCard(
                label: 'Total Sell',
                amount: totalSell,
                icon: Icons.shopping_cart_outlined,
                foreground: const Color(0xFF27A454),
                background: const Color(0xFFEAF7EF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TotalCard(
                label: 'Total Paid',
                amount: totalPaid,
                icon: Icons.credit_card_outlined,
                foreground: const Color(0xFF1763D7),
                background: const Color(0xFFEDF3FF),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TotalCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color foreground;
  final Color background;

  const _TotalCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9EACC2).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: foreground, size: 23),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF778294),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currencyFormat.format(amount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
