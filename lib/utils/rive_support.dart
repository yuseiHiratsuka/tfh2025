import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:rive/rive.dart' as rive;

bool get isRiveSupported {
  if (kIsWeb) return false;

  if (Platform.environment.containsKey('FLUTTER_TEST')) return false;

  return Platform.isAndroid || Platform.isIOS;
}

Future<rive.File?> loadRiveFileIfSupported(String assetPath) async {
  if (!isRiveSupported) return null;

  try {
    return await rive.File.asset(
      assetPath,
      riveFactory: rive.Factory.rive,
    );
  } catch (e) {
    debugPrint('Rive asset load failed ($assetPath): $e');
    return null;
  }
}
