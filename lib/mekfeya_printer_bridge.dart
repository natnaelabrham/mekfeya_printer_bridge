// Routes to the correct implementation at compile time:
// - Web build   → printer_web.dart    (dart:js_interop, no mobile packages)
// - Mobile build → printer_mobile.dart (flutter_blue_plus, usb_serial, dart:io)
// - Fallback    → printer_stub.dart   (safe no-ops)
export 'src/printer_stub.dart'
    if (dart.library.js_interop) 'src/printer_web.dart'
    if (dart.library.io) 'src/printer_mobile.dart';
