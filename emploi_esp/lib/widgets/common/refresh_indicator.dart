import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/api_config.dart';

class AutoRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final bool showIndicator;

  const AutoRefreshIndicator({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.showIndicator = true,
  }) : super(key: key);

  @override
  State<AutoRefreshIndicator> createState() => _AutoRefreshIndicatorState();
}

class _AutoRefreshIndicatorState extends State<AutoRefreshIndicator> {
  Timer? _refreshTimer;
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _setupAutoRefresh();
  }

  void _setupAutoRefresh() {
    _refreshTimer = Timer.periodic(
      Duration(minutes: 1), // Reload every minute
      (_) => _performRefresh(),
    );
  }

  Future<void> _performRefresh() async {
    if (mounted) {
      await widget.onRefresh();
      // If showing indicator, trigger it
      if (widget.showIndicator) {
        _refreshKey.currentState?.show();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: widget.onRefresh,
      color: Theme.of(context).primaryColor,
      backgroundColor: Colors.white,
      displacement: 40,
      strokeWidth: 3,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}