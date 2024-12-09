import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:geolocator/geolocator.dart';
import 'package:stikev/utils/route_config.dart';

class SocketService {
  IO.Socket? socket;

  // Conectar al servidor WebSocket
  void connect() {
    socket = IO.io(AppConfig.ubicationWsUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false, // Desactivar la conexión automática
    });

    // Evento cuando se conecta
    socket?.on('connect', (_) {
      print('Conectado al servidor WebSocket');
    });

    // Evento cuando se desconecta
    socket?.on('disconnect', (_) {
      print('Desconectado del servidor WebSocket');
    });

    // Conectar al servidor WebSocket
    socket?.connect();
  }

  // Enviar la ubicación del usuario al servidor
  void sendPosition(String userId, double lat, double lng) {
    socket?.emit('position', {
      'userId': userId,
      'lat': lat,
      'lng': lng,
    });
  }

  // Escuchar eventos desde el servidor
  void listenToEvents(user) {
    socket?.on('position/$user', (data) {
      print('Recibido desde el servidor: $data');
    });
  }

  // Cerrar la conexión
  void disconnect() {
    socket?.disconnect();
  }
}
