import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
      final dir = Directory('presentation_screenshots');
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      final file = File('presentation_screenshots/$name.png');
      await file.writeAsBytes(bytes);
      stdout.writeln('Saved ${file.path} (${bytes.length} bytes)');
      return true;
    },
  );
}
