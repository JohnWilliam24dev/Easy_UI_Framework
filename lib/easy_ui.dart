/// Easy UI: camada declarativa de UI sobre Flutter.
///
/// Este é o único ponto de entrada público do package. Tudo em `src/` é
/// interno; o que o app pode usar é exportado explicitamente aqui.
library;

export 'src/kernel/unit_system/unit_system.dart'
    show Dimension, Fr, Percent, Px, UnitNumExtension, Vh, Vw;
export 'src/kernel/responsive/responsive.dart'
    show Breakpoints, ResponsiveValue, ScreenSize;
export 'src/theme_layer/theme_layer.dart'
    show
        AppTheme,
        AppThemeMode,
        AppThemeScope,
        ButtonStyleSpec,
        CardStyleSpec,
        ElevationLevel,
        InputStyleKind,
        InputStyleSpec,
        LabelStyleSpec,
        StylePack,
        StylePackScope,
        ThemeTokens;
