import 'dart:async'; // Necesario para el temporizador
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:geolocator/geolocator.dart';
import 'package:stikev/utils/route_config.dart';
class SocketService {
  IO.Socket? socket;
  final String token;
  final String userId;

  Timer? _timer;

  // Constructor que recibe el token y el userId
  SocketService({required this.token, required this.userId});

  void connect() {
    if (token.isEmpty) {
      print('No hay token. Conexión denegada.');
      return;
    }

    socket = IO.io(AppConfig.ubicationWsUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'token': token},
    });

    socket?.on('connect', (_) {
      print('Conectado al servidor WebSocket');
      _startPeriodicUpdates(); // Iniciar el envío periódico de datos
    });

    socket?.on('disconnect', (_) {
      print('Desconectado del servidor WebSocket');
      _stopPeriodicUpdates(); // Detener el temporizador al desconectarse
    });

    socket?.on('position/$userId', (data) {
      print('Recibido desde el servidor: $data');
    });

    socket?.connect();
  }

  // Enviar la ubicación del dispositivo al servidor
  void sendPosition(double lat, double lng) {
    socket?.emit('position', {
      'userId': userId,
      'lat': lat,
      'lng': lng,
    });
  }

  // Iniciar actualizaciones periódicas de ubicación
void _startPeriodicUpdates() {
  print('Iniciando actualizaciones periódicas...');
  _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
    Position position = await _getCurrentPosition();
    if (position != null) {
      sendPosition(position.latitude, position.longitude);
    } else {
      print('No se pudo obtener la ubicación');
    }
  });
}


  // Detener el temporizador de actualizaciones
  void _stopPeriodicUpdates() {
    _timer?.cancel();
  }

  // Obtener la ubicación actual del dispositivo
  Future<Position> _getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Servicio de ubicación desactivado');
        return Future.error('Ubicación desactivada');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Permiso de ubicación denegado permanentemente');
      }

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
          return Future.error('Permiso de ubicación denegado');
        }
      }

      // Obtener la posición actual
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      print('Error al obtener la ubicación: $e');
      return Future.error('Error al obtener la ubicación');
    }
  }

  // Cerrar la conexión del socket
  void disconnect() {
    socket?.disconnect();
    _stopPeriodicUpdates(); // Detener el temporizador si la conexión se cierra
  }
  void listenToEvents(String user) {
    socket?.on('position/$user', (data) {
      print('Recibido desde el servidor: $data');
    });
  }
}


 