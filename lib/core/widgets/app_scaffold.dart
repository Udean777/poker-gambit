import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppScaffold extends StatefulWidget {
  final Widget body;
  final Color? backgroundColor;
  final BoxDecoration? decoration;
  final bool safeTop;
  final bool safeBottom;
  final bool safeLeft;
  final bool safeRight;

  const AppScaffold({
    super.key,
    required this.body,
    this.backgroundColor,
    this.decoration,
    this.safeTop = true,
    this.safeBottom = true,
    this.safeLeft = true,
    this.safeRight = true,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = widget.body;

    if (widget.safeTop || widget.safeBottom || widget.safeLeft || widget.safeRight) {
      content = SafeArea(
        top: widget.safeTop,
        bottom: widget.safeBottom,
        left: widget.safeLeft,
        right: widget.safeRight,
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: widget.decoration != null
          ? Container(decoration: widget.decoration, child: content)
          : content,
    );
  }
}
