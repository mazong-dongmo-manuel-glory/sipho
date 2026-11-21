// Flutter entry point — DEVELOPMENT / QA (Firebase project: sipho-staging)
import 'package:sipho/bootstrap.dart';
import 'package:sipho/core/firebase/firebase_options_dev.dart'
    as firebase_options;

void main() =>
    bootstrap(firebase_options.DefaultFirebaseOptions.currentPlatform,
        flavor: 'dev');
