// ignore: file_names
class PendingNotificationService {
  PendingNotificationService._();

  static String? _pendingRoute;

  static void setPending(String route) {
    _pendingRoute = route;
  }

  static String? consumePending() {
    final route = _pendingRoute;
    _pendingRoute = null;
    return route;
  }

  static bool get hasPending => _pendingRoute != null;
}

