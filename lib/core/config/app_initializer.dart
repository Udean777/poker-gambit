import 'package:poker_gambit/firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppInitializer {
  AppInitializer._();

  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize App Check
    await FirebaseAppCheck.instance.activate(
      providerApple: kDebugMode
          ? const AppleDebugProvider()
          : const AppleDeviceCheckProvider(),
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
      providerWeb: ReCaptchaV3Provider(
        dotenv.get('RECAPTCHA_V3_KEY', fallback: ''),
      ),
    );

    // In Google Sign In 6.x, we don't need a static initialize call here.
    // Initialization is handled when the GoogleSignIn object is created.
  }
}
