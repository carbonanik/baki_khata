import 'package:baki_khata/presentation/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/product.dart';

const _accentColor = Color(0xFF006B4F);
const _inkColor = Color(0xFF13243A);

class AddProductDialog extends ConsumerStatefulWidget {
  final Product? productToEdit;
  const AddProductDialog({super.key, this.productToEdit});

  @override
  ConsumerState<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final product = widget.productToEdit;
    if (product != null) {
      _nameController.text = product.name;
      _priceController.text = product.price.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.productToEdit != null;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
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
                padding: const EdgeInsets.fromLTRB(18, 4, 14, 14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF95F6C8),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: Color(0xFF002114),
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        isEdit ? 'পণ্য সম্পাদনা' : 'নতুন পণ্য যোগ করুন',
                        style: const TextStyle(
                          color: _inkColor,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'বন্ধ করুন',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
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
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('পণ্যের নাম'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          autofocus: !isEdit,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.next,
                          decoration: _inputDecoration(
                            hintText: 'যেমন: মিনিকেট চাল',
                            prefixIcon: Icons.inventory_2_outlined,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'পণ্যের নাম লিখুন';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F3FF),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calculate_outlined,
                                    color: _accentColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'বিক্রয় মূল্য',
                                      style: TextStyle(
                                        color: _inkColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      '৳ টাকা',
                                      style: TextStyle(
                                        color: _mutedColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _priceController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                textInputAction: TextInputAction.done,
                                decoration: _inputDecoration(
                                  hintText: '0.00',
                                  prefixIcon: Icons.payments_outlined,
                                  prefixText: '৳ ',
                                ),
                                validator: (value) {
                                  final price = double.tryParse(
                                    value?.trim() ?? '',
                                  );
                                  if (price == null) {
                                    return 'সঠিক মূল্য লিখুন';
                                  }
                                  if (price < 0) {
                                    return 'মূল্য শূন্যের কম হতে পারবে না';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'এই দামটি পণ্য বিক্রির সময় ব্যবহার হবে।',
                          style: TextStyle(
                            color: Color(0xFF718096),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _saveProduct,
                    style: FilledButton.styleFrom(
                      backgroundColor: _accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(
                      _isSaving ? 'সংরক্ষণ হচ্ছে...' : 'সংরক্ষণ করুন',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF9AA4B2), fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: _accentColor, size: 20),
      prefixText: prefixText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _accentColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFB42336)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFB42336), width: 1.5),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    final price = double.parse(_priceController.text.trim());
    final existingProduct = widget.productToEdit;

    try {
      if (existingProduct == null) {
        await ref
            .read(productProvider.notifier)
            .addProduct(
              Product(
                shopId: '',
                name: _nameController.text.trim(),
                price: price,
              ),
            );
      } else {
        await ref
            .read(productProvider.notifier)
            .updateProduct(
              Product(
                id: existingProduct.id,
                shopId: existingProduct.shopId,
                name: _nameController.text.trim(),
                price: price,
              ),
            );
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      debugPrint('Failed to save product: $error');
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('পণ্য সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।'),
          ),
        );
      }
    }
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _inkColor,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

const _mutedColor = Color(0xFF718096);
