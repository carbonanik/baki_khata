import 'package:flutter/material.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../main.dart';

class BalanceOverviewCard extends StatelessWidget {
  const BalanceOverviewCard({
    super.key,
    required this.stats,
    required this.customersWithDue,
  });

  final Map<String, double> stats;
  final int customersWithDue;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0FFF7), Colors.white, Colors.white],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EDF2)),
        boxShadow: const [appShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.circle, color: Color(0xFFB0003A), size: 9),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'মোট বাকি পাওনা (Total Due)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF4A5750),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE2E7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.people_alt_outlined,
                      color: Color(0xFFB0003A),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$customersWithDue জন বাকি',
                      style: const TextStyle(
                        color: Color(0xFFB0003A),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              currencyFormat.format(stats['due'] ?? 0),
              style: const TextStyle(
                color: Color(0xFFB0003A),
                fontSize: 29,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.payments_outlined,
                    iconColor: const Color(0xFF006B4F),
                    title: 'নগদ জমা (Cash In)',
                    amount: stats['paid'] ?? 0,
                  ),
                ),
                Container(
                  width: 1,
                  height: 39,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: const Color(0xFFDCE2EF),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.storefront_outlined,
                    iconColor: const Color(0xFF34466D),
                    title: 'মোট বিক্রি (Net Sale)',
                    amount: stats['sell'] ?? 0,
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

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.amount,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF59636F),
                  fontSize: 10,
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
                    color: Color(0xFF1E293B),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
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
