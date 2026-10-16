import 'package:baki_khata/domain/entities/expense.dart';
import 'package:baki_khata/presentation/utils/expense_category_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';

const _accentColor = Color(0xFF00845F);
const _inkColor = Color(0xFF13243A);

class AddExpenseDialog extends ConsumerStatefulWidget {
  const AddExpenseDialog({super.key});

  @override
  ConsumerState<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends ConsumerState<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _customCategoryController = TextEditingController();
  String _selectedCategory = defaultExpenseCategories.first;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD4DCD7),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: _accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.payments_outlined,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'খরচ লিখুন',
                      style: TextStyle(
                        color: _inkColor,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'বন্ধ করুন',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF0F3FA),
                      foregroundColor: _inkColor,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE8EDF4)),
            Flexible(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AmountInput(
                        controller: _amountController,
                        validator: _validateAmount,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'খরচের খাত',
                              style: TextStyle(
                                color: _inkColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => setState(
                              () => _selectedCategory =
                                  defaultExpenseCategories.last,
                            ),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('নতুন খাত'),
                            style: TextButton.styleFrom(
                              foregroundColor: _accentColor,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: defaultExpenseCategories.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1.22,
                            ),
                        itemBuilder: (context, index) {
                          final category = defaultExpenseCategories[index];
                          final selected = category == _selectedCategory;
                          return _CategoryOption(
                            category: category,
                            selected: selected,
                            icon: expenseCategoryIcon(category),
                            onTap: () => setState(
                              () => _selectedCategory = category,
                            ),
                          );
                        },
                      ),
                      if (_selectedCategory ==
                          defaultExpenseCategories.last) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _customCategoryController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'নিজস্ব খাতের নাম (ঐচ্ছিক)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ],
                      const SizedBox(height: 17),
                      const Text(
                        'খরচের নোট বা বিবরণ',
                        style: TextStyle(
                          color: Color(0xFF5E6C7E),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 7),
                      TextField(
                        controller: _noteController,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 1,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'যেমন: চা ও বিস্কুট কেনা',
                          prefixIcon: const Icon(Icons.notes_outlined),
                          filled: true,
                          fillColor: const Color(0xFFEEF3FC),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF3FC),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              color: Color(0xFF637286),
                              size: 17,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'তারিখ ও সময়',
                                style: TextStyle(
                                  color: Color(0xFF5E6C7E),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Text(
                              'এখন',
                              style: TextStyle(
                                color: _accentColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedPadding(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.fromLTRB(16, 10, 16, 12 + bottomInset),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        foregroundColor: _inkColor,
                        side: const BorderSide(color: Color(0xFFDDE5EF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: const Text('বাতিল'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: FilledButton.icon(
                      onPressed: _saveExpense,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('খরচ সংরক্ষণ করুন'),
                      style: FilledButton.styleFrom(
                        backgroundColor: _accentColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateAmount(String? value) {
    final amount = double.tryParse(value?.trim() ?? '');
    if (amount == null || !amount.isFinite || amount <= 0) {
      return 'সঠিক পরিমাণ লিখুন';
    }
    return null;
  }

  void _saveExpense() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final customCategory = _customCategoryController.text.trim();
    final expense = Expense(
      shopId: '',
      amount: double.parse(_amountController.text.trim()),
      category:
          _selectedCategory == defaultExpenseCategories.last &&
              customCategory.isNotEmpty
          ? customCategory
          : _selectedCategory,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    ref.read(expenseProvider.notifier).addExpense(expense);
    Navigator.pop(context);
  }
}

class _AmountInput extends StatelessWidget {
  const _AmountInput({required this.controller, required this.validator});

  final TextEditingController controller;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF3FC),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFDDE5F1)),
      ),
      child: Column(
        children: [
          const Text(
            'খরচের পরিমাণ (টাকায়) *',
            style: TextStyle(
              color: Color(0xFF5E6C7E),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextFormField(
            controller: controller,
            validator: validator,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _inkColor,
              fontSize: 29,
              fontWeight: FontWeight.w900,
            ),
            decoration: const InputDecoration(
              prefixText: '৳ ',
              prefixStyle: TextStyle(
                color: _accentColor,
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
              hintText: '০',
              hintStyle: TextStyle(color: Color(0xFF91A0B4)),
              border: InputBorder.none,
              errorMaxLines: 1,
            ),
          ),
          const Divider(height: 12, color: Color(0xFFDDE5F1)),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _QuickAmountChip(
                label: '+৳ ৫০',
                value: 50,
                controller: controller,
              ),
              _QuickAmountChip(
                label: '+৳ ১০০',
                value: 100,
                controller: controller,
              ),
              _QuickAmountChip(
                label: '+৳ ২০০',
                value: 200,
                controller: controller,
              ),
              _QuickAmountChip(
                label: '+৳ ৫০০',
                value: 500,
                controller: controller,
              ),
              _QuickAmountChip(
                label: '+৳ ১,০০০',
                value: 1000,
                controller: controller,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAmountChip extends StatelessWidget {
  const _QuickAmountChip({
    required this.label,
    required this.value,
    required this.controller,
  });

  final String label;
  final int value;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: () {
        final current = double.tryParse(controller.text.trim()) ?? 0;
        controller.text = '${current + value}';
        controller.selection = TextSelection.collapsed(
          offset: controller.text.length,
        );
      },
      label: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      ),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFDDE5F1)),
    );
  }
}

class _CategoryOption extends StatelessWidget {
  const _CategoryOption({
    required this.category,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  final String category;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : _inkColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? _accentColor : Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected ? _accentColor : const Color(0xFFDDE5DF),
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: foreground, size: 19),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Positioned(
                top: 1,
                right: 1,
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
