import 'package:easy_ui/src/widget_catalog/app/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

const _destinos = [
  NavDestination(id: 'inicio', label: 'Início', icon: Icons.home),
  NavDestination(id: 'pedidos', label: 'Pedidos', icon: Icons.list),
];

Widget _shell({
  required ValueChanged<String> onSelect,
  String selectedId = 'inicio',
}) {
  return AppShell(
    destinations: _destinos,
    selectedId: selectedId,
    onSelect: onSelect,
    title: 'Painel',
    subtitle: 'Resumo do dia',
    brand: const Text('Marca'),
    headerActions: const [Text('ação')],
    profileMenu: const Text('perfil'),
    footer: const Text('rodapé'),
    child: const Text('conteúdo'),
  );
}

void main() {
  group('tela larga', () {
    testWidgets('mostra barra lateral, cabeçalho e conteúdo', (tester) async {
      await pumpEasy(tester, _shell(onSelect: (_) {}));

      expect(find.byIcon(Icons.menu), findsNothing);
      expect(find.text('Início'), findsOneWidget);
      expect(find.text('Pedidos'), findsOneWidget);
      expect(find.text('Marca'), findsOneWidget);
      expect(find.text('Painel'), findsOneWidget);
      expect(find.text('Resumo do dia'), findsOneWidget);
      expect(find.text('ação'), findsOneWidget);
      expect(find.text('perfil'), findsOneWidget);
      expect(find.text('rodapé'), findsOneWidget);
      expect(find.text('conteúdo'), findsOneWidget);
    });

    testWidgets('marca o destino selecionado e avisa ao tocar em outro',
        (tester) async {
      String? escolhido;
      await pumpEasy(
        tester,
        _shell(onSelect: (id) => escolhido = id, selectedId: 'pedidos'),
      );
      final tiles = tester.widgetList<ListTile>(find.byType(ListTile));
      expect(tiles.map((tile) => tile.selected), [false, true]);

      await tester.tap(find.text('Início'));
      await tester.pump();

      expect(escolhido, 'inicio');
    });

    testWidgets('recolher esconde rótulos e a marca', (tester) async {
      await pumpEasy(tester, _shell(onSelect: (_) {}));

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      expect(find.text('Início'), findsNothing);
      expect(find.text('Marca'), findsNothing);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(find.text('Início'), findsOneWidget);
    });
  });

  group('tela estreita', () {
    testWidgets('usa drawer aberto pelo botão de menu', (tester) async {
      await pumpEasy(
        tester,
        _shell(onSelect: (_) {}),
        size: const Size(400, 800),
      );
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.text('Pedidos'), findsNothing);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Pedidos'), findsOneWidget);
    });

    testWidgets('escolher um destino avisa e fecha o drawer', (tester) async {
      String? escolhido;
      await pumpEasy(
        tester,
        _shell(onSelect: (id) => escolhido = id),
        size: const Size(400, 800),
      );
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pedidos'));
      await tester.pumpAndSettle();

      expect(escolhido, 'pedidos');
      expect(find.text('Pedidos'), findsNothing);
    });
  });
}
