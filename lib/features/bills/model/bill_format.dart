String formatBillDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String formatBillDateDashed(DateTime date) =>
    formatBillDate(date).replaceAll('/', '-');

String formatBillNumber(double value) => value.toStringAsFixed(2);

// Indian digit grouping, e.g. 1,25,000.00
String formatBillAmount(double value) {
  final fixed = value.toStringAsFixed(2);
  final negative = fixed.startsWith('-');
  final parts = (negative ? fixed.substring(1) : fixed).split('.');
  var whole = parts[0];
  if (whole.length > 3) {
    final lastThree = whole.substring(whole.length - 3);
    final rest = whole
        .substring(0, whole.length - 3)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d\d)+$)'), (m) => '${m[1]},');
    whole = '$rest,$lastThree';
  }
  return '${negative ? '-' : ''}$whole.${parts[1]}';
}
