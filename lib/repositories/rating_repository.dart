import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jiffy/jiffy.dart';

class RatingRepository {

  // Dependencia de la base de datos para las consultas
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Método para obtener la calificación en la última semana de un restaurante
  Future<double> getWeeklyRating(String restaurantName) async {

    try {
      // Información actual de fechas
      DateTime now = DateTime.now();
      int currentYear = now.year;
      int currentWeek = Jiffy.now().weekOfYear;
      
      // COnsulta a la base de datos
      QuerySnapshot querySnapshot = await _db.collection('restaurant_reviews').where('restaurant_name', isEqualTo: restaurantName).get();
      List<double> scores = [];

      // Si no hay reviews en la última semana
      if (querySnapshot.size == 0) return 0.0;

      // Se cojen las reviews que son utiles
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data['timestamp'] is! Timestamp) continue;
        
        // Información de fecha de la reseña
        DateTime timestamp = (data['timestamp'] as Timestamp).toDate();
        int reviewWeek = Jiffy.parseFromDateTime(timestamp).weekOfYear;
        int reviewYear = timestamp.year;

        // Si corresponde con la semana y el año
        if (reviewWeek == currentWeek && reviewYear == currentYear) {
          double? score = _parseDouble(data['review_score']);
          if (score != null) scores.add(score);
        }
      }

      if (scores.isEmpty) return 0.0;

      // Se reduce usando el promedio
      double average = scores.reduce((a, b) => a + b) / scores.length;
      return average;
    } 
    catch (e) {
      return 0.0;
    }
  }

  // Método para convertir a double de manera segura
  double? _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
