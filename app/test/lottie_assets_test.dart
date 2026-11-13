import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final name in [
    'confetti_celebration',
    'xp_coins',
    'streak_fire',
    'scan_laser',
  ]) {
    test('loads $name', () async {
      final data = await rootBundle.load('assets/animations/$name.json');
      final composition = await LottieComposition.fromByteData(data);
      expect(composition.duration.inMilliseconds, greaterThan(0));
    });
  }
}
