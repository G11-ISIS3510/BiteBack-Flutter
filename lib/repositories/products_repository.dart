import 'package:cloud_firestore/cloud_firestore.dart';

class ProductsRepository {

  // Instancia para acceder a la basa de datos del negocio
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Método encargado de traer todos los productos listados
  Future<Set<String>> getUniqueCategories() async {
    
    try {
      // Se traen todas las categorias asociadas a los productos
      QuerySnapshot querySnapshot = await _db.collection('products').get();

      // Se extraen los valores unicos asociados al campo tag
      Set<String> categories = querySnapshot.docs.map((doc) => doc['category'] as String).toSet(); 
      return categories;
    }
    catch (e) {
      return {};
    }
  }
}