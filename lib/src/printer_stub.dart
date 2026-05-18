import 'package:flutter/material.dart';

// Mobile build: these functions are safe stubs.
// They will never be called on mobile because kIsWeb guards
// in your FlutterFlow actions prevent it.

Future<bool> connectWebPrinter({required Function onDisconnect}) async {
  debugPrint('connectWebPrinter: not supported on mobile.');
  return false;
}

Future<bool> sendDataToPrinterWeb(List<int> bytes) async {
  debugPrint('sendDataToPrinterWeb: not supported on mobile.');
  return false;
}
