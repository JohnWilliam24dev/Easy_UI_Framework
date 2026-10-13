import 'package:flutter/widgets.dart';

import '../../theme_layer/theme_layer.dart';

/// Entrada suave com deslocamento vertical. A duração e curva vêm do pack.
class Reveal extends StatefulWidget {
  const Reveal({super.key, required this.child, this.delay = Duration.zero});
  final Widget child;
  final Duration delay;

  static Widget stagger({required List<Widget> children, Duration? step}) {
    return Builder(
      builder: (context) {
        final interval = step ?? StylePackScope.of(context).motion.stagger;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < children.length; index++)
              Reveal(delay: interval * index, child: children[index]),
          ],
        );
      },
    );
  }

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final motion = StylePackScope.of(context).motion;
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: motion.duration,
      curve: motion.curve,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, .08),
        duration: motion.duration,
        curve: motion.curve,
        child: widget.child,
      ),
    );
  }
}
