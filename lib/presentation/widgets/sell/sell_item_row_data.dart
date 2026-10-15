import 'package:flutter/material.dart';

class SellItemRowData {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController(
    text: '১',
  );
  final FocusNode focusNode = FocusNode();
  String unit = 'কেজি';

  void dispose() {
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
    focusNode.dispose();
  }
}
