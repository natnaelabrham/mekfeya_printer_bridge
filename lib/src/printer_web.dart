import 'dart:js_interop';
import 'dart:typed_data';
import 'package:flutter/material.dart';

@JS('requestBluetoothPrinter')
external JSPromise<JSBoolean> _requestBluetoothPrinter();

@JS('requestSerialPrinter')
external JSPromise<JSBoolean> _requestSerialPrinter();

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
Future<bool> connectWebPrinter({required Function onDisconnect}) async {
  try {
    _window.onPrinterDisconnectCallback = (() {
      onDisconnect();
      debugPrint('Web printer disconnected.');
    }).toJS;

    final bool isWindows = _isWindowsBrowser().toDart;
    bool connectionSuccess = false;

    if (isWindows) {
      debugPrint('Windows browser: using Web Serial API.');
      final result = await _requestSerialPrinter().toDart;
      connectionSuccess = result.toDart;
    } else {
      debugPrint('Non-Windows browser: using Web Bluetooth API.');
      final result = await _requestBluetoothPrinter().toDart;
      connectionSuccess = result.toDart;
    }

    return connectionSuccess;
  } catch (e) {
    debugPrint('connectWebPrinter error: $e');
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
      if (result.toDart == false) {
        throw Exception('Web Printer JS rejected payload at chunk $i.');
      }
      await Future.delayed(const Duration(milliseconds: 30));
    }
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  } catch (e) {
    debugPrint('sendDataToPrinterWeb error: $e');
    return false;
  }
}
