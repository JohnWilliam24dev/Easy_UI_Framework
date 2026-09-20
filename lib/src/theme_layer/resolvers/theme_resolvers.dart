import 'package:flutter/widgets.dart' show BuildContext;

import '../../kernel/kernel.dart';
import '../style_pack/style_pack.dart';
import '../style_pack/style_pack_scope.dart';
import '../tokens/app_theme_scope.dart';
import '../tokens/theme_tokens.dart';

/// Implementação concreta, da Theme Layer, do contrato genérico
/// `StyleResolver` do Kernel: resolve os tokens ativos.
class ThemeTokensResolver implements StyleResolver<ThemeTokens> {
  const ThemeTokensResolver();

  @override
  ThemeTokens resolve(BuildContext context) => AppThemeScope.tokensOf(context);
}

/// Resolve o `StylePack` ativo (ou o padrão, se não houver escopo).
class ActiveStylePackResolver implements StyleResolver<StylePack> {
  const ActiveStylePackResolver();

  @override
  StylePack resolve(BuildContext context) => StylePackScope.of(context);
}
