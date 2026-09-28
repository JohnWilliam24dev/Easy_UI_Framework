import 'package:flutter/foundation.dart' show immutable;

/// Categorias de tamanho de tela.
enum ScreenSize { mobile, tablet, desktop }

/// Breakpoints nomeados e a faixa usada na interpolação suave.
@immutable
class Breakpoints {
  const Breakpoints({
    this.tabletMin = 600,
    this.desktopMin = 1024,
    this.interpolationStart = 360,
    this.interpolationEnd = 1440,
  })  : assert(tabletMin > 0, 'tabletMin deve ser > 0.'),
        assert(tabletMin < desktopMin, 'tabletMin deve ser < desktopMin.'),
        assert(
          interpolationStart < interpolationEnd,
          'interpolationStart deve ser < interpolationEnd.',
        );

  /// Valores padrão do framework.
  static const Breakpoints standard = Breakpoints();

  /// Menor largura (inclusive) considerada tablet.
  final double tabletMin;

  /// Menor largura (inclusive) considerada desktop.
  final double desktopMin;

  /// Largura em que a interpolação ainda devolve o valor "mínimo"
  /// (ex: `minCell` do Grid). Abaixo dela o valor fica fixo.
  final double interpolationStart;

  /// Largura em que a interpolação já devolve o valor "máximo"
  /// (ex: `maxCell` do Grid). Acima dela o valor fica fixo.
  final double interpolationEnd;

  /// Classifica uma largura em [ScreenSize].
  ScreenSize sizeFor(double width) {
    if (width >= desktopMin) return ScreenSize.desktop;
    if (width >= tabletMin) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  @override
  bool operator ==(Object other) =>
      other is Breakpoints &&
      other.tabletMin == tabletMin &&
      other.desktopMin == desktopMin &&
      other.interpolationStart == interpolationStart &&
      other.interpolationEnd == interpolationEnd;

  @override
  int get hashCode => Object.hash(
        tabletMin,
        desktopMin,
        interpolationStart,
        interpolationEnd,
      );
}
