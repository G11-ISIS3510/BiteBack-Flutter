import 'package:biteback/models/business_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

class BusinessRepository {

  // Instancia para acceder a la base de datos del negocio
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Método encargado de traer todos los negocios de tipo restaurante
  Future<List<Business>> getRestaurants() async {

    try {
      // Se traen todos los restaurantes que cumplan con la query
      QuerySnapshot querySnapshot = await _db.collection('business').where('type', isEqualTo: 'restaurant').get();

      // Modelar la entrada como un mapa para que se pueda manejar dentro de la aplicacion
      // A futuro toca modelar los atributos que hacen falta
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Business(
          id: doc.id, 
          name: data['name'], 
          type: data['type'], 
          latitude: (data['latitude'] as num).toDouble(), 
          longitude: (data['longitude'] as num).toDouble(), 
          rating: (data['rating'] as num).toDouble(), 
          image: data['image'], 
          openHour: (data['openHour'] as Timestamp).toDate().hour, 
          closeHour: (data['closeHour'] as Timestamp).toDate().hour);
      }).toList();
    }
    catch (e) {
      return [];
    }
  } 
}