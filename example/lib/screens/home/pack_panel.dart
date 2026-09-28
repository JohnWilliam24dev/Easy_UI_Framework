import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

/// Painel de demonstração: sempre os mesmos widgets. A aparência muda só
/// conforme o `StylePack` ativo na subárvore onde ele é colocado.
class PackPanel extends StatelessWidget {
  const PackPanel({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Div(
      children: [
        Label(type: LabelType.subtitle, text: title),
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
