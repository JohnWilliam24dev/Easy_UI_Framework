import 'package:easy_ui/src/theme_layer/tokens/tokens.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _light = ThemeTokens(
  primaryColor: Color(0xFF2196F3),
  secondaryColor: Color(0xFF00BFA5),
  backgroundColor: Color(0xFFFFFFFF),
  textColor: Color(0xDD000000),
);

const _dark = ThemeTokens(
  primaryColor: Color(0xFF90CAF9),
  secondaryColor: Color(0xFF64FFDA),
  backgroundColor: Color(0xFF121212),
  textColor: Color(0xFFFFFFFF),
  onPrimaryColor: Color(0xFF000000),
);

/// Monta um AppThemeScope e devolve os tokens vistos por um filho.
Widget _host({
  required AppTheme theme,
  Brightness platform = Brightness.light,
  required ValueChanged<ThemeTokens> onTokens,
  ValueChanged<Brightness>? onBrightness,
}) {
  return MediaQuery(
    data: MediaQueryData(platformBrightness: platform),
    child: AppThemeScope(
      theme: theme,
      child: Builder(
        builder: (context) {
          onTokens(AppThemeScope.tokensOf(context));
          onBrightness?.call(AppThemeScope.brightnessOf(context));
          return const SizedBox();
        },
      ),
    ),
  );
}

void main() {
  group('ThemeTokens', () {
    test('valores opcionais têm fallback documentado', () {
      expect(_light.surfaceColor, _light.backgroundColor);
      expect(_light.mutedTextColor, _light.textColor.withValues(alpha: 0.6));
      expect(_light.onPrimaryColor, const Color(0xFFFFFFFF));
      expect(_light.borderColor, _light.textColor.withValues(alpha: 0.2));
      expect(_light.baseSpacing, 8);
      expect(_light.baseFontSize, 14);
      expect(_light.fontFamily, isNull);
    });

    test('valores explícitos sobrescrevem o fallback', () {
      expect(_dark.onPrimaryColor, const Color(0xFF000000));
      const custom = ThemeTokens(
        primaryColor: Color(0xFF000001),
        secondaryColor: Color(0xFF000002),
        backgroundColor: Color(0xFF000003),
        textColor: Color(0xFF000004),
        surfaceColor: Color(0xFF000005),
      );
      expect(custom.surfaceColor, const Color(0xFF000005));
    });

    test('copyWith troca só o que foi pedido', () {
      final copia = _light.copyWith(primaryColor: const Color(0xFFFF0000));
      expect(copia.primaryColor, const Color(0xFFFF0000));
      expect(copia.secondaryColor, _light.secondaryColor);
      expect(copia.surfaceColor, _light.backgroundColor);
    });

    test('igualdade por valor', () {
      expect(_light.copyWith(), _light);
      expect(_light.copyWith().hashCode, _light.hashCode);
      expect(_light, isNot(_dark));
    });
  });

  group('AppTheme', () {
    const tema = AppTheme(light: _light, dark: _dark);

    test('tokensFor escolhe pelo brilho', () {
      expect(tema.tokensFor(Brightness.light), _light);
      expect(tema.tokensFor(Brightness.dark), _dark);
    });

    test('resolveBrightness respeita o modo', () {
      expect(tema.mode, AppThemeMode.system);
      expect(tema.resolveBrightness(Brightness.dark), Brightness.dark);

      const claro = AppTheme(
        light: _light,
        dark: _dark,
        mode: AppThemeMode.light,
      );
      expect(claro.resolveBrightness(Brightness.dark), Brightness.light);

      const escuro = AppTheme(
        light: _light,
        dark: _dark,
        mode: AppThemeMode.dark,
      );
      expect(escuro.resolveBrightness(Brightness.light), Brightness.dark);
    });
  });

  group('AppThemeScope', () {
    testWidgets('modo system segue a plataforma e reage a mudanças',
        (tester) async {
      const tema = AppTheme(light: _light, dark: _dark);
      ThemeTokens? visto;

      await tester.pumpWidget(
        _host(theme: tema, platform: Brightness.dark, onTokens: (t) => visto = t),
      );
      expect(visto, _dark);

      await tester.pumpWidget(
        _host(theme: tema, platform: Brightness.light, onTokens: (t) => visto = t),
      );
      expect(visto, _light);
    });

    testWidgets('modo fixo ignora a plataforma', (tester) async {
      const tema = AppTheme(
        light: _light,
        dark: _dark,
        mode: AppThemeMode.light,
      );
      ThemeTokens? visto;
      Brightness? brilho;

      await tester.pumpWidget(
        _host(
          theme: tema,
          platform: Brightness.dark,
          onTokens: (t) => visto = t,
          onBrightness: (b) => brilho = b,
        ),
      );
      expect(visto, _light);
      expect(brilho, Brightness.light);
    });

    testWidgets('trocar o AppTheme atualiza os filhos', (tester) async {
      ThemeTokens? visto;
      await tester.pumpWidget(
        _host(
          theme: const AppTheme(
            light: _light,
            dark: _dark,
            mode: AppThemeMode.light,
          ),
          onTokens: (t) => visto = t,
        ),
      );
      expect(visto, _light);

      await tester.pumpWidget(
        _host(
          theme: const AppTheme(
            light: _light,
            dark: _dark,
            mode: AppThemeMode.dark,
          ),
          onTokens: (t) => visto = t,
        ),
      );
      expect(visto, _dark);
    });

    testWidgets('sem AppThemeScope lança FlutterError', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            AppThemeScope.tokensOf(context);
            return const SizedBox();
          },
        ),
      );
      expect(tester.takeException(), isA<FlutterError>());
    });
  });
}
