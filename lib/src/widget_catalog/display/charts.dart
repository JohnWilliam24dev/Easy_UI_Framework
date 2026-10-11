import 'package:flutter/widgets.dart';

import '../../theme_layer/theme_layer.dart';
import 'card.dart';
import 'label.dart';

class ChartValue {
  const ChartValue(this.label, this.value);
  final String label;
  final num value;
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.value});
  final double value;
  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 8,
        child: Stack(
          children: [
            ColoredBox(color: tokens.inputColor),
            FractionallySizedBox(
              widthFactor: value.clamp(0, 1),
              child: ColoredBox(color: tokens.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}

class BarChart extends StatelessWidget {
  const BarChart({super.key, required this.values});
  final List<ChartValue> values;
  @override
  Widget build(BuildContext context) {
    final highest = values.fold<num>(
      0,
      (current, item) => item.value > current ? item.value : current,
    );
    return Column(
      children: [
        for (final item in values)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  child: Label(type: LabelType.caption, text: item.label),
                ),
                Expanded(
                  child: ProgressBar(
                    value: highest == 0 ? 0 : item.value / highest,
                  ),
                ),
                const SizedBox(width: 8),
                Label(type: LabelType.caption, text: item.value.toString()),
              ],
            ),
          ),
      ],
    );
  }
}

class Legend extends StatelessWidget {
  const Legend({super.key, required this.values});
  final List<ChartValue> values;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 12,
    runSpacing: 6,
    children: [
      for (final value in values)
        Label(type: LabelType.caption, text: '${value.label}: ${value.value}'),
    ],
  );
}

class DonutChart extends StatelessWidget {
  const DonutChart({super.key, required this.values});
  final List<ChartValue> values;
  @override
  Widget build(BuildContext context) {
    final total = values.fold<num>(0, (sum, item) => sum + item.value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Label(type: LabelType.heading, text: total.toString()),
        const SizedBox(height: 8),
        Legend(values: values),
      ],
    );
  }
}

class ChartCard extends StatelessWidget {
  const ChartCard({super.key, required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Label(type: LabelType.heading, text: title),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}
