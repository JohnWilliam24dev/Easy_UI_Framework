import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/material.dart' show MaterialPageRoute;
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

/// Pack da área operacional do ERP: campos com linha, botão baixo e denso.
final StylePack _erpPack = StylePack.define(
  name: 'erp_operacional',
  inputText: const InputStyleSpec.underline(),
  button: const ButtonStyleSpec.compact(),
  label: const LabelStyleSpec.compact(),
  spacingScale: 0.8,
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

/// Regras de validação do login (devolvem a mensagem de erro, ou null).
String? validarUsername(String valor) {
  return valor.trim().length > 3 ? null : 'Use mais de 3 caracteres';
}

String? validarSenha(String valor) {
  return valor.length >= 8 ? null : 'A senha precisa de 8 caracteres ou mais';
}

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

/// Tela de login de referência (seção 9 da documentação), agora validando.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _username = '';
  String _password = '';

  bool get _valido =>
      validarUsername(_username) == null && validarSenha(_password) == null;

  void _entrar() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => HomePage(username: _username)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tela(
      child: Div(
        position: LayoutPosition.center,
        align: Alignment.center,
        width: 50.vw,
        children: [
          const Label(type: LabelType.title, text: 'Login'),
          InputField(
            hint: 'Username',
            type: InputType.text,
            validator: validarUsername,
            onChanged: (valor) => setState(() => _username = valor),
          ),
          InputField(
            hint: 'Password',
            type: InputType.password,
            validator: validarSenha,
            onChanged: (valor) => setState(() => _password = valor),
          ),
          Button(
            text: 'Login',
            variant: ButtonVariant.solid,
            onPressed: _valido ? _entrar : null,
          ),
        ],
      ),
    );
  }
}

/// Próxima tela: os mesmos widgets em dois "estilos" diferentes, só trocando
/// o StylePack da subárvore.
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.username});

  final String username;

  void _sair(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tela(
      scrollable: true,
      child: Div(
        children: [
          Div(
            direction: LayoutDirection.horizontal,
            align: Alignment.centerLeft,
            children: [
              // 1.fr: o título ocupa todo o espaço que sobra ao lado do botão.
              LayoutItem(
                size: 1.fr,
                child: Label(type: LabelType.title, text: 'Olá, $username'),
              ),
              Button(
                text: 'Sair',
                variant: ButtonVariant.ghost,
                onPressed: () => _sair(context),
              ),
            ],
          ),
          const Label(
            type: LabelType.caption,
            text: 'Os dois painéis usam exatamente os mesmos widgets. '
                'Só o StylePack da subárvore muda.',
          ),
          StylePackScope(
            pack: _clientePack,
            child: const _Painel(titulo: 'Área do cliente'),
          ),
          StylePackScope(
            pack: _erpPack,
            child: const _Painel(titulo: 'Área operacional (ERP)'),
          ),
        ],
      ),
    );
  }
}

class _Painel extends StatelessWidget {
  const _Painel({required this.titulo});

  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Div(
      children: [
        Label(type: LabelType.subtitle, text: titulo),
        const InputField(hint: 'Buscar pedido', type: InputType.search),
        Div(
          direction: LayoutDirection.horizontal,
          children: [
            Button(text: 'Salvar', onPressed: () {}),
            Button(
              text: 'Cancelar',
              variant: ButtonVariant.outline,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}
