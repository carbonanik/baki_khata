import 'package:baki_khata/main.dart';
import 'package:flutter/material.dart';

class SellSummary extends StatelessWidget {
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final bool isFullPaid;
  final TextEditingController paidController;
  final TextEditingController noteController;
  final VoidCallback onPaidChanged;
  final ValueChanged<bool> onFullPaidChanged;

  const SellSummary({
    super.key,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.isFullPaid,
    required this.paidController,
    required this.noteController,
    required this.onPaidChanged,
    required this.onFullPaidChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Total Amount
          _summaryRow(
            'Total',
            totalAmount,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),

          const SizedBox(height: 24),

          // Paid Amount with Full Paid Toggle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paid',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: paidController,
                      keyboardType: TextInputType.number,
                      enabled: !isFullPaid,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isFullPaid ? Colors.grey[400] : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        prefixText: '৳ ',
                        prefixStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isFullPaid ? Colors.grey[400] : Colors.black87,
                        ),
                        // border: InputBorder.none,
                        hintText: '0',
                        hintStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isFullPaid ? Colors.grey[400] : Colors.black87,
                        ),
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      onChanged: (_) => onPaidChanged(),
                    ),
                  ],
                ),
              ),

              // Full Paid Chip
              GestureDetector(
                onTap: () => onFullPaidChanged(!isFullPaid),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isFullPaid ? Colors.black : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isFullPaid ? Icons.check_circle : Icons.circle_outlined,
                        size: 16,
                        color: isFullPaid ? Colors.white : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Full Paid',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isFullPaid ? Colors.white : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Note Field
          TextField(
            controller: noteController,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Note (optional)',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              // border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            textCapitalization: TextCapitalization.sentences,
            maxLines: 2,
          ),

          const SizedBox(height: 24),

          // Divider
          // Container(height: 1, color: Colors.grey[200]),
          // Divider(),

          // const SizedBox(height: 24),

          // Due Amount
          _summaryRow(
            'Due',
            dueAmount,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            valueColor: dueAmount > 0 ? Colors.red[600] : Colors.green[600],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    double amount, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: Colors.grey[700],
          ),
        ),
        Text(
          currencyFormat.format(amount),
          style: TextStyle(
            fontSize: fontSize + 2,
            fontWeight: FontWeight.w700,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
