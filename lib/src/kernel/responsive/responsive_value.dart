import 'package:flutter/foundation.dart' show immutable;

import 'breakpoints.dart';

/// Um valor que muda conforme o [ScreenSize].
///
/// Tablet cai para mobile e desktop cai para tablet (e depois mobile) quando
/// não declarados.
///
/// ```dart
/// const ResponsiveValue(mobile: 1, desktop: 3)
/// ```
@immutable
class ResponsiveValue<T> {
  const ResponsiveValue({required this.mobile, this.tablet, this.desktop});

  final T mobile;
  final T? tablet;
  final T? desktop;

  T resolve(ScreenSize size) {
    switch (size) {
      case ScreenSize.mobile:
        return mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}
