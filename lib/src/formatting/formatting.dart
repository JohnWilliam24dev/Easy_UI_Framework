/// Formata valores monetários sem obrigar telas a dependerem de `intl`.
///
/// Os formatos `pt`/`pt_BR` e `en`/`en_US` são tratados explicitamente. Para
/// outros locais, o formato internacional (`1,234.50`) é usado.
String formatMoney(
  num value, {
  String symbol = 'R\$',
  String locale = 'pt_BR',
  int decimals = 2,
}) {
  assert(decimals >= 0, 'decimals deve ser >= 0.');
  final formatted = _formatNumber(value, locale: locale, decimals: decimals);
  return symbol.isEmpty ? formatted : '$symbol $formatted';
}

/// Formata uma data no padrão do locale informado.
String formatDate(DateTime value, {String locale = 'pt_BR'}) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString().padLeft(4, '0');
  if (_usesInternationalOrder(locale)) return '$year-$month-$day';
  return '$day/$month/$year';
}

/// Formata data e hora no padrão do locale informado.
String formatDateTime(DateTime value, {String locale = 'pt_BR'}) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '${formatDate(value, locale: locale)} $hour:$minute';
}

/// Formata uma porcentagem. Sem [total], [value] já representa a porcentagem.
/// Com [total], calcula `value / total * 100`; total zero retorna `0%`.
String formatPercent(
  num value, {
  num? total,
  int decimals = 0,
  String locale = 'pt_BR',
}) {
  assert(decimals >= 0, 'decimals deve ser >= 0.');
  final percentage = total == null
      ? value
      : (total == 0 ? 0 : value / total * 100);
  if (percentage.isNaN || percentage.isInfinite) return '0%';
  return '${_formatNumber(percentage, locale: locale, decimals: decimals)}%';
}

/// Converte números com vírgula ou ponto decimal. Separadores de milhar são
/// ignorados quando o outro símbolo aparece como separador decimal.
double? parseDecimal(String value) {
  var normalized = value.trim().replaceAll(RegExp(r'[^0-9,.-]'), '');
  if (normalized.isEmpty ||
      normalized == '-' ||
      normalized == '.' ||
      normalized == ',') {
    return null;
  }
  final comma = normalized.lastIndexOf(',');
  final dot = normalized.lastIndexOf('.');
  if (comma >= 0 && dot >= 0) {
    final decimal = comma > dot ? ',' : '.';
    final thousand = decimal == ',' ? '.' : ',';
    normalized = normalized.replaceAll(thousand, '').replaceAll(decimal, '.');
  } else if (comma >= 0) {
    normalized = normalized.replaceAll('.', '').replaceAll(',', '.');
  } else if (dot >= 0 && normalized.indexOf('.') != dot) {
    normalized = normalized.replaceAll('.', '');
  }
  return double.tryParse(normalized);
}

String _formatNumber(
  num value, {
  required String locale,
  required int decimals,
}) {
  final separators = _usesInternationalOrder(locale) ? (',', '.') : ('.', ',');
  final fixed = value.abs().toStringAsFixed(decimals);
  final parts = fixed.split('.');
  final whole = parts.first;
  final grouped = StringBuffer();
  for (var index = 0; index < whole.length; index++) {
    if (index > 0 && (whole.length - index) % 3 == 0)
      grouped.write(separators.$1);
    grouped.write(whole[index]);
  }
  final sign = value < 0 ? '-' : '';
  return decimals == 0
      ? '$sign$grouped'
      : '$sign$grouped${separators.$2}${parts.last}';
}

bool _usesInternationalOrder(String locale) =>
    locale.toLowerCase().startsWith('en');
