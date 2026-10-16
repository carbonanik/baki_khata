import 'package:flutter/material.dart';

IconData expenseCategoryIcon(String category) => switch (category) {
  'চা ও আপ্যায়ন' => Icons.coffee_outlined,
  'দোকান ভাড়া' => Icons.storefront_outlined,
  'বিদ্যুৎ বিল' => Icons.bolt_outlined,
  'পরিবহন / ভাড়া' => Icons.local_shipping_outlined,
  'কর্মচারী বেতন' => Icons.badge_outlined,
  'অন্যান্য' => Icons.more_horiz,
  _ => Icons.receipt_long_outlined,
};
