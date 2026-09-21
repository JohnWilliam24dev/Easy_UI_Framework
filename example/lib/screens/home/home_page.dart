import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart';

import '../../theme/style_packs.dart';
import 'pack_panel.dart';

/// Tela seguinte ao login: os mesmos widgets em dois "estilos", trocando só
/// o `StylePack` da subárvore.
///
/// Não conhece a tela de login: avisa quem a usa por [onLogout].
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.username, required this.onLogout});

  final String username;
  final VoidCallback onLogout;

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
                onPressed: onLogout,
              ),
            ],
          ),
          const Label(
            type: LabelType.caption,
            text: 'Os dois painéis usam exatamente os mesmos widgets. '
                'Só o StylePack da subárvore muda.',
          ),
          StylePackScope(
            pack: clientePack,
            child: const PackPanel(title: 'Área do cliente'),
          ),
          StylePackScope(
            pack: erpPack,
            child: const PackPanel(title: 'Área operacional (ERP)'),
          ),
        ],
      ),
    );
  }
}
