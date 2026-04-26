import 'package:card_games/core/config/app_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AppInitializer {
  AppInitializer._();

  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
    await Firebase.initializeApp();
    await GoogleSignIn.instance.initialize(
      serverClientId: AppConfig.googleWebClientId,
    );
  }
}
