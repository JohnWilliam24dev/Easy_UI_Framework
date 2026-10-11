import 'package:flutter/widgets.dart';

import 'empty_state.dart';
import 'error_state.dart';
import 'loader.dart';

/// Resolve uma operação assíncrona uma vez por ciclo de vida e oferece
/// loading, erro e recarregamento sem `FutureBuilder` nas telas.
class AsyncView<T> extends StatefulWidget {
  const AsyncView({
    super.key,
    required this.load,
    required this.builder,
    this.loading,
    this.empty,
    this.error,
  });

  final Future<T> Function() load;
  final Widget Function(BuildContext context, T data) builder;
  final Widget? loading;
  final Widget? empty;
  final Widget Function(
    BuildContext context,
    Object error,
    VoidCallback reload,
  )?
  error;

  @override
  State<AsyncView<T>> createState() => _AsyncViewState<T>();
}

class _AsyncViewState<T> extends State<AsyncView<T>> {
  late Future<T> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.load();
  }

  void _reload() => setState(() => _future = widget.load());

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
    future: _future,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return widget.loading ?? const Loader();
      }
      if (snapshot.hasError) {
        return widget.error?.call(context, snapshot.error!, _reload) ??
            ErrorState(onRetry: _reload);
      }
      final data = snapshot.data;
      if (data == null) return widget.empty ?? const EmptyState();
      return widget.builder(context, data);
    },
  );
}
