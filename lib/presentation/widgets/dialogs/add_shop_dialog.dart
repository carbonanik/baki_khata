import 'package:baki_khata/presentation/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/shop.dart';

class AddShopDialog extends ConsumerStatefulWidget {
  const AddShopDialog({super.key});

  @override
  ConsumerState<AddShopDialog> createState() => _AddShopDialogState();
}

class _AddShopDialogState extends ConsumerState<AddShopDialog> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Shop'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: 'Shop Name',
              border: UnderlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: addressController,
            decoration: const InputDecoration(
              hintText: 'Address (Optional)',
              border: UnderlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(
              hintText: 'Phone (Optional)',
              border: UnderlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () async {
            if (nameController.text.isNotEmpty) {
              final shop = Shop(
                name: nameController.text,
                address: addressController.text.isEmpty
                    ? null
                    : addressController.text,
                phone: phoneController.text.isEmpty
                    ? null
                    : phoneController.text,
              );
              await ref.read(shopProvider.notifier).addShop(shop);
              if (mounted) Navigator.pop(context);
            }
          },
          child: const Text(
            'ADD',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
