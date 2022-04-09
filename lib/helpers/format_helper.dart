import 'package:intl/intl.dart';

String moneyNoCents(dynamic value) {
  if (value == null) return '';
  final List<String> parts =
      NumberFormat("#,##0.00", "pt_BR").format(value).split(',');
  return parts.sublist(0, parts.length - 1).join();
}
