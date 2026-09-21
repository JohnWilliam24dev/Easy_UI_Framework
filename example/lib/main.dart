import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart';

/// Pack da área do cliente: campos arredondados, botão em pílula e mais ar.
final StylePack _clientePack = StylePack.define(
  name: 'cliente_convidativo',
  inputText: const InputStyleSpec.rounded(
    radius: 16,
    elevation: ElevationLevel.subtle,
  ),
  button: const ButtonStyleSpec.pill(),
  spacingScale: 1.2,
);

const AppTheme _tema = AppTheme(
  light: ThemeTokens(
    primaryColor: Color(0xFF2196F3),
    secondaryColor: Color(0xFF00BFA5),
    backgroundColor: Color(0xFFFFFFFF),
    textColor: Color(0xDD000000),
  ),
  dark: ThemeTokens(
    primaryColor: Color(0xFF90CAF9),
    secondaryColor: Color(0xFF64FFDA),
    backgroundColor: Color(0xFF121212),
    textColor: Color(0xFFFFFFFF),
    onPrimaryColor: Color(0xFF000000),
  ),
);

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return EasyApp(
      title: 'Easy UI',
      theme: _tema,
      stylePack: _clientePack,
      home: const LoginPage(),
    );
  }
}

/// Tela de login de referência (seção 9 da documentação).
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Tela(
      child: Div(
        position: LayoutPosition.center,
        align: Alignment.center,
        width: 50.vw,
        children: [
          const Label(type: LabelType.title, text: 'Login'),
          const InputField(hint: 'Username', type: InputType.text),
          const InputField(hint: 'Password', type: InputType.password),
          Button(text: 'Login', variant: ButtonVariant.solid, onPressed: () {}),
        ],
      ),
    );
  }
}
