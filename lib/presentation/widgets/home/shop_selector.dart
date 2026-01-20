import 'package:baki_khata/domain/entities/shop.dart';
import 'package:baki_khata/presentation/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dialogs/add_shop_dialog.dart';

class ShopSelector extends ConsumerWidget {
  const ShopSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shop = ref.watch(shopProvider);
    final shopListNotifier = ref.watch(shopProvider.notifier);

    if (shop == null) return const Text('Baki Khata');

    return FutureBuilder<List<Shop>>(
      future: shopListNotifier.getShops(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Text(shop.name);

        final shops = snapshot.data!;

        // Ensure current shop exists in the list to prevent crash
        final isValidShop = shops.any((s) => s.id == shop.id);
        final selectedValue = isValidShop ? shop.id : null;

        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue,
            hint: Text(
              shop.name,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
            onChanged: (String? newValue) {
              if (newValue == 'add_new') {
                showDialog(
                  context: context,
                  builder: (context) => const AddShopDialog(),
                );
              } else if (newValue != null) {
                final selectedShop = shops.firstWhere((s) => s.id == newValue);
                ref.read(shopProvider.notifier).selectShop(selectedShop);
              }
            },
            items: [
              ...shops.map<DropdownMenuItem<String>>((Shop s) {
                return DropdownMenuItem<String>(
                  value: s.id,
                  child: Text(s.name),
                );
              }),
              const DropdownMenuItem<String>(
                value: 'add_new',
                child: Row(
                  children: [
                    Icon(Icons.add, size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Add New Shop', style: TextStyle(color: Colors.blue)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
