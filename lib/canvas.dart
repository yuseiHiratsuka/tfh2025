import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';
import 'package:image/image.dart' as img;

/// flutter_painter_v2 の最小限のサンプル。
class CanvasPage extends StatefulWidget {
  const CanvasPage({super.key});

  @override
  State<CanvasPage> createState() => _CanvasPageState();
}

class _CanvasPageState extends State<CanvasPage> {
  Timer? _launchTimer;
  late final PainterController _controller;
  static const _goalTopic = 'きつねうどん';
  static const _currentTopic = 'ミャクミャク';
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
    _controller = PainterController(
      settings: const PainterSettings(
        freeStyle: FreeStyleSettings(
          mode: FreeStyleMode.draw,
          strokeWidth: 5,
        ),
      ),
      background: const ColorBackgroundDrawable(color: Colors.white),
    );
    _launchTimer = Timer(
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

  void _onClearCanvas() {
    _controller.clearDrawables();
    if (!mounted) return;
  }

  Future<Uint8List> _captureBytes(Size size) async {
    final image = await _controller.renderImage(size);
    final byteData = await image.toByteData();
    if (byteData == null) {
      throw Exception('JPEG 変換に必要なバッファ取得に失敗しました');
    }
    final rgbaBytes = byteData.buffer.asUint8List();
    final converted = img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: rgbaBytes.buffer,
      numChannels: 4,
      order: img.ChannelOrder.rgba,
    );
    return Uint8List.fromList(img.encodeJpg(converted));
  }

  Future<void> _exportImage() async {
    final renderBox =
        _controller.painterKey.currentContext?.findRenderObject() as RenderBox?;
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFBE2BBF), Color(0xFF2CB2E5)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              const Row(
                children: [
                  Expanded(
                    child: _InfoChip(
                      label: 'ゴールのお題',
                      value: _goalTopic,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _InfoChip(
                      label: '制限時間',
                      value: 'あと１２０秒',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                '現在のお題',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
              ),
              const SizedBox(height: 8),
              const _TopicCard(value: _currentTopic),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _onClearCanvas,
                  child: const Text('キャンパスをクリア'),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF2E207A),
                      width: 6,
                    ),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FlutterPainter(controller: _controller),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _PainterControls(
                controller: _controller,
                palette: _palette,
                onModeChanged: _setMode,
                onColorPicked: _setColor,
                onStrokeChanged: _setStroke,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 64,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text(
                    'けってい！',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF8A1B8D),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF8A1B8D),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 32,
            letterSpacing: 2,
          ),
        ),
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
