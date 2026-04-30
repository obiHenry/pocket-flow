import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final bool enableRefresh;
  final Future<void> Function()? onRefresh;
  final Color? backgroundColor;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.enableRefresh = false,
    this.onRefresh,
    this.backgroundColor,
  }) : assert(
         !enableRefresh || onRefresh != null,
         'onRefresh must be provided when enableRefresh is true',
       );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      backgroundColor: backgroundColor,
      body: enableRefresh
          ? RefreshIndicator(
              onRefresh: onRefresh!,
              child: body,
            )
          : body,
    );
  }
}
