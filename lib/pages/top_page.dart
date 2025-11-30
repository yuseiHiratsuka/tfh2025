import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart';
import 'package:tfh2025/components/background.dart';

class TopPage extends StatefulWidget {
  const TopPage({super.key});

  @override
  State<TopPage> createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  File? _startButtonRiveFile;
  RiveWidgetController? _startButtonController;

  @override
  void initState() {
    super.initState();
    _loadStartButtonRiveFile();
  }

  Future<void> _loadStartButtonRiveFile() async {
    _startButtonRiveFile = await File.asset(
      'assets/rive/start_button.riv',
      riveFactory: Factory.rive,
    );
    if (_startButtonRiveFile != null) {
      _startButtonController = RiveWidgetController(_startButtonRiveFile!);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _startButtonController?.dispose();
    _startButtonRiveFile?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset(
                        'assets/images/title.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'スタート→ゴールを、\nAI判定つき絵しりとりでつなごう！',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  HapticFeedback.heavyImpact();
                  await Future<void>.delayed(const Duration(seconds: 2));
                  if (context.mounted) {
                    context.go('/room_entry');
                  }
                },
                child: _startButtonController == null
                    ? const SizedBox(
                        width: double.infinity,
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: RiveWidget(
                          controller: _startButtonController!,
                          fit: Fit.cover,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
