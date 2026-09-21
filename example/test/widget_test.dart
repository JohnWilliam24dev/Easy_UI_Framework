import 'package:easy_ui/easy_ui.dart';
import 'package:easy_ui_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tela de login monta só com a API do catálogo', (tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.byType(Label), findsOneWidget);
    expect(find.byType(InputField), findsNWidgets(2));
    expect(find.byType(Button), findsOneWidget);
    expect(find.text('Login'), findsNWidgets(2)); // título + botão
  });
}
