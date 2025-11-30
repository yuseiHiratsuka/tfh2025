import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart';
import 'package:tfh2025/components/background.dart';
import 'package:tfh2025/utils/rive_support.dart';

class TopPage extends StatefulWidget {
  const TopPage({super.key});

  @override
  State<TopPage> createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  File? _startButtonRiveFile;
  RiveWidgetController? _startButtonController;
  bool _riveEnabled = isRiveSupported;

  @override
  void initState() {
    super.initState();
    if (_riveEnabled) {
      _loadStartButtonRiveFile();
    }
  }

  Future<void> _loadStartButtonRiveFile() async {
    final riveFile =
        await loadRiveFileIfSupported('assets/rive/start_button.riv');
    if (!mounted) return;
    if (riveFile == null) {
      setState(() {
        _riveEnabled = false;
      });
      return;
    }
    _startButtonRiveFile = riveFile;
    _startButtonController = RiveWidgetController(riveFile);
    setState(() {});
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
                    context.push('/room_entry');
                  }
                },
                child: _buildStartButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    if (_riveEnabled && _startButtonController != null) {
      return SizedBox(
        width: double.infinity,
        height: 200,
        child: RiveWidget(
          controller: _startButtonController!,
          fit: Fit.cover,
        ),
      );
    }

    if (_riveEnabled) {
      return const SizedBox(
        width: double.infinity,
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        'スタート',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
