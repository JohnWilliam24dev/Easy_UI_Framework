import 'package:flutter/widgets.dart';

import 'toast.dart';

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
  } catch (_) {
    rollback();
    if (context.mounted) Toast.error(context, text: errorMessage);
    return false;
  }
}
