import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import 'download_helper_stub.dart'
    if (dart.library.html) 'download_helper_web.dart';

/// Downloads [bytes] as a file named [filename].
/// On web this triggers a browser download. On mobile it's a no-op
/// (you'd need path_provider + file writing for mobile saves).
void downloadFile(Uint8List bytes, String filename) {
  if (kIsWeb) downloadFileWeb(bytes, filename);
}
