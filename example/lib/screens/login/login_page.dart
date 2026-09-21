import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart';

import 'login_validators.dart';

/// Tela de login de referência (seção 9 da documentação), com validação.
///
/// Não conhece a próxima tela: avisa quem a usa por [onLogin].
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onLogin});

  /// Chamado com o username quando o usuário confirma um login válido.
  final ValueChanged<String> onLogin;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _username = '';
  String _password = '';

  bool get _valido =>
      validarUsername(_username) == null && validarSenha(_password) == null;

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
            onPressed: _valido ? () => widget.onLogin(_username) : null,
          ),
        ],
      ),
    );
  }
}
