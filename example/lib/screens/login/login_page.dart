import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart';

/// Tela de login de referência (seção 9 da documentação), com validação.
///
/// Sem estado: o `FormGroup` cuida dos campos e o `Button` de envio valida
/// tudo. Não conhece a próxima tela: avisa quem a usa por [onLogin].
class LoginPage extends StatelessWidget {
  const LoginPage({super.key, required this.onLogin});

  /// Chamado com o username quando o usuário envia um login válido.
  final ValueChanged<String> onLogin;

  @override
  Widget build(BuildContext context) {
    return Tela(
      child: FormGroup(
        position: LayoutPosition.center,
        align: Alignment.center,
        width: 50.vw,
        children: [
          const Label(type: LabelType.title, text: 'Login'),
          InputField(
            name: 'username',
            hint: 'Username',
            validation: [isRequired(), minLength(4)],
          ),
          InputField(
            name: 'password',
            hint: 'Password',
            type: InputType.password,
            validation: [isRequired(), isPassword(min: 8)],
          ),
          Button(
            text: 'Login',
            variant: ButtonVariant.solid,
            onSubmit: (values) => onLogin(values['username']!),
          ),
        ],
      ),
    );
  }
}
