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

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, this.testRepository, super.key});

  final String title;
  final TestRepository? testRepository;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late final TestRepository _testRepository;
  String? _savedDocumentId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _testRepository = widget.testRepository ?? TestRepository();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  /// Firestoreにテスト文字列を保存
  Future<void> _saveTestText() async {
    setState(() {
      _errorMessage = null;
      _savedDocumentId = null;
    });

    try {
      const testText = 'これはテスト用の文字列です';
      final documentId = await _testRepository.saveTestText(text: testText);

      setState(() {
        _savedDocumentId = documentId;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Firestoreに保存しました！\nドキュメントID: $documentId'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _saveTestText,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Firestoreにテスト文字を保存'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            if (_savedDocumentId != null) ...[
              const SizedBox(height: 16),
              Text(
                '保存成功！\nドキュメントID: $_savedDocumentId',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.green),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                'エラー: $_errorMessage',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _saveTestText,
            tooltip: 'Firestoreに保存',
            heroTag: 'save',
            child: const Icon(Icons.cloud_upload),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            heroTag: 'increment',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
