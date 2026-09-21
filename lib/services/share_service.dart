import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  static Future<void> _copyFallback(ScaffoldMessengerState? messenger, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    messenger?.showSnackBar(
      const SnackBar(content: Text('Sharing is unavailable. Text copied instead.')),
    );
  }
}