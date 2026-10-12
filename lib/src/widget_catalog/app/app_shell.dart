import 'package:flutter/material.dart';

import '../../kernel/kernel.dart'
    show Breakpoints, ResponsiveResolver, ScreenSize;
import '../../theme_layer/theme_layer.dart';

const _shellResolver = ResponsiveResolver(
  breakpoints: Breakpoints(tabletMin: 760, desktopMin: 761),
);

class NavDestination {
  const NavDestination({
    required this.id,
    required this.label,
    required this.icon,
  });
  final String id;
  final String label;
  final IconData icon;
}

/// Casca responsiva de aplicações autenticadas, com drawer compacto em telas
/// pequenas e barra lateral recolhível nas demais.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.destinations,
    required this.selectedId,
    required this.onSelect,
    required this.child,
    this.title,
    this.subtitle,
    this.brand,
    this.headerActions = const [],
    this.profileMenu,
    this.footer,
  });
  final List<NavDestination> destinations;
  final String selectedId;
  final ValueChanged<String> onSelect;
  final Widget child;
  final String? title, subtitle;
  final Widget? brand, profileMenu, footer;
  final List<Widget> headerActions;
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _collapsed = false;
  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    final spec = StylePackScope.of(context).nav;
    final compact = _shellResolver.sizeOf(context) == ScreenSize.mobile;
    final nav = _Navigation(
      widget: widget,
      collapsed: _collapsed,
      onToggle: () => setState(() => _collapsed = !_collapsed),
    );
    return Scaffold(
      drawer: compact ? Drawer(child: nav) : null,
      backgroundColor: tokens.backgroundColor,
      body: Row(
        children: [
          if (!compact)
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: _collapsed ? spec.collapsedWidth : spec.expandedWidth,
              child: nav,
            ),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (compact)
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.title != null)
                              Text(
                                widget.title!,
                                style: TextStyle(
                                  color: tokens.headingColor,
                                  fontSize: tokens.baseFontSize * 1.4,
                                ),
                              ),
                            if (widget.subtitle != null)
                              Text(
                                widget.subtitle!,
                                style: TextStyle(color: tokens.mutedTextColor),
                              ),
                          ],
                        ),
                      ),
                      ...widget.headerActions,
                      if (widget.profileMenu != null) widget.profileMenu!,
                    ],
                  ),
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Navigation extends StatelessWidget {
  const _Navigation({
    required this.widget,
    required this.collapsed,
    required this.onToggle,
  });
  final AppShell widget;
  final bool collapsed;
  final VoidCallback onToggle;
  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    return ColoredBox(
      color: tokens.surfaceColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: collapsed
                      ? const SizedBox()
                      : (widget.brand ?? const SizedBox()),
                ),
                IconButton(
                  icon: Icon(
                    collapsed ? Icons.chevron_right : Icons.chevron_left,
                  ),
                  onPressed: onToggle,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                for (final item in widget.destinations)
                  ListTile(
                    leading: Icon(item.icon),
                    title: collapsed ? null : Text(item.label),
                    selected: item.id == widget.selectedId,
                    onTap: () {
                      widget.onSelect(item.id);
                      if (Scaffold.of(context).isDrawerOpen) {
                        Navigator.pop(context);
                      }
                    },
                  ),
              ],
            ),
          ),
          if (widget.footer != null) widget.footer!,
        ],
      ),
    );
  }
}
