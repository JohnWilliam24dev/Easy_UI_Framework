import 'package:flutter/widgets.dart';

import '../../theme_layer/theme_layer.dart';
import '../actions/button.dart';
import '../display/label.dart';

/// Busca uma página de dados. Deve devolver menos de [limit] itens quando
/// não houver mais páginas (o `DataList` usa isso para saber quando parar).
typedef DataSource<T> = Future<List<T>> Function(int page, int limit);

/// Listagem simples (não tabular), com paginação **server-side por padrão**:
/// pede só a fatia de dados necessária, em vez de carregar tudo de uma vez.
/// Evita reescrever o widget quando a base crescer (1000, 5000, 10000
/// registros).
///
/// - [limit]: itens por página. Padrão: 50;
/// - conforme o usuário rola até perto do fim, a próxima página é buscada
///   automaticamente;
/// - para quando uma página devolve menos itens que [limit].
///
/// ```dart
/// DataList<Pedido>(
///   source: (page, limit) => api.pedidos(page: page, limit: limit),
///   itemBuilder: (context, pedido) => Card(child: Label(text: pedido.titulo)),
/// )
/// ```
class DataList<T> extends StatefulWidget {
  const DataList({
    super.key,
    required this.source,
    required this.itemBuilder,
    this.limit = 50,
    this.emptyBuilder,
    this.separatorBuilder,
  }) : assert(limit > 0, 'limit deve ser > 0.');

  final DataSource<T> source;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final int limit;

  /// Conteúdo exibido quando a primeira página vem vazia.
  final WidgetBuilder? emptyBuilder;

  /// Separador entre itens (ex: `Divider()`). Sem separador por padrão.
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  @override
  State<DataList<T>> createState() => _DataListState<T>();
}

class _DataListState<T> extends State<DataList<T>> {
  final List<T> _items = <T>[];
  int _page = 0;
  bool _loading = false;
  bool _hasMore = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadNextPage();
  }

  Future<void> _loadNextPage() async {
    if (_loading || !_hasMore) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await widget.source(_page, widget.limit);
      if (!mounted) return;
      setState(() {
        _items.addAll(page);
        _hasMore = page.length >= widget.limit;
        _page++;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    const threshold = 300.0;
    if (notification.metrics.extentAfter < threshold) {
      _loadNextPage();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);

    if (_items.isEmpty) {
      if (_loading) return const Center(child: CircularProgressIndicator());
      if (_error != null) return _ErrorState(error: _error!, onRetry: _loadNextPage);
      return widget.emptyBuilder?.call(context) ??
          Center(
            child: Label(type: LabelType.caption, text: 'Nenhum item encontrado'),
          );
    }

    final hasFooter = _loading || _error != null;

    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: ListView.separated(
        itemCount: _items.length + (hasFooter ? 1 : 0),
        separatorBuilder: (context, index) {
          if (index >= _items.length - 1) return const SizedBox.shrink();
          return widget.separatorBuilder?.call(context, index) ??
              const SizedBox.shrink();
        },
        itemBuilder: (context, index) {
          if (index < _items.length) {
            return widget.itemBuilder(context, _items[index]);
          }
          if (_error != null) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: _ErrorState(error: _error!, onRetry: _loadNextPage),
            );
          }
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Label(type: LabelType.error, text: 'Não foi possível carregar'),
          const SizedBox(height: 8),
          Button(text: 'Tentar de novo', variant: ButtonVariant.outline, onPressed: onRetry),
        ],
      ),
    );
  }
}
