import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_painter_v2/flutter_painter.dart';
import 'package:tfh2025/painter.dart';

class _FakeTimer implements Timer {
  bool cancelled = false;

  @override
  void cancel() {
    cancelled = true;
  }

  @override
  bool get isActive => !cancelled;

  @override
  int get tick => 0;
}

class _SpyPainterController extends PainterController {
  bool disposed = false;

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}

void main() {
  testWidgets('RenderBox取得失敗時はフォールバックサイズでキャプチャする', (tester) async {
    Size? capturedSize;

    await tester.pumpWidget(
      MaterialApp(
        home: PainterPage(
          renderBoxResolver: () => null,
          captureBytesOverride: (size) async {
            capturedSize = size;
            return Uint8List.fromList(
              img.encodeJpg(img.Image(width: 8, height: 8)),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byTooltip('JPEG でプレビュー'));
    await tester.pumpAndSettle();

    expect(capturedSize, const Size(512, 512));
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('キャプチャが失敗した場合はSnackBarで例外を通知する', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PainterPage(
          captureBytesOverride: (_) => throw Exception('boom'),
        ),
      ),
    );

    await tester.tap(find.byTooltip('JPEG でプレビュー'));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('画像化に失敗しました'), findsOneWidget);
    expect(find.textContaining('boom'), findsOneWidget);
  });

  testWidgets('disposeでタイマーとControllerを解放する', (tester) async {
    final controller = _SpyPainterController();
    late _FakeTimer fakeTimer;

    await tester.pumpWidget(
      MaterialApp(
        home: PainterPage(
          controller: controller,
          timerFactory: (_, __) {
            fakeTimer = _FakeTimer();
            return fakeTimer;
          },
        ),
      ),
    );

    await tester.pump();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(fakeTimer.cancelled, isTrue);
    expect(controller.disposed, isTrue);
  });
}
