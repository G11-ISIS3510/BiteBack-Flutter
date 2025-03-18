import 'package:biteback/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductsRepository {

  // Instancia para acceder a la basa de datos del negocio
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Método encargado de cargar todos los productos
  Future<List<Product>> getProducts() async {

    try{
      // Se traen todos los productos listados
      QuerySnapshot querySnapshot = await _db.collection('products').get();
      // Modelar la entrada como un mapa para poder manejar los atributos
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Product(
          id: doc.id,
          name: data['name'],
          image: data['image'],
          discount: (data['discount'] as num).toDouble(),
          description: data['description'],
          expirationDate: (data['expirationDate'] as Timestamp).toDate(),
          price: (data['price'] as num).toDouble(),
          category: data['category'],
          categoryImage: data['categoryImage'],
          businessId: data['businessId']);
      }).toList();
    }
    catch (e) {
      return [];
    }
  }
  // Método encargado de traer las categorias unicas de los productos listados
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