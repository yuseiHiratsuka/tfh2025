import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tfh2025/theme/app_theme.dart';

import 'firebase_options.dart';
import 'router.dart';
import 'services/repositories/test_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({this.testRepository, super.key});

  final TestRepository? testRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TFH 2025',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
