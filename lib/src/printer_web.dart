import 'dart:js_interop';
import 'dart:typed_data';
import 'package:flutter/material.dart';

// ── JS bridges ───────────────────────────────────────────────────────────────
@JS('requestBluetoothPrinter')
external JSPromise<JSBoolean> _requestBluetoothPrinter();

@JS('requestSerialPrinter')
external JSPromise<JSBoolean> _requestSerialPrinter();

@JS('requestUsbPrinter')
external JSPromise<JSBoolean> _requestUsbPrinter();

@JS('isWindowsBrowser')
external JSBoolean _isWindowsBrowser();

@JS('sendDataToPrinter')
external JSPromise<JSBoolean> _sendDataToPrinter(JSUint8Array data);

@JS('window')
external JSObject get _window;

extension WindowExtension on JSObject {
  @JS('onPrinterDisconnectCallback')
  external set onPrinterDisconnectCallback(JSFunction cb);
}

// ── connectWebPrinter ────────────────────────────────────────────────────────
Future<bool> connectWebPrinter({
  required String type,
  required Function onDisconnect,
}) async {
  try {
    _window.onPrinterDisconnectCallback = (() {
      onDisconnect();
      debugPrint('Web printer disconnected.');
    }).toJS;

    bool connectionSuccess = false;
    if (type == 'usb') {
      final result = await _requestUsbPrinter().toDart;
      connectionSuccess = result.toDart;
    } else {
      final bool isWindows = _isWindowsBrowser().toDart;
      if (isWindows) {
        final result = await _requestSerialPrinter().toDart;
        connectionSuccess = result.toDart;
      } else {
        final result = await _requestBluetoothPrinter().toDart;
        connectionSuccess = result.toDart;
      }
    }
    return connectionSuccess;
  } catch (e) {
    debugPrint('connectWebPrinter error ($type): $e');
    return false;
  }
}

// ── sendDataToPrinterWeb ─────────────────────────────────────────────────────
Future<bool> sendDataToPrinterWeb(List<int> bytes) async {
  try {
    const int chunkSize = 128;
    for (int i = 0; i < bytes.length; i += chunkSize) {
      int end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
      final chunk = bytes.sublist(i, end);
      final result =
          await _sendDataToPrinter(Uint8List.fromList(chunk).toJS).toDart;
      if (result.toDart == false)
        throw Exception('Web Printer JS rejected payload at chunk $i.');
      await Future.delayed(const Duration(milliseconds: 30));
    }
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  } catch (e) {
    debugPrint('sendDataToPrinterWeb error: $e');
    return false;
  }
}

void monitorBluetoothConnectionMobile(
    String deviceId, Function(bool) onStateChanged) {}

Future<bool> connectViaBluetoothMobile(String deviceId) async => false;
Future<void> disconnectViaBluetoothMobile(String deviceId) async {}

// ── disconnectWebPrinter ─────────────────────────────────────────────────────
Future<bool> disconnectWebPrinter() async => true;

// ── Mobile stubs — never called on web ───────────────────────────────────────
Future<dynamic> getBluetoothWriteChar(String deviceId) async => null;
Future<bool> sendViaBluetooth(List<int> bytes, String deviceId) async => false;
Future<bool> sendViaUsb(List<int> bytes) async => false;
Future<bool> sendViaEthernetMobile(List<int> bytes, String ip) async => false;
