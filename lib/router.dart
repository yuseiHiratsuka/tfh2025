import 'package:go_router/go_router.dart';
import 'package:tfh2025/pages/canvas_page.dart';
import 'package:tfh2025/pages/final_result_page.dart';
import 'package:tfh2025/pages/game_start_page.dart';
import 'package:tfh2025/pages/judging_page.dart';
import 'package:tfh2025/pages/password_page.dart';
import 'package:tfh2025/pages/room_entry_page.dart';
import 'package:tfh2025/pages/theme_presentation_page.dart';
import 'package:tfh2025/pages/top_page.dart';
import 'package:tfh2025/pages/waiting_room_page.dart';

final router = GoRouter(
  initialLocation: '/top',
  routes: [
    GoRoute(
      path: '/top',
      builder: (context, state) => const TopPage(),
    ),
    GoRoute(
      path: '/room_entry',
      builder: (context, state) => const RoomEntryPage(),
    ),
    GoRoute(
      path: '/password',
      builder: (context, state) => PasswordPage(
        isCreateMode: state.uri.queryParameters['create'] == 'true',
      ),
    ),
    GoRoute(
      path: '/waiting_room/:roomId',
      builder: (context, state) => WaitingRoomPage(
        roomId: state.pathParameters['roomId']!,
        password: state.uri.queryParameters['password']!,
      ),
    ),
    GoRoute(
      path: '/theme_presentation/:roomId',
      builder: (context, state) => ThemePresentationPage(
        roomId: state.pathParameters['roomId']!,
      ),
    ),
    GoRoute(
      path: '/game_start/:roomId',
      builder: (context, state) => GameStartPage(
        roomId: state.pathParameters['roomId']!,
      ),
    ),
    GoRoute(
      path: '/canvas',
      builder: (context, state) => CanvasPage(
        roomId: state.uri.queryParameters['roomId'],
      ),
    ),
    GoRoute(
      path: '/judging',
      builder: (context, state) => const JudgingPage(),
    ),
    GoRoute(
      path: '/final_result/:roomId',
      builder: (context, state) => FinalResultPage(
        roomId: state.pathParameters['roomId']!,
      ),
    ),
  ],
);
