import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  const ShareService._();

  static Future<void> shareText(BuildContext context, String text) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      await SharePlus.instance.share(ShareParams(text: text));
    } on MissingPluginException {
      await _copyFallback(messenger, text);
    } on PlatformException {
      await _copyFallback(messenger, text);
    }
  }

  static Future<void> shareWidgetAsImage(
    BuildContext context,
    GlobalKey boundaryKey, {
    String fileName = 'gitsawe',
    String? shareText,
  }) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw StateError('Nothing to capture yet.');

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw StateError('Could not encode image.');

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName-${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: shareText,
        ),
      );
    } catch (e, st) {
      debugPrint('shareWidgetAsImage failed: $e\n$st');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not create a shareable image.')),
        );
      }
    }
  }

  static Future<void> _copyFallback(ScaffoldMessengerState? messenger, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    messenger?.showSnackBar(
      const SnackBar(content: Text('Sharing is unavailable. Text copied instead.')),
    );
  }
}