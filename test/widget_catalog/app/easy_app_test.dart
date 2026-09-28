import 'package:easy_ui/src/theme_layer/theme_layer.dart';
import 'package:easy_ui/src/widget_catalog/app/material_bridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_easy.dart';

void main() {
  group('materialThemeFor', () {
    test('usa as cores dos tokens, sem paleta implícita do Material', () {
      final theme = materialThemeFor(testTokens, Brightness.light);
      expect(theme.colorScheme.primary, testTokens.primaryColor);
      expect(theme.colorScheme.onPrimary, testTokens.onPrimaryColor);
      expect(theme.colorScheme.secondary, testTokens.secondaryColor);
      expect(theme.colorScheme.surface, testTokens.surfaceColor);
      expect(theme.colorScheme.onSurface, testTokens.textColor);
      expect(theme.scaffoldBackgroundColor, testTokens.backgroundColor);
      expect(theme.colorScheme.brightness, Brightness.light);
    });

    test('respeita o brilho pedido', () {
      final theme = materialThemeFor(testDarkTokens, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, testDarkTokens.backgroundColor);
    });

    test('materialThemeModeFor traduz os modos', () {
      expect(materialThemeModeFor(AppThemeMode.light), ThemeMode.light);
      expect(materialThemeModeFor(AppThemeMode.dark), ThemeMode.dark);
      expect(materialThemeModeFor(AppThemeMode.system), ThemeMode.system);
    });
  });

  group('EasyApp', () {
    testWidgets('disponibiliza tokens e StylePack para as telas',
        (tester) async {
      const pack = StylePack(name: 'denso', spacingScale: 0.8);
      ThemeTokens? tokens;
      StylePack? visto;

      await pumpEasy(
        tester,
        Builder(
          builder: (context) {
            tokens = AppThemeScope.tokensOf(context);
            visto = StylePackScope.of(context);
            return const SizedBox();
          },
        ),
        pack: pack,
      );

      expect(tokens, testTokens);
      expect(visto, pack);
    });

    testWidgets('sem stylePack usa o standard', (tester) async {
      StylePack? visto;
      await pumpEasy(
        tester,
        Builder(
          builder: (context) {
            visto = StylePackScope.of(context);
            return const SizedBox();
          },
        ),
      );
      expect(visto, same(StylePack.standard));
    });

    testWidgets('modo dark usa os tokens escuros também no Material',
        (tester) async {
      const escuro = AppTheme(
        light: testTokens,
        dark: testDarkTokens,
        mode: AppThemeMode.dark,
      );
      ThemeTokens? tokens;
      Color? primaryDoMaterial;

      await pumpEasy(
        tester,
        Builder(
          builder: (context) {
            tokens = AppThemeScope.tokensOf(context);
            primaryDoMaterial = Theme.of(context).colorScheme.primary;
            return const SizedBox();
          },
        ),
        theme: escuro,
      );

      expect(tokens, testDarkTokens);
      expect(primaryDoMaterial, testDarkTokens.primaryColor);
    });
  });
}
