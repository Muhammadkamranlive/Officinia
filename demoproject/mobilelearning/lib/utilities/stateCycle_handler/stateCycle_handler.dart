import 'package:flutter/material.dart';
import 'package:mobile_onboarding/screens/blankScreen/blankScreen.dart';

class LifecycleWatcher extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const LifecycleWatcher(
      {required this.child, required this.navigatorKey, Key? key})
      : super(key: key);

  @override
  _LifecycleWatcherState createState() => _LifecycleWatcherState();
}

class _LifecycleWatcherState extends State<LifecycleWatcher>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive) {
      print(state);
      widget.navigatorKey.currentState?.pushNamed(BlankScreen.routeName);
    } else if (state == AppLifecycleState.resumed) {
      print(state);
      widget.navigatorKey.currentState
          ?.popUntil((route) => route.settings.name != BlankScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
