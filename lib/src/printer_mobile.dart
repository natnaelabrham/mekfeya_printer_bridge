import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:usb_serial/usb_serial.dart';

// ── Bluetooth ─────────────────────────────────────────────────────────────────
// Returns the write characteristic — used by print actions that connect early
Future<BluetoothCharacteristic?> getBluetoothWriteChar(String deviceId) async {
  try {
    final device = BluetoothDevice.fromId(deviceId);
    final services = await device.discoverServices();
    for (var s in services) {
      for (var c in s.characteristics) {
        if (c.uuid.toString().contains('bef8d6c9') ||
            c.uuid.toString().contains('884143f4') ||
            c.properties.write) {
          return c;
        }
      }
    }
    debugPrint('getBluetoothWriteChar: no writable characteristic found.');
    return null;
  } catch (e) {
    debugPrint('getBluetoothWriteChar error: $e');
    return null;
  }
}

Future<bool> sendViaBluetooth(List<int> bytes, String deviceId) async {
  try {
    final writeChar = await getBluetoothWriteChar(deviceId);
    if (writeChar == null) return false;
    const int chunkSize = 20;
    for (int i = 0; i < bytes.length; i += chunkSize) {
      int end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
      await writeChar.write(bytes.sublist(i, end), withoutResponse: true);
      await Future.delayed(const Duration(milliseconds: 15));
    }
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  } catch (e) {
    debugPrint('sendViaBluetooth error: $e');
    return false;
  }
}

// ── Bluetooth Connection ─────────────────────────────────────────────────────
Future<bool> connectViaBluetoothMobile(String deviceId) async {
  try {
    final device = BluetoothDevice.fromId(deviceId);

    // Explicitly add the required License argument required by newer flutter_blue_plus versions
    await device.connect(
      license: License.free,
      timeout: const Duration(seconds: 10),
      autoConnect: false,
    );

    await device.discoverServices();
    debugPrint("LOG: Connected successfully to ${device.remoteId}");
    return true;
  } catch (e) {
    debugPrint("LOG: Connection failed: $e");
    return false;
  }
}

Future<void> disconnectViaBluetoothMobile(String deviceId) async {
  try {
    if (deviceId.isNotEmpty) {
      final device = BluetoothDevice.fromId(deviceId);
      await device.disconnect();
      debugPrint(
          'disconnectViaBluetoothMobile: Device $deviceId disconnected.');
    }
  } catch (e) {
    debugPrint('disconnectViaBluetoothMobile error: $e');
  }
}

// ── USB ───────────────────────────────────────────────────────────────────────
Future<bool> sendViaUsb(List<int> bytes) async {
  if (Platform.isIOS) {
    debugPrint('USB not supported on iOS.');
    return false;
  }
  UsbPort? port;
  try {
    final devices = await UsbSerial.listDevices();
    if (devices.isEmpty) return false;
    port = await devices.first.create();
    if (port == null || !(await port.open())) return false;
    const int chunkSize = 128;
    for (int i = 0; i < bytes.length; i += chunkSize) {
      int end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
      await port.write(Uint8List.fromList(bytes.sublist(i, end)));
      await Future.delayed(const Duration(milliseconds: 30));
    }
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  } catch (e) {
    debugPrint('sendViaUsb error: $e');
    return false;
  } finally {
    await port?.close();
  }
}

// ── Ethernet ──────────────────────────────────────────────────────────────────
Future<bool> sendViaEthernetMobile(List<int> bytes, String ip) async {
  Socket? socket;
  try {
    socket =
        await Socket.connect(ip, 9100, timeout: const Duration(seconds: 3));
    socket.add(bytes);
    await socket.flush();
    await socket.close();
    return true;
  } catch (e) {
    debugPrint('sendViaEthernetMobile error: $e');
    socket?.destroy();
    return false;
  }
}

// ── Connection Monitoring ───────────────────────────────────────────────────
void monitorBluetoothConnectionMobile(
    String deviceId, Function(bool) onStateChanged) {
  try {
    if (deviceId.isEmpty) return;
    final device = BluetoothDevice.fromId(deviceId);

    device.connectionState.listen((BluetoothConnectionState state) {
      bool isConnected = (state == BluetoothConnectionState.connected);
      onStateChanged(isConnected);
      debugPrint("LOG: Connection state changed to: $state");
    });
  } catch (e) {
    debugPrint("LOG: Error monitoring connection: $e");
  }
}

// ── Web stubs — never called on mobile ───────────────────────────────────────
Future<bool> connectWebPrinter({
  required String type,
  required Function onDisconnect,
}) async =>
    false;

Future<bool> sendDataToPrinterWeb(List<int> bytes) async => false;
Future<bool> disconnectWebPrinter() async => true;
