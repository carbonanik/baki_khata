import 'package:flutter/material.dart';

class SellItemRowData {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  void dispose() {
    nameController.dispose();
    priceController.dispose();
    focusNode.dispose();
  }
}
