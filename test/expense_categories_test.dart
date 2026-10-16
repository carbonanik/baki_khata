import 'package:baki_khata/domain/entities/expense.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default expense categories match the Bengali category list', () {
    expect(defaultExpenseCategories, [
      'চা ও আপ্যায়ন',
      'দোকান ভাড়া',
      'বিদ্যুৎ বিল',
      'পরিবহন / ভাড়া',
      'কর্মচারী বেতন',
      'অন্যান্য',
    ]);
  });
}
