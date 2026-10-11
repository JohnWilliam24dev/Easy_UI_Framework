import 'package:flutter/foundation.dart';

import 'app_theme.dart';

/// Estado observável do modo de tema, sem depender de armazenamento ou de
/// widgets. O app pode persistir [mode] onde preferir e restaurá-lo no
/// construtor.
class AppThemeController extends ValueNotifier<AppThemeMode> {
  AppThemeController({AppThemeMode initial = AppThemeMode.system})
    : darkMode = ValueNotifier(initial == AppThemeMode.dark),
      super(initial) {
    darkMode.addListener(_syncFromDarkMode);
  }

  /// Adaptador prático para controles booleanos. Ativar seleciona escuro;
  /// desativar seleciona claro (não volta automaticamente a `system`).
  final ValueNotifier<bool> darkMode;

  AppThemeMode get mode => value;

  set mode(AppThemeMode next) {
    if (value == next) return;
    value = next;
    final nextDark = next == AppThemeMode.dark;
    if (darkMode.value != nextDark) darkMode.value = nextDark;
  }

  void _syncFromDarkMode() =>
      mode = darkMode.value ? AppThemeMode.dark : AppThemeMode.light;

  void useSystem() => mode = AppThemeMode.system;

  @override
  void dispose() {
    darkMode.removeListener(_syncFromDarkMode);
    darkMode.dispose();
    super.dispose();
  }
}
