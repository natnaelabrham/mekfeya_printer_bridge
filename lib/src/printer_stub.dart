import 'package:flutter/material.dart';

Future<bool> connectWebPrinter(
    {required String type, required Function onDisconnect}) async {
  debugPrint('connectWebPrinter: not supported on mobile.');
  return false;
}

Future<bool> sendDataToPrinterWeb(List<int> bytes) async {
  debugPrint('sendDataToPrinterWeb: not supported on mobile.');
  return false;
}

Future<bool> disconnectWebPrinter() async {
  return true; // Logic handled natively in FF Action for mobile
}
