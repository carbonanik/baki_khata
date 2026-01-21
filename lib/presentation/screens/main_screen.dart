import 'package:baki_khata/presentation/screens/products_page.dart';
import 'package:flutter/material.dart';
import '../../presentation/screens/home_page.dart';
import '../../presentation/screens/expense_page.dart';
import '../widgets/home/shop_selector.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    ExpensePage(),
    ProductsPage(), // Assuming you might want Products here too, but users request didn't strictly say tab, but implementation plan did not include Products tab change, just Expense. user said "separate tab".
    // Wait, the plan only mentioned Customers and Expenses tabs.
    // I see ProductsPage in the file list. I will stick to two tabs for now as per immediate plan or add products if it makes sense.
    // Let's stick to Home (Customers) and Expenses.
    // The HomePage currently has a link to ProductsPage.
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ShopSelector(),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductsPage()),
              );
            },
            icon: const Icon(Icons.inventory_2_outlined, color: Colors.black),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Expenses',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 8,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
