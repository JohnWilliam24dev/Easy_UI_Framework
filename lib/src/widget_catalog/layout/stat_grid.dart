import 'package:flutter/widgets.dart';

import '../display/card.dart';
import '../display/stat.dart';
import 'grid.dart';

/// Grade responsiva para métricas: duas colunas compactas e quatro amplas.
class StatGrid extends StatelessWidget {
  const StatGrid({super.key, required this.items});
  final List<Stat> items;

  @override
  Widget build(BuildContext context) {
    return Grid(
      minCell: 2,
      maxCell: 4,
      cellRatio: 1.35,
      children: [for (final item in items) Card(child: item)],
    );
  }
}
