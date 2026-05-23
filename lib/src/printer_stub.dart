import 'package:flutter/material.dart';

// ── Web stubs ────────────────────────────────────────────────────────────────
// Mobile-only packages (flutter_blue_plus, usb_serial, dart:io)
// are never compiled on web. All transport functions return false safely.

bool isDesktopPlatform() => false;

Future<bool> connectWebPrinter({
  required String type,
  required Function onDisconnect,
}) async {
  debugPrint('connectWebPrinter: not supported on mobile.');
  return false;
}

Future<bool> sendDataToPrinterWeb(List<int> bytes) async {
  debugPrint('sendDataToPrinterWeb: not supported on mobile.');
  return false;
}

Future<bool> disconnectWebPrinter() async => true;

// Mobile transport stubs — called on web, do nothing
Future<bool> sendViaBluetooth(List<int> bytes, String deviceId) async {
  debugPrint('sendViaBluetooth: not supported on web.');
  return false;
}

Future<bool> sendViaUsb(List<int> bytes) async {
  debugPrint('sendViaUsb: not supported on web.');
  return false;
}

Future<bool> sendViaEthernetMobile(List<int> bytes, String ip) async {
  debugPrint('sendViaEthernetMobile: not supported on web.');
  return false;
}

// BT connect stub — used by print actions that connect early
Future<dynamic> getBluetoothWriteChar(String deviceId) async {
  debugPrint('getBluetoothWriteChar: not supported on web.');
  return null;
}

// Add this with your other mobile transport stubs
Future<void> disconnectViaBluetoothMobile(String deviceId) async {
  debugPrint('disconnectViaBluetoothMobile: not supported on this platform.');
}

Future<bool> connectViaBluetoothMobile(String deviceId) async {
  debugPrint('connectViaBluetoothMobile: not supported on this platform.');
  return false;
}

void monitorBluetoothConnectionMobile(
    String deviceId, Function(bool) onStateChanged) {
  debugPrint(
      'monitorBluetoothConnectionMobile: not supported on this platform.');
}
