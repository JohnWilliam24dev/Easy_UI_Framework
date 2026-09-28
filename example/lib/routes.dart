import 'package:flutter/material.dart' show MaterialPageRoute;
import 'package:flutter/widgets.dart';

import 'screens/home/home_page.dart';
import 'screens/login/login_page.dart';
import 'screens/orders/orders_page.dart';

/// Navegação do exemplo. As telas não se conhecem: cada uma recebe daqui os
/// callbacks para ir à próxima.
Widget buildLoginScreen(BuildContext context) {
  return LoginPage(
    onLogin: (username) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: _homeBuilder(username)),
      );
    },
  );
}

WidgetBuilder _homeBuilder(String username) {
  return (context) {
    return HomePage(
      username: username,
      onLogout: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: buildLoginScreen),
        );
      },
      onOpenOrders: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: _ordersBuilder),
        );
      },
    );
  };
}

Widget _ordersBuilder(BuildContext context) {
  return OrdersPage(onBack: () => Navigator.of(context).pop());
}
