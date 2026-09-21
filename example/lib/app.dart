import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart';

import 'routes.dart';
import 'theme/example_theme.dart';
import 'theme/style_packs.dart';

/// Raiz do app de exemplo: tema explícito, pack do cliente como padrão e a
/// tela de login como início.
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return EasyApp(
      title: 'Easy UI',
      theme: exampleTheme,
      stylePack: clientePack,
      home: Builder(builder: buildLoginScreen),
    );
  }
}
