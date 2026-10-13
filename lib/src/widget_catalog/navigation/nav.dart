import 'package:flutter/material.dart' show MaterialPageRoute;
import 'package:flutter/widgets.dart';

/// Navegação imperativa mínima, isolando `MaterialPageRoute` das telas.
abstract final class Nav {
  static Future<T?> push<T>(BuildContext context, Widget page) => Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page));
  static Future<T?> replace<T, TO>(BuildContext context, Widget page) => Navigator.of(context).pushReplacement<T, TO>(MaterialPageRoute(builder: (_) => page));
  static Future<T?> reset<T>(BuildContext context, Widget page) => Navigator.of(context).pushAndRemoveUntil<T>(MaterialPageRoute(builder: (_) => page), (_) => false);
}
