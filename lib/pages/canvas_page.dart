import 'dart:async';
import 'dart:math' as math;

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:rive/rive.dart';
import 'package:tfh2025/components/background.dart';
import 'package:tfh2025/models/room.dart';
import 'package:tfh2025/models/submission.dart';
import 'package:tfh2025/services/providers/submission_providers.dart';
import 'package:tfh2025/services/repositories/auth_repository.dart';
import 'package:tfh2025/services/repositories/participant_repository.dart';
import 'package:tfh2025/services/repositories/room_repository.dart';
import 'package:tfh2025/services/repositories/submission_repository.dart';
import 'package:tfh2025/utils/rive_support.dart';

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
  final cacheStrategy = AsyncCache<void>.ephemeral();

  Timer? _countdownTimer;
  static const _initialSeconds = 120;
  int _secondsLeft = _initialSeconds;
  late final PainterController _controller;
  bool _isSubmitting = false;
  Room? _lastRoom;
  bool _isCanvasInteracting = false;
  File? _buttonRiveFile;
  RiveWidgetController? _buttonController;
  String? _lastCurrentCharacter;
  bool _riveEnabled = isRiveSupported;
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
    if (_riveEnabled) {
      _loadButtonRiveFile();
    }
  }

  Future<void> _loadButtonRiveFile() async {
    final riveFile = await loadRiveFileIfSupported('assets/rive/button.riv');
    if (!mounted) return;
    if (riveFile == null) {
      setState(() {
        _riveEnabled = false;
      });
      return;
    }
    _buttonRiveFile = riveFile;
    _buttonController = RiveWidgetController(_buttonRiveFile!);
    setState(() {});
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller.dispose();
    _buttonController?.dispose();
    _buttonRiveFile?.dispose();
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
    HapticFeedback.heavyImpact();
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
      await ref.read(submissionRepositoryProvider).submitImageBytes(
            roomId: roomId,
            displayName: displayName,
            rawBytes: captured,
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
      return const Scaffold(
        body: Background(
          child: Center(
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

          _lastCurrentCharacter = room?.currentCharacter;
        });
      },
    );

    // 全てのsubmissionsを監視してダイアログを表示（採用・不採用両方）
    ref.listen<AsyncValue<List<Submission>>>(
      allSubmissionsStreamProvider(roomId),
      (previous, next) {
        // 初回読み込みではダイアログを表示しない
        if (previous == null) return;

        next.whenData((submissions) {
          previous.whenData((prevSubmissions) {
            // 新しい投稿が追加された場合のみ
            if (submissions.length > prevSubmissions.length) {
              final newSubmission = submissions.last;
              final aiResult = newSubmission.aiResult;
              final validation = newSubmission.validation;

              debugPrint(
                '[CanvasPage] 新しい投稿を検出: id=${newSubmission.id}, aiResult=$aiResult, validation=$validation',
              );

              // aiResultが存在する場合のみダイアログを表示
              // validation は採用・不採用どちらの場合も存在する
              if (aiResult != null) {
                // Room情報を取得（不正解時のお題表示のため）
                final roomAsync = ref.read(roomStreamProvider(roomId));
                roomAsync.whenData((room) {
                  final currentCharacter = room?.currentCharacter;

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      showGeneralDialog<void>(
                        context: context,
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            ScaleTransition(
                          scale: animation,
                          child: Center(
                            child: _Dialog(
                              submission: newSubmission,
                              requiredCharacter: currentCharacter,
                            ),
                          ),
                        ),
                      );
                    }
                  });
                });
              }
            }
          });
        });
      },
    );

    final roomAsync = ref.watch(roomStreamProvider(roomId));

    return Scaffold(
      body: Background(
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

              // 初回のみ_lastCurrentCharacterを設定
              _lastCurrentCharacter ??= room.currentCharacter;
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
    final previousDrawing = room.usedWords.isEmpty ? '-' : room.usedWords.last;

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
                  horizontal: 20,
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
                Expanded(
                  child: controls,
                ),
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
        const SizedBox(height: 26),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildSubmitButton() {
    if (_riveEnabled && _buttonController != null) {
      return GestureDetector(
        onTap: _isSubmitting
            ? null
            : () async {
                await AsyncCache<void>.ephemeral().fetch(() async {
                  await _submitDrawing();
                });
              },
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: RiveWidget(
            controller: _buttonController!,
            fit: Fit.cover,
          ),
        ),
      );
    }

    if (_riveEnabled) {
      return const SizedBox(
        width: double.infinity,
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitDrawing,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          '送信する',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
    final theme = Theme.of(context);
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color:
                theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              '前の絵：$previousDrawing',
              style: const TextStyle(
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
                  reverse: true,
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

class _Dialog extends StatefulWidget {
  const _Dialog({
    required this.submission,
    this.requiredCharacter,
  });

  final Submission submission;
  final String? requiredCharacter;

  @override
  State<_Dialog> createState() => _DialogState();
}

class _DialogState extends State<_Dialog> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final aiResult = widget.submission.aiResult;
    final validation = widget.submission.validation;
    final isGoalReached = validation?.isGoalReached ?? false;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Background(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 上部：AIの判定
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.secondary,
                        width: 2,
                      ),
                      color: theme.colorScheme.primary,
                    ),
                    child: const Center(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/images/robot.png'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AIの判定',
                          style: theme.textTheme.bodyMedium,
                        ),
                        if (aiResult != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainer
                                  .withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              aiResult.word,
                              style: theme.textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 画像表示部分
              if (widget.submission.imageUrl.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF2E207A),
                      width: 6,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.submission.imageUrl,
                          height: 300,
                          width: 300,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(
                            height: 300,
                            width: 300,
                            child: Icon(Icons.error, size: 48),
                          ),
                        ),
                      ),
                      Image(
                        width: 280,
                        height: 280,
                        image: AssetImage(
                          validation?.isAdopted == true
                              ? 'assets/images/circle.png'
                              : 'assets/images/cross.png',
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              // 下部：メッセージ
              Column(
                children: [
                  if (validation?.isAdopted == true) ...[
                    Text(
                      isGoalReached ? 'ゴールに到達しました！' : '絵がお題にあっています！',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (aiResult != null && !isGoalReached)
                      Text(
                        '次のお題は " ${aiResult.lastChar} " です！',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ] else ...[
                    if (validation?.reason != null)
                      Text(
                        validation!.reason!,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                  ],
                  const SizedBox(height: 16),
                  // とじるボタン
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2E207A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(
                            color: Color(0xFF2E207A),
                            width: 3,
                          ),
                        ),
                      ),
                      child: const Text(
                        'とじる',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
