import 'package:baki_khata/presentation/screens/products_page.dart';
import 'package:baki_khata/core/theme/app_shadows.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'expense_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    HomePage(),
    ExpensePage(),
    ProductsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      // appBar: _selectedIndex == 1
      //     ? AppBar(
      //         title: const Text('Expenses'),
      //         actions: [
      //           IconButton(
      //             tooltip: 'Products',
      //             onPressed: () {
      //               setState(() => _selectedIndex = 2);
      //             },
      //             icon: const Icon(
      //               Icons.inventory_2_outlined,
      //               color: Colors.black,
      //             ),
      //           ),
      //         ],
      //       )
      //     : _selectedIndex == 2
      //         ? AppBar(title: const Text('Products'))
      //         : null,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FF),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [appShadow],
            ),
            child: Row(
              children: [
                _NavigationItem(
                  icon: Icons.people_alt_outlined,
                  label: 'হিসাব',
                  selected: _selectedIndex == 0,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
                _NavigationItem(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'খরচ',
                  selected: _selectedIndex == 1,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
                _NavigationItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'পণ্য',
                  selected: _selectedIndex == 2,
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF3E4943) : const Color(0xFF858585);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
