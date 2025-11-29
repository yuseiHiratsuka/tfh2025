import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rive/rive.dart';
import 'package:tfh2025/components/background.dart';
import 'package:tfh2025/services/providers/firebase_providers.dart';
import 'package:tfh2025/services/repositories/auth_repository.dart';
import 'package:tfh2025/services/repositories/participant_repository.dart';

final _roomStreamProvider =
    StreamProvider.family<DocumentSnapshot<Map<String, dynamic>>, String>(
  (ref, roomId) {
    final firestore = ref.watch(firebaseFirestoreProvider);
    return firestore.collection('rooms').doc(roomId).snapshots();
  },
);

class ReadyWaitingRoomPage extends ConsumerStatefulWidget {
  const ReadyWaitingRoomPage({
    required this.roomId,
    super.key,
  });

  final String roomId;

  @override
  ConsumerState<ReadyWaitingRoomPage> createState() =>
      _ReadyWaitingRoomPageState();
}

class _ReadyWaitingRoomPageState extends ConsumerState<ReadyWaitingRoomPage> {
  bool _hasNavigatedToGame = false;
  File? _riveFile;
  RiveWidgetController? _controller;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(authRepositoryProvider).signInAnonymouslyIfNeeded(),
    );
    _loadRiveFile();
  }

  Future<void> _loadRiveFile() async {
    _riveFile = await File.asset(
      'assets/rive/character.riv',
      riveFactory: Factory.rive,
    );
    if (_riveFile != null) {
      _controller = RiveWidgetController(_riveFile!);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _riveFile?.dispose();
    super.dispose();
  }

  /// 準備を解除してお題提示画面に戻る
  Future<void> _cancelReady() async {
    try {
      await ref.read(participantRepositoryProvider).setReadyStatus(
            roomId: widget.roomId,
            isReady: false,
          );
      if (mounted) {
        context.go('/theme_presentation/${widget.roomId}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('準備解除に失敗しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roomAsync = ref.watch(_roomStreamProvider(widget.roomId));

    // ルームステータスがplayingになったらゲーム開始画面へ
    roomAsync.whenData((room) {
      final status = room.data()?['status'] as String?;
      if (status == 'playing' && !_hasNavigatedToGame && mounted) {
        _hasNavigatedToGame = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go('/game_start/${widget.roomId}');
          }
        });
      }
    });

    return Scaffold(
      body: Background(
        child: SafeArea(
          child: Column(
            children: [
              // ヘッダー
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _cancelReady,
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '準備完了',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ルームID: ${widget.roomId}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Riveアニメーション
              Expanded(
                child: _controller == null
                    ? const Center(child: CircularProgressIndicator())
                    : RiveWidget(
                        controller: _controller!,
                      ),
              ),

              // 説明テキスト
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      '他のプレイヤーの準備完了を待っています...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
