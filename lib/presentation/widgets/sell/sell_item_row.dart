import 'package:flutter/material.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/utils/bengali_formatters.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/transaction.dart';
import '../../../main.dart';
import 'sell_item_row_data.dart';

const _units = ['কেজি', 'লিটার', 'পিস', 'বস্তা'];
const _green = Color(0xFF006B4F);
const _ink = Color(0xFF172333);
const _muted = Color(0xFF75808D);

class SellItemRow extends StatelessWidget {
  final int itemNumber;
  final SellItemRowData rowData;
  final List<Product> products;
  final VoidCallback onRemove;
  final VoidCallback onAddToList;
  final VoidCallback onCalculated;

  const SellItemRow({
    super.key,
    required this.itemNumber,
    required this.rowData,
    required this.products,
    required this.onRemove,
    required this.onAddToList,
    required this.onCalculated,
  });

  double get _quantity =>
      parseBengaliNumber(rowData.quantityController.text) ?? 0;

  double get _unitPrice =>
      parseBengaliNumber(rowData.priceController.text) ?? 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFB8D8CC)),
        boxShadow: const [appShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.add_shopping_cart_rounded,
                color: _green,
                size: 22,
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'নতুন পণ্য যোগ করুন',
                  style: TextStyle(
                    color: _green,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF8EC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'আইটেম #${toBengaliDigits(itemNumber)}',
                  style: const TextStyle(
                    color: _green,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 22, color: Color(0xFFE8ECF2)),
          const Text(
            'পণ্যের নাম',
            style: TextStyle(
              color: _muted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Autocomplete<Product>(
            optionsBuilder: (value) {
              if (value.text.trim().isEmpty) {
                return const Iterable<Product>.empty();
              }
              return products.where(
                (product) => product.name.toLowerCase().contains(
                  value.text.toLowerCase(),
                ),
              );
            },
            displayStringForOption: (product) => product.name,
            onSelected: (product) {
              rowData.nameController.text = product.name;
              rowData.priceController.text = toBengaliDigits(
                product.price.toStringAsFixed(0),
              );
              onCalculated();
            },
            fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: (value) {
                  rowData.nameController.text = value;
                  onCalculated();
                },
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(color: _ink, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'পণ্যের নাম লিখুন বা খুঁজুন',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: _muted,
                    size: 21,
                  ),
                  suffixIcon: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: _green,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF0F3FF),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide.none,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'পরিমাণ',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F3FF),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Row(
                        children: [
                          _QuantityButton(
                            icon: Icons.remove,
                            onPressed: () {
                              if (_quantity <= 0.1) return;
                              rowData.quantityController.text = toBengaliDigits(
                                _quantity > 1 ? _quantity - 1 : 0.1,
                              );
                              onCalculated();
                            },
                          ),
                          Expanded(
                            child: TextField(
                              controller: rowData.quantityController,
                              textAlign: TextAlign.center,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              onChanged: (_) => onCalculated(),
                              style: const TextStyle(
                                color: _ink,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          _QuantityButton(
                            icon: Icons.add,
                            onPressed: () {
                              rowData.quantityController.text = toBengaliDigits(
                                _quantity + 1,
                              );
                              onCalculated();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'একক দর (৳)',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: rowData.priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => onCalculated(),
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        prefixText: '৳ ',
                        hintText: '০',
                        filled: true,
                        fillColor: const Color(0xFFF0F3FF),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          const Text(
            'একক নির্বাচন করুন',
            style: TextStyle(
              color: _muted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: _units.map((unit) {
              final selected = rowData.unit == unit;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: ChoiceChip(
                    label: Text(unit),
                    selected: selected,
                    showCheckmark: false,
                    onSelected: (_) {
                      rowData.unit = unit;
                      onCalculated();
                    },
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : _ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    selectedColor: _green,
                    backgroundColor: const Color(0xFFF0F3FF),
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F3FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'আইটেমের মোট দাম',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  currencyFormat.format(_quantity * _unitPrice),
                  style: const TextStyle(
                    color: _green,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onAddToList,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('তালিকায় যোগ করুন'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 7),
              TextButton(
                onPressed: onRemove,
                style: TextButton.styleFrom(
                  foregroundColor: _muted,
                  backgroundColor: const Color(0xFFF0F3FF),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: const Text('বাতিল'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SavedSellItemCard extends StatelessWidget {
  final SaleItem item;
  final VoidCallback onRemove;

  const SavedSellItemCard({
    super.key,
    required this.item,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [appShadow],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text(
                      'দর: ${currencyFormat.format(item.unitPrice)}',
                      style: const TextStyle(color: _muted, fontSize: 13),
                    ),
                    const Text('•', style: TextStyle(color: _muted)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDF8EC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${toBengaliDigits(item.quantity)} ${item.unit}',
                        style: const TextStyle(
                          color: _green,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat.format(item.price),
                style: const TextStyle(
                  color: _ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                onPressed: onRemove,
                tooltip: 'তালিকা থেকে সরান',
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(
                  width: 36,
                  height: 36,
                ),
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: _muted,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 19),
      color: _green,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 42, height: 42),
    );
  }
}
