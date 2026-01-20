import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../widgets/product/product_tile.dart';
import '../widgets/dialogs/add_product_dialog.dart';

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const AddProductDialog(),
        ),
        child: const Icon(Icons.add),
      ),
      body: products.isEmpty
          ? const Center(
              child: Text(
                'No products yet',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.separated(
              itemCount: products.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: Color(0xFFF0F0F0), height: 1),
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductTile(product: product);
              },
            ),
    );
  }
}
