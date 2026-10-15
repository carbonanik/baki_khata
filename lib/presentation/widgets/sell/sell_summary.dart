import 'package:baki_khata/main.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/utils/bengali_formatters.dart';

const _green = Color(0xFF006B4F);
const _ink = Color(0xFF172333);
const _muted = Color(0xFF75808D);

class SellSummary extends StatelessWidget {
  final double grossAmount;
  final double discountAmount;
  final double totalAmount;
  final double dueAmount;
  final double customerDue;
  final bool hasExcessDiscount;
  final bool hasExcessPaid;
  final int itemCount;
  final bool isFullPaid;
  final TextEditingController discountController;
  final TextEditingController paidController;
  final TextEditingController noteController;
  final VoidCallback onDiscountChanged;
  final VoidCallback onPaidChanged;
  final VoidCallback onClearPaid;
  final VoidCallback onNoteChanged;
  final ValueChanged<bool> onFullPaidChanged;

  const SellSummary({
    super.key,
    required this.grossAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.dueAmount,
    required this.customerDue,
    required this.hasExcessDiscount,
    required this.hasExcessPaid,
    required this.itemCount,
    required this.isFullPaid,
    required this.discountController,
    required this.paidController,
    required this.noteController,
    required this.onDiscountChanged,
    required this.onPaidChanged,
    required this.onClearPaid,
    required this.onNoteChanged,
    required this.onFullPaidChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [appShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AmountRow(
            label: 'মোট বিল (${toBengaliDigits(itemCount)}টি)',
            amount: grossAmount,
            color: _muted,
          ),
          const SizedBox(height: 12),
          const Text(
            'ছাড় / ডিসকাউন্ট',
            style: TextStyle(
              color: Color(0xFFB20E42),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  'ছাড়ের পরিমাণ: ${currencyFormat.format(discountAmount)}',
                  style: const TextStyle(
                    color: Color(0xFFB20E42),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                width: 125,
                child: TextField(
                  controller: discountController,
                  textAlign: TextAlign.end,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => onDiscountChanged(),
                  style: const TextStyle(
                    color: Color(0xFFB20E42),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    prefixText: '৳ ',
                    hintText: '০',
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFFFF2F4),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 11,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (hasExcessDiscount)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'ছাড়ের পরিমাণ মোট বিলের বেশি হতে পারবে না।',
                style: TextStyle(color: Color(0xFFB20E42), fontSize: 12),
              ),
            ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: _AmountRow(
              label: 'প্রদেয় টাকা',
              amount: totalAmount,
              color: _green,
              large: true,
            ),
          ),
          const SizedBox(height: 17),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'জমা পেয়েছেন',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _CompactAction(
                    label: 'পুরো পরিশোধ',
                    selected: isFullPaid,
                    onPressed: () => onFullPaidChanged(!isFullPaid),
                  ),
                ],
              ),
              if (hasExcessPaid)
                const Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    'জমার পরিমাণ প্রদেয় টাকার বেশি হতে পারবে না।',
                    style: TextStyle(color: Color(0xFFB20E42), fontSize: 12),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: paidController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      enabled: !isFullPaid,
                      onChanged: (_) => onPaidChanged(),
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        prefixText: '৳ ',
                        hintText: '০',
                        filled: true,
                        fillColor: const Color(0xFFF6F8FC),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  IconButton(
                    onPressed: onClearPaid,
                    tooltip: 'জমার পরিমাণ মুছুন',
                    icon: const Icon(Icons.backspace_outlined),
                    color: _muted,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFB20E42),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'নতুন বাকি যোগ হবে',
                            style: TextStyle(
                              color: Color(0xFF9B123D),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'কাস্টমারের মোট বাকি: ${currencyFormat.format(customerDue)}',
                            style: const TextStyle(color: _ink, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      currencyFormat.format(dueAmount),
                      style: const TextStyle(
                        color: Color(0xFFB20E42),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'লেনদেনের বিবরণ / বিশেষ নোট (ঐচ্ছিক)',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _editNote(context),
                child: Text(
                  noteController.text.trim().isEmpty ? 'যোগ করুন' : 'সম্পাদনা',
                  style: const TextStyle(color: _green),
                ),
              ),
            ],
          ),
          TextField(
            controller: noteController,
            onChanged: (_) => onNoteChanged(),
            textCapitalization: TextCapitalization.sentences,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'যেমন: বাকি টাকা পরে দেবেন',
              prefixIcon: const Icon(Icons.notes_rounded, color: _muted),
              filled: true,
              fillColor: const Color(0xFFF0F3FF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editNote(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('লেনদেনের নোট'),
        content: TextField(
          controller: noteController,
          autofocus: true,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'ঐচ্ছিক নোট লিখুন',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('সম্পন্ন'),
          ),
        ],
      ),
    );
    onNoteChanged();
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool large;

  const _AmountRow({
    required this.label,
    required this.amount,
    required this.color,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: large ? 16 : 14,
              fontWeight: large ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          currencyFormat.format(amount),
          style: TextStyle(
            color: color,
            fontSize: large ? 23 : 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _CompactAction extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  const _CompactAction({
    required this.label,
    this.selected = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: selected ? Colors.white : _green,
        backgroundColor: selected ? _green : const Color(0xFFDDF8EC),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        minimumSize: const Size(0, 35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}
