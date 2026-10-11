import 'package:flutter/material.dart'
    show DefaultTabController, Tab, TabBar, TabBarView;
import 'package:flutter/widgets.dart';

import '../../theme_layer/theme_layer.dart';

/// Uma aba declarativa de [Tabs].
class TabItem {
  const TabItem({required this.label, required this.child});
  final String label;
  final Widget child;
}

/// Abas com ciclo de vida do controlador mantido pelo framework.
class Tabs extends StatelessWidget {
  const Tabs({super.key, required this.items});
  final List<TabItem> items;

  @override
  Widget build(BuildContext context) {
    assert(items.isNotEmpty, 'Tabs exige ao menos uma aba.');
    final tokens = AppThemeScope.tokensOf(context);
    return DefaultTabController(
      length: items.length,
      child: Column(
        children: [
          TabBar(
            tabs: [for (final item in items) Tab(text: item.label)],
            labelColor: tokens.primaryColor,
            unselectedLabelColor: tokens.mutedTextColor,
            indicatorColor: tokens.primaryColor,
          ),
          Expanded(child: TabBarView(children: [for (final item in items) item.child])),
        ],
      ),
    );
  }
}
