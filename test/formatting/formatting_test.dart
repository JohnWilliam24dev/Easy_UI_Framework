import 'package:easy_ui/easy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formata dinheiro nos locais suportados', () {
    expect(formatMoney(1234.5), 'R\$ 1.234,50');
    expect(formatMoney(1234.5, symbol: '\$', locale: 'en_US'), '\$ 1,234.50');
  });

  test('formata data, data e hora', () {
    final value = DateTime(2026, 10, 11, 9, 5);
    expect(formatDate(value), '11/10/2026');
    expect(formatDate(value, locale: 'en_US'), '2026-10-11');
    expect(formatDateTime(value), '11/10/2026 09:05');
  });

  test('formata porcentagem sem divisão por zero', () {
    expect(formatPercent(12.5, decimals: 1), '12,5%');
    expect(formatPercent(0, total: 0), '0%');
    expect(formatPercent(3, total: 4), '75%');
  });

  test('interpreta vírgula e ponto decimal', () {
    expect(parseDecimal('1.234,50'), 1234.5);
    expect(parseDecimal('1,234.50'), 1234.5);
    expect(parseDecimal('12,5'), 12.5);
    expect(parseDecimal('inválido'), isNull);
  });
}
