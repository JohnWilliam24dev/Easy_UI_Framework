import 'package:easy_ui/src/widget_catalog/display/avatar.dart' as easy;
import 'package:easy_ui/src/widget_catalog/layout/tela.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

void main() {
  group('initialsOf', () {
    test('duas palavras: primeira letra de cada', () {
      expect(easy.Avatar.initialsOf('Maria Silva'), 'MS');
    });

    test('uma palavra: só a primeira letra', () {
      expect(easy.Avatar.initialsOf('Maria'), 'M');
    });

    test('mais de duas palavras: usa só as duas primeiras', () {
      expect(easy.Avatar.initialsOf('Maria da Silva Santos'), 'MD');
    });

    test('espaços nas pontas e vazio', () {
      expect(easy.Avatar.initialsOf('  Maria  Silva  '), 'MS');
      expect(easy.Avatar.initialsOf(''), '?');
      expect(easy.Avatar.initialsOf('   '), '?');
    });
  });

  testWidgets('sem imageUrl mostra as iniciais', (tester) async {
    await pumpEasy(tester, const Tela(child: easy.Avatar(name: 'Maria Silva')));
    expect(find.text('MS'), findsOneWidget);
  });

  testWidgets('cada size tem o diâmetro correto', (tester) async {
    for (final size in easy.AvatarSize.values) {
      await pumpEasy(
        tester,
        Tela(child: easy.Avatar(name: 'A', size: size)),
      );
      expect(
        tester.getSize(find.byType(easy.Avatar)),
        Size(size.diameter, size.diameter),
      );
    }
  });

  testWidgets('é recortado em círculo', (tester) async {
    await pumpEasy(tester, const Tela(child: easy.Avatar(name: 'Maria')));
    expect(find.byType(ClipOval), findsOneWidget);
  });
}
