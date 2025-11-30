import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rive_native/rive_native.dart' as rive;
import 'package:tfh2025/theme/app_theme.dart';
import 'package:tfh2025/utils/rive_support.dart';

import 'firebase_options.dart';
import 'router.dart';
import 'services/repositories/test_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (isRiveSupported) {
    await rive.RiveNative.init();
  }

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
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            padding: mediaQuery.padding +
                const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
          ),
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
