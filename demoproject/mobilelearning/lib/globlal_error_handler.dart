import 'package:flutter/material.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void showError(Object e) {
  final ctx = navigatorKey.currentContext;
  if (ctx == null) return;

  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(content: Text("Services are not working...")),
  );
}
