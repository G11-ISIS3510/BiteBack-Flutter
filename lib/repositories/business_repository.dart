import 'package:biteback/models/business_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

class BusinessRepository {

  // Instancia para acceder a la base de datos del negocio
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Método encargado de traer todos los negocios de tipo restaurante
  Future<List<Business>> getRestaurants() async {

    try {
      // Se traen todos los restaurantes que cumplan con la query
      QuerySnapshot querySnapshot = await _db.collection('business').where('type', isEqualTo: 'restaurante').get();
      // Modelar la entrada como un mapa para que se pueda manejar dentro de la aplicacion
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Business(
          id: doc.id, 
          name: data['name'], 
          type: data['type'], 
          latitude: (data['latitude'] as num).toDouble(), 
          longitude: (data['longitude'] as num).toDouble(), 
          address: data['address'],
          rating: (data['rating'] as num).toDouble(), 
          image: data['image'], 
          startHour: (data['startHour'] as num).toInt(), 
          closeHour: (data['closeHour'] as num).toInt(),
          products: []);
      }).toList();
    }
    catch (e) {
      return [];
    }
  } 


  Future<Business?> getBusinessById(String businessId) async {
    try {
      DocumentSnapshot doc = await _db.collection('business').doc(businessId).get();
      if (!doc.exists) return null;
      
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Business(
        id: doc.id,
        name: data['name'], 
        type: data['type'],
        latitude: (data['latitude'] as num).toDouble(),
        longitude: (data['longitude'] as num).toDouble(),
        address: data['address'],
        rating: (data['rating'] as num).toDouble(),
        image: data['image'],
        startHour: (data['startHour'] as num).toInt(),
        closeHour: (data['closeHour'] as num).toInt(),
        products: [],
      );
    } catch (e) {
      return null;
    }
  }
}