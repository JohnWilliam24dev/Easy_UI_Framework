import 'package:flutter/widgets.dart';

import '../display/label.dart';

/// Link sem dependência de navegador: o app recebe [url] e decide como abri-la
/// em [onOpen] (por exemplo, com seu adaptador de plataforma).
class Link extends StatelessWidget {
  const Link({super.key, required this.text, required this.url, this.onOpen});

  final String text;
  final String url;
  final ValueChanged<String>? onOpen;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onOpen == null ? null : () => onOpen!(url),
    child: DefaultTextStyle.merge(
      style: const TextStyle(decoration: TextDecoration.underline),
      child: Label(text: text, color: (tokens) => tokens.primaryColor),
    ),
  );
}
