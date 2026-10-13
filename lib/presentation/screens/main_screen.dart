import 'package:baki_khata/presentation/screens/products_page.dart';
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
      appBar: _selectedIndex == 1
          ? AppBar(
              title: const Text('Expenses'),
              actions: [
                IconButton(
                  tooltip: 'Products',
                  onPressed: () {
                    setState(() => _selectedIndex = 2);
                  },
                  icon: const Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.black,
                  ),
                ),
              ],
            )
          : _selectedIndex == 2
              ? AppBar(title: const Text('Products'))
              : null,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 69,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
            boxShadow: [
              BoxShadow(
                color: Color(0x0D25364A),
                blurRadius: 14,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              _NavigationItem(
                icon: Icons.people_alt_outlined,
                label: 'Customers',
                selected: _selectedIndex == 0,
                onTap: () => setState(() => _selectedIndex = 0),
              ),
              _NavigationItem(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Expenses',
                selected: _selectedIndex == 1,
                onTap: () => setState(() => _selectedIndex = 1),
              ),
              _NavigationItem(
                icon: Icons.inventory_2_outlined,
                label: 'Products',
                selected: _selectedIndex == 2,
                onTap: () => setState(() => _selectedIndex = 2),
              ),
            ],
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
    final color = selected ? const Color(0xFF111111) : const Color(0xFF858585);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              height: 3,
              width: selected ? 56 : 0,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
