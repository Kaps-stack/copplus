class AppConfig {
  /// URLs des environnements
  static const String devUrl = 'http://10.0.3.2:8000/api';

  static const String tunnelUrl =
      'https://mon-app.com/api';

  static const String prodUrl = 'https://api.copplus.com/api';

  static const String stagingUrl = 'https://staging.copplus.com/api';

  /// Obtenir l'URL de base selon l'environnement
  static String getBaseUrl() {
    const String env = String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'dev',
    );

    switch (env) {
      case 'prod':
        return prodUrl;

      case 'staging':
        return stagingUrl;

      case 'tunnel':
        return tunnelUrl;

      case 'dev':
      default:
        return devUrl;
    }
  }
}