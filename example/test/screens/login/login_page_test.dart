import 'package:easy_ui/easy_ui.dart';
import 'package:easy_ui_example/screens/login/login_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/helpers.dart';

void main() {
  testWidgets('monta só com a API do catálogo e começa bloqueado',
      (tester) async {
    await tester.pumpWidget(easyHome(LoginPage(onLogin: (_) {})));

    expect(find.byType(Label), findsOneWidget);
    expect(find.byType(InputField), findsNWidgets(2));
    expect(find.byType(Button), findsOneWidget);
    expect(loginHabilitado(tester), isFalse);
    // Nenhum erro aparece antes do usuário digitar.
    expect(find.text('Use mais de 3 caracteres'), findsNothing);
  });

  testWidgets('mostra os erros e mantém o botão bloqueado', (tester) async {
    await tester.pumpWidget(easyHome(LoginPage(onLogin: (_) {})));
    await preencherLogin(tester, username: 'abc', password: '1234567');

    expect(find.text('Use mais de 3 caracteres'), findsOneWidget);
    expect(
      find.text('A senha precisa de 8 caracteres ou mais'),
      findsOneWidget,
    );
    expect(loginHabilitado(tester), isFalse);
  });

  testWidgets('com dados válidos libera o botão e entrega o username',
      (tester) async {
    String? recebido;
    await tester.pumpWidget(easyHome(LoginPage(onLogin: (u) => recebido = u)));
    await preencherLogin(tester, username: 'maria', password: 'senha1234');

    expect(find.text('Use mais de 3 caracteres'), findsNothing);
    expect(loginHabilitado(tester), isTrue);

    await tester.tap(find.byType(Button));
    await tester.pump();
    expect(recebido, 'maria');
  });
}
