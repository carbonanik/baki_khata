import 'package:baki_khata/main.dart';
import 'package:flutter/material.dart';

class SellSummary extends StatelessWidget {
  final double totalAmount;
  final double dueAmount;
  final int itemCount;
  final bool isFullPaid;
  final TextEditingController paidController;
  final TextEditingController noteController;
  final VoidCallback onPaidChanged;
  final VoidCallback onClearPaid;
  final VoidCallback onNoteChanged;
  final ValueChanged<bool> onFullPaidChanged;

  const SellSummary({
    super.key,
    required this.totalAmount,
    required this.dueAmount,
    required this.itemCount,
    required this.isFullPaid,
    required this.paidController,
    required this.noteController,
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEDF4FF), Color(0xFFF8FAFD)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9E7FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: Color(0xFF1557D5),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Summary',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _editNote(context),
                icon: const Icon(Icons.edit_outlined, size: 17),
                label: Text(
                  noteController.text.trim().isEmpty ? 'Add Note' : 'Edit Note',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1557D5),
                  backgroundColor: const Color(0xFFF7FAFF),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    '($itemCount ${itemCount == 1 ? 'item' : 'items'})',
                    style: const TextStyle(
                      color: Color(0xFF7B8798),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Text(
                currencyFormat.format(totalAmount),
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Paid',
            style: TextStyle(
              color: Color(0xFF778294),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 7),
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
                    color: Color(0xFF111827),
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    prefixText: '৳ ',
                    hintText: '0',
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 13,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: const BorderSide(color: Color(0xFFDCE3ED)),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: const BorderSide(color: Color(0xFFDCE3ED)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: const BorderSide(
                        color: Color(0xFF8EAFE8),
                        width: 1.3,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _CompactAction(
                label: 'Full Paid',
                selected: isFullPaid,
                onPressed: () => onFullPaidChanged(!isFullPaid),
              ),
              const SizedBox(width: 6),
              _CompactAction(label: 'Clear', onPressed: onClearPaid),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 19),
            child: Divider(height: 1, color: Color(0xFFD9E1EB)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Due',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                currencyFormat.format(dueAmount),
                style: TextStyle(
                  color: dueAmount > 0
                      ? const Color(0xFFE04B4B)
                      : const Color(0xFF2FA757),
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (noteController.text.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              noteController.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF778294), fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _editNote(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sale note'),
        content: TextField(
          controller: noteController,
          autofocus: true,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Add an optional note',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Done'),
          ),
        ],
      ),
    );
    onNoteChanged();
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
        foregroundColor: selected ? Colors.white : const Color(0xFF343B46),
        backgroundColor: selected
            ? const Color(0xFF111315)
            : const Color(0xFFEAF0F9),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      child: Text(label),
    );
  }
}
