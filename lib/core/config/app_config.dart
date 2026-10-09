class AppConfig {
  static const String errorReportUrl = String.fromEnvironment(
    'ERROR_REPORT_URL',
    defaultValue:
        'https://mi-presupuesto-reportes.mi-presupuesto-pinzon.workers.dev/reports',
  );
  static const String flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'prod',
  );

  static bool get isDev => flavor == 'dev';
  static bool get isProd => flavor == 'prod';

  // Se guarda para un futuro uso, como URLs de API específicas por entorno
  // static String get apiBaseUrl {
  //   switch (flavor) {
  //     case 'dev':
  //       return 'https://api.dev.midominio.com';
  //     case 'prod':
  //     default:
  //       return 'https://api.midominio.com';
  //   }
  // }
}
