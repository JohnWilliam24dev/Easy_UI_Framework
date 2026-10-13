import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import '../../theme_layer/theme_layer.dart';
import '../feedback/loader.dart';

/// Imagem remota ou em bytes com carregamento, falha e recorte resolvidos.
class Picture extends StatelessWidget {
  const Picture({
    super.key,
    this.url,
    this.bytes,
    this.radius = 0,
    this.fallback,
    this.fit = BoxFit.cover,
  }) : assert(url != null || bytes != null, 'Informe url ou bytes.');

  final String? url;
  final Uint8List? bytes;
  final double radius;
  final Widget? fallback;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    final placeholder = fallback ??
        ColoredBox(color: tokens.inputColor, child: const Center(child: Loader()));
    final source = bytes != null
        ? Image.memory(bytes!, fit: fit, errorBuilder: (_, _, _) => placeholder)
        : Image.network(
            url!, fit: fit,
            errorBuilder: (_, _, _) => placeholder,
            loadingBuilder: (_, child, progress) => progress == null ? child : placeholder,
          );
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: source);
  }
}
