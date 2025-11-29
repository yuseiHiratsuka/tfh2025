import 'package:go_router/go_router.dart';
import 'package:tfh2025/pages/canvas_page.dart';
import 'package:tfh2025/pages/final_result_page.dart';
import 'package:tfh2025/pages/game_start_page.dart';
import 'package:tfh2025/pages/judging_page.dart';
import 'package:tfh2025/pages/theme_presentation_page.dart';
import 'package:tfh2025/pages/waiting_room_page.dart';

final router = GoRouter(
  initialLocation: '/waiting_room',
  routes: [
    GoRoute(
      path: '/waiting_room',
      builder: (context, state) => const WaitingRoomPage(),
    ),
    GoRoute(
      path: '/theme_presentation',
      builder: (context, state) => const ThemePresentationPage(),
    ),
    GoRoute(
      path: '/game_start',
      builder: (context, state) => const GameStartPage(),
    ),
    GoRoute(
      path: '/canvas',
      builder: (context, state) => const CanvasPage(),
    ),
    GoRoute(
      path: '/judging',
      builder: (context, state) => const JudgingPage(),
    ),
    GoRoute(
      path: '/final_result',
      builder: (context, state) => const FinalResultPage(),
    ),
  ],
);
