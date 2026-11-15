import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/core/sound/sound_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final effects = SiphoSound.values.where((s) => !s.isVoice).toList();

  test('every sound effect ships as a bundled, valid OGG file', () async {
    for (final sound in effects) {
      final data = await rootBundle.load(sound.assetPath);
      final bytes = data.buffer.asUint8List();
      expect(bytes.length, greaterThan(1024),
          reason: '${sound.assetPath} is empty');
      expect(String.fromCharCodes(bytes.sublist(0, 4)), 'OggS',
          reason: '${sound.assetPath} is not an OGG file');
    }
  });

  test('sizes respect the README budget: < 50 KB each, < 1 MB in total',
      () async {
    var total = 0;
    for (final sound in effects) {
      final size = (await rootBundle.load(sound.assetPath)).lengthInBytes;
      expect(size, lessThan(50 * 1024), reason: sound.assetPath);
      total += size;
    }
    expect(total, lessThan(1024 * 1024));
  });
}
