import 'package:flutter/widgets.dart';

import '../../kernel/kernel.dart';
import '../layout/tela.dart';
import '../display/card.dart';
import '../display/label.dart';

/// Estrutura responsiva compartilhada por login, cadastro e recuperação.
class AuthPage extends StatelessWidget {
  const AuthPage({
    super.key,
    required this.title,
    required this.form,
    this.subtitle,
    this.footer,
    this.onBack,
    this.brand,
    this.background,
  });
  final String title;
  final Widget form;
  final String? subtitle;
  final Widget? footer, brand, background;
  final VoidCallback? onBack;
  @override
  Widget build(BuildContext context) => Tela(
    scrollable: true,
    onBack: onBack,
    background: background,
    maxWidth: 460.px,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (brand != null) Center(child: brand!),
        const SizedBox(height: 24),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Label(type: LabelType.title, text: title),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Label(type: LabelType.caption, text: subtitle!),
              ],
              const SizedBox(height: 24),
              form,
            ],
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(child: footer!),
          ),
      ],
    ),
  );
}
