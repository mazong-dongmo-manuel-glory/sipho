// Flutter entry point — STAGING (Firebase project: sipho-staging)
import 'package:sipho/bootstrap.dart';
import 'package:sipho/core/firebase/firebase_options_staging.dart'
    as firebase_options;

void main() =>
    bootstrap(firebase_options.DefaultFirebaseOptions.currentPlatform,
        flavor: 'staging');
