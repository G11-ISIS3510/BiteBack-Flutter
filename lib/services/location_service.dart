import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {

  // Método para obtener la posición actual del usuario
  static Future<Position?> getCurrentPosition() async {

    // Se revisa si el servicio de ubicación está habilitado en el dispositivo
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    // Se revisa que se tengan los permisos necesarios para usar el servicio de ubicación
    LocationPermission permission = await Geolocator.checkPermission();
    // Si no se cuenta con los permisos, se solicitan al usuario
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      // Para manejar el caso en el que el usuario niega los permisos de ubicación
      if (permission == LocationPermission.denied) return null;
    }

    // Para manejar el caso en el que el usuario niega los permisos de ubicación
    if (permission == LocationPermission.deniedForever) return null;

    // Retorna la posición actual del dispositivo
    return await Geolocator.getCurrentPosition();
  }

  // Método para convertir coordenadas en una dirección legible
  static Future<String> getAddressFromCoordinates(Position position) async {

    try {

      // Se obtienen los lugares (direcciones) que hacen match con las coordenadas del usuario
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      
      if (placemarks.isNotEmpty) {
        // Se obtiene el primer lugar con el cual se hizo match
        Placemark place = placemarks.first;
        // Se retorna la información para su visualización
        return "${place.street}, ${place.locality}, ${place.country}";
      } 
      else {
        return "Dirección no encontrada";
      }
    } 
    catch (e) {
      return "No hay conexión a internet.";
    }
  }
}
