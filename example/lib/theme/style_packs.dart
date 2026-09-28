import 'package:easy_ui/easy_ui.dart';

/// Pack da área do cliente: campos arredondados, botão em pílula e mais ar.
final StylePack clientePack = StylePack.define(
  name: 'cliente_convidativo',
  inputText: const InputStyleSpec.rounded(
    radius: 16,
    elevation: ElevationLevel.subtle,
  ),
  button: const ButtonStyleSpec.pill(),
  spacingScale: 1.2,
);

/// Pack da área operacional do ERP: campos com linha, botão baixo e denso.
final StylePack erpPack = StylePack.define(
  name: 'erp_operacional',
  inputText: const InputStyleSpec.underline(),
  button: const ButtonStyleSpec.compact(),
  label: const LabelStyleSpec.compact(),
  spacingScale: 0.8,
);
