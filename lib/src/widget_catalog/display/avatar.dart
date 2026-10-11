import 'package:flutter/widgets.dart';

import '../../theme_layer/theme_layer.dart';

/// Tamanho de um [Avatar].
enum AvatarSize {
  sm(28),
  md(40),
  lg(56);

  const AvatarSize(this.diameter);

  final double diameter;
}

/// Avatar circular: uma imagem, ou, na ausência dela (ou em caso de falha ao
/// carregar), as iniciais de [name] sobre um fundo derivado do tema.
///
/// ```dart
/// Avatar(name: 'Maria Silva')
/// Avatar(name: 'Maria Silva', imageUrl: cliente.fotoUrl, size: AvatarSize.lg)
/// ```
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    this.name = '',
    this.initials,
    this.imageUrl,
    this.size = AvatarSize.md,
    this.diameter,
    this.color,
  });

  final String name;
  final String? initials;
  final String? imageUrl;
  final AvatarSize size;
  final double? diameter;
  final Color Function(ThemeTokens tokens)? color;

  static String initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final letters = parts.take(2).map((p) => p[0].toUpperCase());
    final initials = letters.join();
    return initials.isEmpty ? '?' : initials;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    final diameter = this.diameter ?? size.diameter;
    final url = imageUrl;

    Widget fallback = Center(
      child: Text(
        initials ?? initialsOf(name),
        style: TextStyle(
          color: tokens.onPrimaryColor,
          fontSize: diameter * 0.4,
          fontWeight: FontWeight.w600,
          fontFamily: tokens.fontFamily,
        ),
      ),
    );

    return ClipOval(
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: ColoredBox(
          color: color?.call(tokens) ?? tokens.accentColor,
          child: url == null
              ? fallback
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => fallback,
                  loadingBuilder: (context, child, progress) {
                    return progress == null ? child : fallback;
                  },
                ),
        ),
      ),
    );
  }
}
