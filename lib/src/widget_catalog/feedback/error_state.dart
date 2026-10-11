import 'package:flutter/widgets.dart';

import '../actions/button.dart';
import '../display/label.dart';

/// Estado de falha reutilizável com ação opcional de tentativa novamente.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.title = 'Não foi possível carregar',
    this.description,
    this.onRetry,
  });

  final String title;
  final String? description;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Label(type: LabelType.error, text: title, textAlign: TextAlign.center),
        if (description != null) ...[
          const SizedBox(height: 6),
          Label(
            type: LabelType.caption,
            text: description!,
            textAlign: TextAlign.center,
          ),
        ],
        if (onRetry != null) ...[
          const SizedBox(height: 12),
          Button(
            text: 'Tentar de novo',
            variant: ButtonVariant.outline,
            onPressed: onRetry,
          ),
        ],
      ],
    ),
  );
}
