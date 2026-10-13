import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Brightness;

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
  bool _syncingSystemBrightness = false;

  AppThemeMode get mode => value;

  set mode(AppThemeMode next) {
    if (value == next) return;
    value = next;
    final nextDark = next == AppThemeMode.dark;
    if (darkMode.value != nextDark) darkMode.value = nextDark;
  }

  void _syncFromDarkMode() {
    if (_syncingSystemBrightness) return;
    mode = darkMode.value ? AppThemeMode.dark : AppThemeMode.light;
  }

  /// Mantém o adaptador booleano fiel ao tema efetivo enquanto [mode] segue
  /// o sistema. Chamado por [EasyApp] depois que o `MediaQuery` existe.
  void syncSystemBrightness(Brightness brightness) {
    if (mode != AppThemeMode.system) return;
    final isDark = brightness == Brightness.dark;
    if (darkMode.value == isDark) return;
    _syncingSystemBrightness = true;
    darkMode.value = isDark;
    _syncingSystemBrightness = false;
  }

  void useSystem() => mode = AppThemeMode.system;

  @override
  void dispose() {
    darkMode.removeListener(_syncFromDarkMode);
    darkMode.dispose();
    super.dispose();
  }
}
