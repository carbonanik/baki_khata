const _bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
const _bengaliMonths = [
  'জানুয়ারি',
  'ফেব্রুয়ারি',
  'মার্চ',
  'এপ্রিল',
  'মে',
  'জুন',
  'জুলাই',
  'আগস্ট',
  'সেপ্টেম্বর',
  'অক্টোবর',
  'নভেম্বর',
  'ডিসেম্বর',
];

String toBengaliDigits(Object value) {
  return value.toString().replaceAllMapped(
    RegExp(r'\d'),
    (match) => _bengaliDigits[int.parse(match[0]!)],
  );
}

double? parseBengaliNumber(String value) {
  final latinDigits = value
      .replaceAll('০', '0')
      .replaceAll('১', '1')
      .replaceAll('২', '2')
      .replaceAll('৩', '3')
      .replaceAll('৪', '4')
      .replaceAll('৫', '5')
      .replaceAll('৬', '6')
      .replaceAll('৭', '7')
      .replaceAll('৮', '8')
      .replaceAll('৯', '9')
      .replaceAll(',', '')
      .trim();
  return double.tryParse(latinDigits);
}

String formatBengaliDate(DateTime date, {bool includeTime = true}) {
  final dayAndMonth =
      '${toBengaliDigits(date.day)} ${_bengaliMonths[date.month - 1]}';
  if (!includeTime) return dayAndMonth;

  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final period = date.hour < 12 ? 'পূর্বাহ্ন' : 'অপরাহ্ন';
  return '$dayAndMonth, ${toBengaliDigits(hour)}:'
      '${toBengaliDigits(date.minute.toString().padLeft(2, '0'))} $period';
}
