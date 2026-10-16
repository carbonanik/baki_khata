import 'package:baki_khata/domain/entities/expense.dart';
import 'package:baki_khata/presentation/widgets/dialogs/add_expense_dialog.dart';
import 'package:baki_khata/presentation/utils/expense_category_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../../main.dart'; // for currencyFormat and dateFormat

const _bengaliMonthNames = [
  'জানুয়ারি',
  'ফেব্রুয়ারি',
  'মার্চ',
  'এপ্রিল',
  'মে',
  'জুন',
  'জুলাই',
  'আগস্ট',
  'সেপ্টেম্বর',
  'অক্টোবর',
  'নভেম্বর',
  'ডিসেম্বর',
];

const _pageBackground = Color(0xFFF5F7FC);
const _accentColor = Color(0xFF00845F);
const _inkColor = Color(0xFF13243A);
const _mutedColor = Color(0xFF718096);

class ExpensePage extends ConsumerStatefulWidget {
  const ExpensePage({super.key});

  @override
  ConsumerState<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends ConsumerState<ExpensePage> {
  DateTime _selectedMonth = DateTime.now();
  bool _todayOnly = false;

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expenseProvider);
    final visibleExpenses = expenses.where((expense) {
      if (_todayOnly) {
        return DateUtils.isSameDay(expense.timestamp, DateTime.now());
      }
      return expense.timestamp.year == _selectedMonth.year &&
          expense.timestamp.month == _selectedMonth.month;
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final total = visibleExpenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
    final average = visibleExpenses.isEmpty
        ? 0.0
        : total / visibleExpenses.length;
    final categoryTotals = {
      for (final category in defaultExpenseCategories)
        category: visibleExpenses
            .where((expense) => expense.category == category)
            .fold<double>(0, (sum, expense) => sum + expense.amount),
    };

    return Scaffold(
      backgroundColor: _pageBackground,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const AddExpenseDialog(),
        ),
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text(
          'খরচ লিখুন',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFB4003A),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'দোকানের খরচ হিসাব',
                            style: TextStyle(
                              color: _inkColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 16, top: 3),
                      child: Text(
                        'দৈনিক দোকান খরচ',
                        style: TextStyle(color: _mutedColor, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _PeriodSelector(
                      todayOnly: _todayOnly,
                      selectedMonth: _selectedMonth,
                      onTodaySelected: () => setState(() => _todayOnly = true),
                      onMonthSelected: () => setState(() => _todayOnly = false),
                      onMonthTap: _chooseMonth,
                    ),
                    const SizedBox(height: 14),
                    _ExpenseSummaryCard(
                      total: total,
                      expenseCount: visibleExpenses.length,
                      average: average,
                      todayOnly: _todayOnly,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(
                          Icons.pie_chart_outline,
                          color: _accentColor,
                          size: 19,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'খরচের খাতসমূহ',
                            style: TextStyle(
                              color: _inkColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          '${defaultExpenseCategories.length}টি খাত',
                          style: const TextStyle(
                            color: _mutedColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: defaultExpenseCategories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1.05,
                          ),
                      itemBuilder: (context, index) {
                        final category = defaultExpenseCategories[index];
                        return _CategoryCard(
                          category: category,
                          amount: categoryTotals[category] ?? 0,
                          icon: expenseCategoryIcon(category),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.history, color: _inkColor, size: 19),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'সাম্প্রতিক খরচসমূহ',
                            style: TextStyle(
                              color: _inkColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          '${visibleExpenses.length}টি',
                          style: const TextStyle(
                            color: _accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            if (visibleExpenses.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  child: _EmptyExpenses(todayOnly: _todayOnly),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final expense = visibleExpenses[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Dismissible(
                        key: Key(expense.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                        ),
                        confirmDismiss: (_) => _confirmDelete(context),
                        onDismissed: (_) => ref
                            .read(expenseProvider.notifier)
                            .deleteExpense(expense.id),
                        child: _ExpenseRow(expense: expense),
                      ),
                    );
                  }, childCount: visibleExpenses.length),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseMonth() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'মাস নির্বাচন করুন',
    );
    if (selectedDate != null && mounted) {
      setState(() {
        _selectedMonth = DateTime(selectedDate.year, selectedDate.month);
        _todayOnly = false;
      });
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('খরচ মুছে ফেলবেন?'),
            content: const Text('এই কাজটি আর ফিরিয়ে নেওয়া যাবে না।'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('বাতিল'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('মুছুন', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.todayOnly,
    required this.selectedMonth,
    required this.onTodaySelected,
    required this.onMonthSelected,
    required this.onMonthTap,
  });

  final bool todayOnly;
  final DateTime selectedMonth;
  final VoidCallback onTodaySelected;
  final VoidCallback onMonthSelected;
  final VoidCallback onMonthTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FA),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              _PeriodTab(
                label: 'চলতি মাস',
                detail: 'This Month',
                selected: !todayOnly,
                onTap: onMonthSelected,
              ),
              _PeriodTab(
                label: 'আজকের দিন',
                detail: 'Today',
                selected: todayOnly,
                onTap: onTodaySelected,
              ),
            ],
          ),
        ),
        if (!todayOnly)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onMonthTap,
              icon: const Icon(Icons.calendar_month_outlined, size: 17),
              label: Text(
                '${_bengaliMonthNames[selectedMonth.month - 1]} ${selectedMonth.year}',
              ),
              style: TextButton.styleFrom(
                foregroundColor: _accentColor,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
      ],
    );
  }
}

class _PeriodTab extends StatelessWidget {
  const _PeriodTab({
    required this.label,
    required this.detail,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String detail;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x120D2340),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text.rich(
              TextSpan(
                text: label,
                style: TextStyle(
                  color: selected ? _accentColor : _inkColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  TextSpan(
                    text: ' ($detail)',
                    style: TextStyle(
                      color: selected ? _accentColor : _mutedColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpenseSummaryCard extends StatelessWidget {
  const _ExpenseSummaryCard({
    required this.total,
    required this.expenseCount,
    required this.average,
    required this.todayOnly,
  });

  final double total;
  final int expenseCount;
  final double average;
  final bool todayOnly;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFFFF5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1E6EA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100D2340),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            todayOnly ? 'আজকের মোট খরচ' : 'চলতি মাসের মোট খরচ',
            style: const TextStyle(
              color: _mutedColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  currencyFormat.format(total),
                  style: const TextStyle(
                    color: Color(0xFFB4003A),
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  color: Color(0xFFB4003A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  icon: Icons.receipt_long_outlined,
                  label: 'খরচের সংখ্যা',
                  value: '$expenseCountটি',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryMetric(
                  icon: Icons.stacked_line_chart,
                  label: 'গড় খরচ',
                  value: currencyFormat.format(average),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF2FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: _accentColor, size: 17),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _mutedColor, fontSize: 10),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _inkColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
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

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.amount,
    required this.icon,
  });

  final String category;
  final double amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE8EDF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFE6EEFF),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: _accentColor, size: 17),
          ),
          const Spacer(),
          Text(
            category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _inkColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            currencyFormat.format(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFB4003A),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final icon = expenseCategoryIcon(expense.category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EEF5)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFE6EEFF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _accentColor, size: 21),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _inkColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  expense.note?.isNotEmpty == true
                      ? expense.note!
                      : dateFormat.format(expense.timestamp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _mutedColor, fontSize: 11),
                ),
                if (expense.note?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      dateFormat.format(expense.timestamp),
                      style: const TextStyle(color: _mutedColor, fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat.format(expense.amount),
                style: const TextStyle(
                  color: Color(0xFFB4003A),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'নগদ খরচ',
                style: TextStyle(color: _mutedColor, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyExpenses extends StatelessWidget {
  const _EmptyExpenses({required this.todayOnly});

  final bool todayOnly;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EEF5)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            color: Color(0xFF91A0B4),
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            todayOnly ? 'আজকের কোনো খরচ নেই' : 'এই মাসে কোনো খরচ নেই',
            style: const TextStyle(
              color: _inkColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'নতুন খরচ যোগ করতে নিচের বোতামে চাপ দিন।',
            textAlign: TextAlign.center,
            style: TextStyle(color: _mutedColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
