import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class AppConfig {
  static String get googleWebClientId =>
      dotenv.get('GOOGLE_WEB_CLIENT_ID', fallback: '');

  static String get appName => dotenv.get('APP_NAME', fallback: 'Poker Gambit');

  static String get assetBaseUrl => dotenv.get('ASSET_BASE_URL', fallback: '');
}
