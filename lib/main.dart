import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rive_native/rive_native.dart' as rive;
import 'package:tfh2025/components/loading_overlay.dart';
import 'package:tfh2025/theme/app_theme.dart';

import 'firebase_options.dart';
import 'router.dart';
import 'services/repositories/test_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await rive.RiveNative.init();

  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({this.testRepository, super.key});

  final TestRepository? testRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, child) {
        return LoadingOverlay(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: child,
          ),
        );
      },
    );
  }
}
