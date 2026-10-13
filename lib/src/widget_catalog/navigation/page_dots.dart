import 'package:flutter/widgets.dart';

import '../../theme_layer/theme_layer.dart';

/// Indicador reativo para um [PageController].
class PageDots extends AnimatedWidget {
  const PageDots({super.key, required PageController controller, required this.count}) : super(listenable: controller);
  final int count;
  PageController get _controller => listenable as PageController;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    final active = _controller.hasClients ? (_controller.page ?? _controller.initialPage).round() : _controller.initialPage;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < count; index++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: index == active ? 18 : 7,
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(color: index == active ? tokens.primaryColor : tokens.borderColor, borderRadius: BorderRadius.circular(99)),
          ),
      ],
    );
  }
}
