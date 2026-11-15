// Flutter entry point — PRODUCTION (Firebase project: sipho-prod)
import 'package:sipho/bootstrap.dart';
import 'package:sipho/core/firebase/firebase_options_prod.dart'
    as firebase_options;

void main() =>
    bootstrap(firebase_options.DefaultFirebaseOptions.currentPlatform,
        flavor: 'prod');
