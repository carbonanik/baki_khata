import 'package:flutter/material.dart';
import '../../../main.dart';

class BalanceOverviewCard extends StatelessWidget {
  final Map<String, double> stats;

  const BalanceOverviewCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE8EFF8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0B5274A3),
            blurRadius: 19,
            offset: Offset(0, 7),
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
                      'Total Due',
                      style: TextStyle(
                        color: Color(0xFF697586),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        currencyFormat.format(stats['due'] ?? 0),
                        style: const TextStyle(
                          color: Color(0xFFEF2929),
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 61,
                height: 61,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFECEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Color(0xFFEF2929),
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFDDE3EA), height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _StatItem(
                icon: Icons.shopping_cart_outlined,
                iconColor: const Color(0xFF20A645),
                iconBackground: const Color(0xFFE5F8EA),
                title: 'Total Sell',
                amount: stats['sell'] ?? 0,
              )),
              Container(
                width: 1,
                height: 48,
                color: const Color(0xFFDDE3EA),
                margin: const EdgeInsets.symmetric(horizontal: 11),
              ),
              Expanded(child: _StatItem(
                icon: Icons.credit_card_outlined,
                iconColor: const Color(0xFF1768E8),
                iconBackground: const Color(0xFFE7F0FF),
                title: 'Paid',
                amount: stats['paid'] ?? 0,
              )),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.amount,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: iconBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 25),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF697586),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  simpleCurrencyFormat.format(amount),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
