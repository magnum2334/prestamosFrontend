import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Obtén las IPs desde las variables de entorno
  static String get apiServerIp => dotenv.env['API_STIKEV']!;

  // Construye las URLs completas para las APIs
  static String get healthApiUrl => '$apiServerIp/health';
  static String get profileApiUrl => '$apiServerIp/auth/profile';
  static String get authApiUrl => '$apiServerIp/auth/login';
  static String get userApiUrl => '$apiServerIp/users';
  static String get clientApiUrl => '$apiServerIp/cliente/create';
  static String get routeApiUrl => '$apiServerIp/ruta';
  static String get loanApiUrl => '$apiServerIp/prestamo';
  static String get paymentApiUrl => '$apiServerIp/pago';
  static String get jopApiUrl => '$apiServerIp/jop';
  static String rutaCobradorApiUrl(String cobradorId) => '$apiServerIp/ruta/cobrador/$cobradorId';
  static String rutaPrestamoApiUrl(String rutaId) => '$apiServerIp/cliente/prestamos/ruta/$rutaId';
  static String rutaPrestamoPagoApiUrl(String prestamoId) => '$apiServerIp/cliente/prestamo/$prestamoId';
}
