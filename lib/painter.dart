import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';
import 'package:image/image.dart' as img;

/// flutter_painter_v2 の最小限のサンプル。
class PainterPage extends StatefulWidget {
  const PainterPage({
    super.key,
    this.controller,
    this.timerFactory,
    this.captureBytesOverride,
    this.renderBoxResolver,
  });

  /// テスト用に外部から注入できる [PainterController]。
  final PainterController? controller;

  /// テスト用のタイマー生成フック。
  final Timer Function(Duration duration, void Function())? timerFactory;

  /// 画像バイト列生成を差し替えるフック。
  final Future<Uint8List> Function(Size size)? captureBytesOverride;

  /// RenderBox 解決を差し替えるフック。
  final RenderBox? Function()? renderBoxResolver;

  @override
  State<PainterPage> createState() => _PainterPageState();
}

class _PainterPageState extends State<PainterPage> {
  Timer? _launchTimer;
  late final PainterController _controller;
  late final Future<Uint8List> Function(Size size) _captureBytesImpl;
  static const _palette = <Color>[
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        PainterController(
          settings: const PainterSettings(
            freeStyle: FreeStyleSettings(
              mode: FreeStyleMode.draw,
              strokeWidth: 5,
            ),
          ),
          background: const ColorBackgroundDrawable(color: Colors.white),
        );
    _captureBytesImpl =
        widget.captureBytesOverride ?? _captureBytesInternal;
    _launchTimer = (widget.timerFactory ?? Timer.new)(
      const Duration(seconds: 2),
      () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('タイマーが発火しました')),
        );
      },
    );
  }

  @override
  void dispose() {
    _launchTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _setMode(FreeStyleMode mode) {
    _controller.freeStyleSettings =
        _controller.freeStyleSettings.copyWith(mode: mode);
  }

  void _setColor(Color color) {
    _controller.freeStyleSettings = _controller.freeStyleSettings
        .copyWith(color: color, mode: FreeStyleMode.draw);
  }

  void _setStroke(double value) {
    _controller.freeStyleSettings =
        _controller.freeStyleSettings.copyWith(strokeWidth: value);
  }

  Future<Uint8List> _captureBytes(Size size) {
    return _captureBytesImpl(size);
  }

  Future<Uint8List> _captureBytesInternal(Size size) async {
    final image = await _controller.renderImage(size);
    final byteData = await image.toByteData();
    if (byteData == null) {
      throw Exception('JPEG 変換に必要なバッファ取得に失敗しました');
    }
    byteData.buffer.asUint8List();
    final converted = img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: byteData.buffer,
      numChannels: 4,
      order: img.ChannelOrder.rgba,
    );
    return Uint8List.fromList(img.encodeJpg(converted));
  }

  Future<void> _exportImage() async {
    final renderBox = widget.renderBoxResolver != null
        ? widget.renderBoxResolver!()
        : _controller.painterKey.currentContext?.findRenderObject()
            as RenderBox?;
    final size = renderBox?.size ?? const Size(512, 512);
    try {
      final bytes = await _captureBytes(size);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('JPEG でプレビュー'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360, maxHeight: 400),
            child: Image.memory(bytes, fit: BoxFit.contain),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('画像化に失敗しました: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Painter v2'),
        actions: [
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => IconButton(
              tooltip: 'Undo',
              icon: const Icon(Icons.undo),
              onPressed: _controller.canUndo ? _controller.undo : null,
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => IconButton(
              tooltip: 'Redo',
              icon: const Icon(Icons.redo),
              onPressed: _controller.canRedo ? _controller.redo : null,
            ),
          ),
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.delete_outline),
            onPressed: _controller.clearDrawables,
          ),
          IconButton(
            tooltip: 'JPEG でプレビュー',
            icon: const Icon(Icons.image_outlined),
            onPressed: _exportImage,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FlutterPainter(controller: _controller),
                ),
              ),
            ),
          ),
          _PainterControls(
            controller: _controller,
            palette: _palette,
            onModeChanged: _setMode,
            onColorPicked: _setColor,
            onStrokeChanged: _setStroke,
          ),
        ],
      ),
    );
  }
}

class _PainterControls extends StatelessWidget {
  const _PainterControls({
    required this.controller,
    required this.palette,
    required this.onModeChanged,
    required this.onColorPicked,
    required this.onStrokeChanged,
  });

  final PainterController controller;
  final List<Color> palette;
  final ValueChanged<FreeStyleMode> onModeChanged;
  final ValueChanged<Color> onColorPicked;
  final ValueChanged<double> onStrokeChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final settings = controller.freeStyleSettings;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, index) {
                    final color = palette[index];
                    final isSelected = settings.color == color;
                    return InkResponse(
                      onTap: () => onColorPicked(color),
                      radius: 24,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: color,
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemCount: palette.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
