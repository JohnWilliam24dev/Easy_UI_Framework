import 'dart:async';

import 'package:flutter/material.dart'
    show Colors, Dialog, showDialog, showModalBottomSheet;
import 'package:flutter/widgets.dart';

import '../../kernel/kernel.dart';
import '../actions/button.dart';
import '../display/card.dart';
import '../display/label.dart';
import '../display/list_item.dart';
import '../layout/div.dart';
import '../inputs/form/form_group.dart';
import '../inputs/form/validators.dart';
import '../inputs/input_field.dart';

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
    bool destructive = false,
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
            variant: destructive ? ButtonVariant.danger : ButtonVariant.solid,
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
          Button(
            text: okText,
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
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

  /// Modal de edição que cria o [FormGroup] e mantém as ações no mesmo
  /// escopo dos campos, portanto o botão Salvar sempre valida antes do envio.
  static Future<T?> form<T>(
    BuildContext context, {
    required String title,
    required List<Widget> Function(BuildContext context) fields,
    required FutureOr<T?> Function(FormValues values) onSubmit,
    Map<String, Object?> initialValues = const <String, Object?>{},
    String cancelText = 'Cancelar',
    String saveText = 'Salvar',
  }) => showDialog<T>(
    context: context,
    builder: (dialogContext) => _ModalShell(
      title: title,
      content: FormGroup(
        initialValues: initialValues,
        onSubmit: (values) async {
          final result = await onSubmit(values);
          if (dialogContext.mounted) Navigator.of(dialogContext).pop(result);
        },
        children: [
          ...fields(dialogContext),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            children: [
              Button(
                text: cancelText,
                variant: ButtonVariant.ghost,
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              Button(text: saveText),
            ],
          ),
        ],
      ),
      actions: const [],
    ),
  );

  /// Pede um texto usando o mesmo fluxo validado de [form].
  static Future<String?> prompt(
    BuildContext context, {
    required String title,
    String? label,
    String? hint,
    String? initialValue,
    List<Validator> validation = const <Validator>[],
    String confirmText = 'Confirmar',
  }) => form<String>(
    context,
    title: title,
    saveText: confirmText,
    initialValues: {'value': initialValue},
    fields: (_) => [
      InputField(
        name: 'value',
        label: label,
        hint: hint,
        validation: validation,
      ),
    ],
    onSubmit: (values) => values.string('value'),
  );

  /// Escolhe um item sem expor `SimpleDialog` ao aplicativo.
  static Future<T?> choice<T>(
    BuildContext context, {
    required String title,
    required List<ModalChoice<T>> choices,
    T? selected,
  }) => showDialog<T>(
    context: context,
    builder: (dialogContext) => _ModalShell(
      title: title,
      actions: const [],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final choice in choices)
            ListItem(
              title: choice.label,
              subtitle: choice.description,
              selected: choice.value == selected,
              onTap: () => Navigator.of(dialogContext).pop(choice.value),
            ),
        ],
      ),
    ),
  );

  /// Exibe conteúdo como bottom sheet, adequado para ações em telas pequenas.
  static Future<T?> sheet<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool isScrollControlled = true,
  }) => showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    builder: (sheetContext) => AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
      child: SafeArea(top: false, child: builder(sheetContext)),
    ),
  );

  /// Escolhe o formato com a largura do pai; a consulta de layout fica no
  /// Kernel, por meio de [Responsive].
  static Future<T?> adaptive<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    double sheetBelow = 600,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    return width < sheetBelow
        ? sheet<T>(context, builder: builder)
        : custom<T>(context, builder: builder);
  }
}

class ModalChoice<T> {
  const ModalChoice(this.value, this.label, {this.description});
  final T value;
  final String label;
  final String? description;
}

class _ModalShell extends StatelessWidget {
  const _ModalShell({
    required this.title,
    this.message,
    this.content,
    required this.actions,
  });

  final String title;
  final String? message;
  final Widget? content;
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
            ?content,
            // Wrap, não Div/Row: com textos maiores (localização, fonte
            // maior por acessibilidade) os botões quebram linha em vez de
            // estourar a largura fixa do modal.
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}
