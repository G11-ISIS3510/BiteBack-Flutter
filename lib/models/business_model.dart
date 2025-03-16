class Business {
  final String id;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  // A futuro toca cambiar el final, cuando se agregue la herramienta de reviews
  final double rating;
  final String image;
  final int openHour;
  final int closeHour;
  // A futuro toca agregar y modelar el mapa de productos, para manejar relaciones

  Business({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.image,
    required this.openHour,
    required this.closeHour
  });

  // A futuro toca añadir el método para actualizar el rating
}