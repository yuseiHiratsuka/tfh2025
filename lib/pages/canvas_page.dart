import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:tfh2025/models/room.dart';
import 'package:tfh2025/services/repositories/auth_repository.dart';
import 'package:tfh2025/services/repositories/participant_repository.dart';
import 'package:tfh2025/services/repositories/room_repository.dart';
import 'package:tfh2025/services/repositories/submission_repository.dart';

/// flutter_painter_v2 の最小限のサンプル。
class CanvasPage extends ConsumerStatefulWidget {
  const CanvasPage({
    this.roomId,
    super.key,
  });

  final String? roomId;

  @override
  ConsumerState<CanvasPage> createState() => _CanvasPageState();
}

class _CanvasPageState extends ConsumerState<CanvasPage> {
  Timer? _countdownTimer;
  static const _initialSeconds = 120;
  int _secondsLeft = _initialSeconds;
  late final PainterController _controller;
  bool _isSubmitting = false;
  Room? _lastRoom;
  bool _isCanvasInteracting = false;
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
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _secondsLeft = _initialSeconds;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          timer.cancel();
        }
      });
    });
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

  Size _getCanvasSize() {
    final renderBox =
        _controller.painterKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size ?? const Size(512, 512);
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

  //ignore: unused_element
  Future<void> _exportImage() async {
    try {
      final size = _getCanvasSize();
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

  Future<String> _resolveDisplayName(String roomId) async {
    final authRepository = ref.read(authRepositoryProvider);
    final user = await authRepository.signInAnonymouslyIfNeeded();

    try {
      final participants = await ref
          .read(participantsStreamProvider(roomId).future)
          .timeout(const Duration(seconds: 3));

      for (final participant in participants) {
        if (participant.userId == user.uid) {
          return participant.displayName;
        }
      }
    } catch (e) {
      //todo 削除
      // タイムアウトまたはエラーの場合は仮データで参加登録（モック用）
      final participantRepository = ref.read(participantRepositoryProvider);
      final newParticipant = await participantRepository.joinRoom(
        roomId: roomId,
        displayName: 'テストユーザー',
      );
      return newParticipant.displayName;
    }

    // 参加者が見つからない場合は仮データで参加登録（モック用）
    final participantRepository = ref.read(participantRepositoryProvider);
    final newParticipant = await participantRepository.joinRoom(
      roomId: roomId,
      displayName: 'テストユーザー',
    );
    return newParticipant.displayName;
  }

  Future<void> _submitDrawing() async {
    if (_isSubmitting) return;

    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('roomId が指定されていません。ルーム参加後にお試しください。'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final size = _getCanvasSize();
      final captured = await _captureBytes(size);
      final displayName = await _resolveDisplayName(roomId);
      final submissionId =
          await ref.read(submissionRepositoryProvider).submitImageBytes(
                roomId: roomId,
                displayName: displayName,
                rawBytes: captured,
              );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('送信しました (id: $submissionId)')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('送信に失敗しました: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomId = widget.roomId;
    if (roomId == null || roomId.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFBE2BBF), Color(0xFF2CB2E5)],
            ),
          ),
          child: const Center(
            child: Text(
              'ルームIDが指定されていません',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    // ルームステータスを監視してゴール画面へ自動遷移
    ref.listen<AsyncValue<Room?>>(
      roomStreamProvider(roomId),
      (previous, next) {
        next.whenData((room) {
          if (room != null &&
              (room.status == RoomStatus.success ||
                  room.status == RoomStatus.failed)) {
            // ゴール到達または失敗時に最終結果画面へ遷移
            context.go('/final_result/$roomId');
          }
        });
      },
    );

    final roomAsync = ref.watch(roomStreamProvider(roomId));

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
          child: roomAsync.when(
            data: (room) {
              if (room == null) {
                return const Center(
                  child: Text(
                    'ルームが見つかりません',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              _lastRoom = room;
              return _buildRoomContent(room);
            },
            loading: () {
              final fallback = _lastRoom;
              if (fallback != null) {
                return _buildRoomContent(fallback);
              }
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            },
            error: (error, stack) {
              final fallback = _lastRoom;
              if (fallback != null) {
                return _buildRoomContent(fallback);
              }
              return const Center(
                child: Text(
                  'エラーが発生しました。時間をおいて再度お試しください。',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRoomContent(Room room) {
    final goalTopic = room.goalCharacter;
    final currentTopic = room.currentCharacter;
    final previousDrawing =
        room.usedWords.isEmpty ? 'スタート' : room.usedWords.last;

    return ListView(
      physics: _isCanvasInteracting
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _InfoChip(
                label: 'ゴールのお題',
                value: goalTopic,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: _InfoChip(
                  label: '制限時間',
                  value: 'あと$_secondsLeft秒',
                  leading: const CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage('assets/images/robot.png'),
                  ),
                ),
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
        _TopicCard(
          value: currentTopic,
          previousDrawing: previousDrawing,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final controls = _PainterControls(
              controller: _controller,
              palette: _palette,
              onModeChanged: _setMode,
              onColorPicked: _setColor,
              onStrokeChanged: _setStroke,
            );
            final clearButton = OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _onClearCanvas,
              child: const Text('キャンバスをクリア'),
            );
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                clearButton,
                Expanded(child: controls),
              ],
            );
          },
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final canvasWidth = math.min(constraints.maxWidth, 520.0);
            return Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: canvasWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
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
                        child: Listener(
                          onPointerDown: (_) =>
                              setState(() => _isCanvasInteracting = true),
                          onPointerUp: (_) =>
                              setState(() => _isCanvasInteracting = false),
                          onPointerCancel: (_) =>
                              setState(() => _isCanvasInteracting = false),
                          child: FlutterPainter(controller: _controller),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitDrawing,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('けってい！'),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
    this.leading,
  });

  final String label;
  final String value;
  final Widget? leading;

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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 10),
              ],
              Flexible(
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
          ),
        ),
      ],
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.value,
    required this.previousDrawing,
  });

  final String value;
  final String previousDrawing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF8A1B8D),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              '前の絵：$previousDrawing',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          Center(
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
                      radius: 26,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        padding: const EdgeInsets.all(3),
                        child: CircleAvatar(
                          backgroundColor: color,
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : null,
                        ),
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
