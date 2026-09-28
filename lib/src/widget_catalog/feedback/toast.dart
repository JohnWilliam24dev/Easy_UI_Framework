import 'package:flutter/material.dart' show ScaffoldMessenger, ScaffoldFeatureController, SnackBar, SnackBarClosedReason;
import 'package:flutter/widgets.dart' hide Icon;

import '../../kernel/kernel.dart';
import '../../theme_layer/theme_layer.dart';
import '../display/icon.dart';
import '../layout/div.dart';

/// Papel semântico (e cor) de um [Toast].
enum ToastType { success, error, warning, info }

/// Aviso temporário sobre o conteúdo da tela: SnackBar/overlay, pintado com
/// os tokens do tema.
///
/// Diferente dos demais widgets do catálogo, `Toast` não é inserido na
/// árvore — é disparado a partir de um `BuildContext`:
///
/// ```dart
/// Toast.show(context, text: 'Pedido salvo', type: ToastType.success);
/// ```
abstract final class Toast {
  /// Mostra o toast e devolve um controller (útil para aguardar o
  /// fechamento ou fechar manualmente com `.close()`).
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context, {
    required String text,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    final tokens = AppThemeScope.tokensOf(context);
    final background = switch (type) {
      ToastType.success => tokens.successColor,
      ToastType.error => tokens.errorColor,
      ToastType.warning => tokens.warningColor,
      ToastType.info => tokens.infoColor,
    };
    final iconData = switch (type) {
      ToastType.success => _checkCircle,
      ToastType.error => _errorCircle,
      ToastType.warning => _warningIcon,
      ToastType.info => _infoIcon,
    };

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    return messenger.showSnackBar(
      SnackBar(
        backgroundColor: background,
        duration: duration,
        content: Div(
          direction: LayoutDirection.horizontal,
          align: Alignment.centerLeft,
          gap: 8.px,
          children: [
            Icon(iconData, color: (t) => t.onPrimaryColor),
            LayoutItem(
              size: 1.fr,
              // Fundo é sempre uma cor sólida de status (não a superfície do
              // tema), então o texto usa onPrimaryColor para contraste —
              // Label não serve aqui, pois sua cor é fixa por LabelType.
              child: Text(
                text,
                style: TextStyle(
                  color: tokens.onPrimaryColor,
                  fontSize: tokens.baseFontSize,
                  fontFamily: tokens.fontFamily,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Ícones do Material por código, para o Toast não depender de
// `material.dart` inteiro (só do enum IconData, que vem de widgets.dart).
const IconData _checkCircle = IconData(0xe86c, fontFamily: 'MaterialIcons');
const IconData _errorCircle = IconData(0xe000, fontFamily: 'MaterialIcons');
const IconData _warningIcon = IconData(0xe002, fontFamily: 'MaterialIcons');
const IconData _infoIcon = IconData(0xe88e, fontFamily: 'MaterialIcons');
