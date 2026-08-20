import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_strings.dart';

class ImmersiveReader extends StatefulWidget {
  final String title;
  final List<Widget> actions;
  final Widget? drawer;
  final Widget body;
  final Widget? bottom;
  final bool fullscreen;
  final ValueChanged<bool> onFullscreenChanged;
  final Color? backgroundColor;

  const ImmersiveReader({
    super.key,
    required this.title,
    this.actions = const [],
    this.drawer,
    required this.body,
    this.bottom,
    required this.fullscreen,
    required this.onFullscreenChanged,
    this.backgroundColor,
  });

  @override
  State<ImmersiveReader> createState() => _ImmersiveReaderState();
}

class _ImmersiveReaderState extends State<ImmersiveReader>
    with WidgetsBindingObserver {
  bool _chromeVisible = false;

  bool get _immersive => widget.fullscreen && !_chromeVisible;

  bool get _showChrome => !widget.fullscreen || _chromeVisible;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _applySystemUiMode();
  }

  @override
  void didUpdateWidget(ImmersiveReader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fullscreen != widget.fullscreen) {
      _chromeVisible = false;
      _applySystemUiMode();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _applySystemUiMode();
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _applySystemUiMode() {
    SystemChrome.setEnabledSystemUIMode(
      _immersive ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  void _toggleChrome() {
    if (!widget.fullscreen) return;
    setState(() => _chromeVisible = !_chromeVisible);
    _applySystemUiMode();
  }

  @override
  Widget build(BuildContext context) {
    final actions = [
      ...widget.actions,
      IconButton(
        icon: Icon(
          widget.fullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
        ),
        tooltip: widget.fullscreen
            ? AppStrings.exitFullscreen
            : AppStrings.enterFullscreen,
        onPressed: () => widget.onFullscreenChanged(!widget.fullscreen),
      ),
    ];

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      appBar: _showChrome
          ? AppBar(
              title: Text(
                widget.title,
                style: const TextStyle(fontSize: 14),
              ),
              actions: actions,
            )
          : null,
      drawer: widget.drawer,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: widget.body),
              if (widget.bottom != null && _showChrome) widget.bottom!,
            ],
          ),
          if (_immersive)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleChrome,
              ),
            ),
        ],
      ),
    );
  }
}