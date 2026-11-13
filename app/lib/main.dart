// Flutter entry point — PRODUCTION
import 'package:sipho/bootstrap.dart';
import 'package:sipho/core/firebase/firebase_options_dev.dart'
    as firebase_options;

void main() =>
    bootstrap(firebase_options.DefaultFirebaseOptions.currentPlatform,
        flavor: 'prod');
