import 'package:flutter/widgets.dart';

import 'toast.dart';
import 'user_facing_exception.dart';

/// Executa uma alteração imediatamente e a reverte caso [persist] falhe.
Future<bool> optimistic(
  BuildContext context, {
  required VoidCallback apply,
  required Future<void> Function() persist,
  required VoidCallback rollback,
  String errorMessage = 'Não foi possível salvar a alteração.',
}) async {
  apply();
  try {
    await persist();
    return true;
  } catch (error, stack) {
    var message = errorMessage;
    if (error is UserFacingException) {
      message = error.message;
    } else {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'easy_ui',
          context: ErrorDescription('ao persistir uma alteração otimista'),
        ),
      );
    }
    rollback();
    if (context.mounted) Toast.error(context, text: message);
    return false;
  }
}
