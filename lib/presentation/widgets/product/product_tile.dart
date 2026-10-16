import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/product.dart';
import '../../../main.dart';
import '../../providers/app_providers.dart';
import '../dialogs/add_product_dialog.dart';

class ProductTile extends ConsumerWidget {
  final Product product;
  const ProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1B3555),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showProductSheet(context, product),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F8F0),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: Color(0xFF006B4F),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF13243A),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          const Icon(
                            Icons.sell_outlined,
                            size: 15,
                            color: Color(0xFF718096),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'বিক্রয় মূল্য',
                            style: TextStyle(
                              color: Color(0xFF718096),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              currencyFormat.format(product.price),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF006B4F),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'সম্পাদনা করুন',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _showProductSheet(context, product),
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF718096),
                        size: 20,
                      ),
                    ),
                    IconButton(
                      tooltip: 'মুছে ফেলুন',
                      visualDensity: VisualDensity.compact,
                      onPressed: () =>
                          _showDeleteConfirmation(context, ref, product),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFB42336),
                        size: 21,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProductSheet(BuildContext context, Product product) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddProductDialog(productToEdit: product),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              ref.read(productProvider.notifier).deleteProduct(product.id);
              Navigator.pop(context);
            },
            child: const Text(
              'DELETE',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
