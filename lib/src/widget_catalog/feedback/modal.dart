import 'package:flutter/material.dart' show Colors, Dialog, showDialog;
import 'package:flutter/widgets.dart';

import '../../kernel/kernel.dart';
import '../actions/button.dart';
import '../display/card.dart';
import '../display/label.dart';
import '../layout/div.dart';

/// Caixa de diálogo modal: `showDialog` + `AlertDialog`, pintada com os
/// tokens e a aparência do `StylePack` ativo (via `Card`/`Button`
/// internamente).
///
/// Três formas de uso:
///
/// ```dart
/// final apagar = await Modal.confirm(
///   context,
///   title: 'Excluir pedido?',
///   message: 'Esta ação não pode ser desfeita.',
///   confirmText: 'Excluir',
/// );
///
/// await Modal.alert(context, title: 'Pedido salvo');
///
/// final resultado = await Modal.custom<String>(
///   context,
///   builder: (context) => MeuConteudo(),
/// );
/// ```
abstract final class Modal {
  /// Pergunta e devolve `true` (confirmou), `false` (cancelou) ou `null`
  /// (fechou sem escolher, ex: tocando fora).
  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    String? message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => _ModalShell(
        title: title,
        message: message,
        actions: [
          Button(
            text: cancelText,
            variant: ButtonVariant.ghost,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          Button(
            text: confirmText,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
  }

  /// Mostra uma mensagem com um único botão de confirmação.
  static Future<void> alert(
    BuildContext context, {
    required String title,
    String? message,
    String okText = 'OK',
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => _ModalShell(
        title: title,
        message: message,
        actions: [
          Button(text: okText, onPressed: () => Navigator.of(dialogContext).pop()),
        ],
      ),
    );
  }

  /// Conteúdo livre dentro do mesmo invólucro visual (`Card` + largura
  /// fixa). Quem constrói o conteúdo decide como fechar o diálogo (ex:
  /// `Navigator.of(context).pop(valor)`).
  static Future<T?> custom<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Card(child: builder(dialogContext)),
        );
      },
    );
  }
}

class _ModalShell extends StatelessWidget {
  const _ModalShell({required this.title, this.message, required this.actions});

  final String title;
  final String? message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Card(
        child: Div(
          width: 320.px,
          children: [
            Label(type: LabelType.subtitle, text: title),
            if (message != null) Label(type: LabelType.body, text: message!),
            Div(
              direction: LayoutDirection.horizontal,
              position: LayoutPosition.right,
              gap: 8.px,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}
