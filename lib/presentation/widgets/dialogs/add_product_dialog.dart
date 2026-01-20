import 'package:baki_khata/presentation/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/product.dart';

class AddProductDialog extends ConsumerStatefulWidget {
  final Product? productToEdit;
  const AddProductDialog({super.key, this.productToEdit});

  @override
  ConsumerState<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<AddProductDialog> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.productToEdit != null) {
      nameController.text = widget.productToEdit!.name;
      priceController.text = widget.productToEdit!.price.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.productToEdit != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit Product' : 'New Product'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: 'Product Name',
              border: UnderlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: priceController,
            decoration: const InputDecoration(
              hintText: 'Price',
              prefixText: '৳ ',
              border: UnderlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () {
            if (nameController.text.isNotEmpty &&
                priceController.text.isNotEmpty) {
              if (isEdit) {
                final updatedProduct = Product(
                  id: widget.productToEdit!.id,
                  shopId: '', // Provider will set this
                  name: nameController.text,
                  price: double.tryParse(priceController.text) ?? 0,
                );
                ref
                    .read(productProvider.notifier)
                    .updateProduct(updatedProduct);
              } else {
                final product = Product(
                  shopId: '', // Provider will set this
                  name: nameController.text,
                  price: double.tryParse(priceController.text) ?? 0,
                );
                ref.read(productProvider.notifier).addProduct(product);
              }
              Navigator.pop(context);
            }
          },
          child: const Text(
            'SAVE',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
