import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsRepository {

  // Instancia para acceder a la base de datos del negocio
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Método encargado de agregar una insteraccion con los filtros de categorias
  Future<void> addFilterButtonsUsage(String category) async {
    try{
      await _db.collection('filter_buttons_usage').add({
        'filter_name': category,
        'count': 1,
        'timestamp': FieldValue.serverTimestamp()
      });
    }
    catch(e){
      return;
    }
  }

  // Método encargado de añadir un tiempo de carga de la pantalla princiapl
  Future<void> addLoadTimeHomePage(double loadtime) async {
    try{
      await _db.collection('homepage_load_time').add({
        'load_time': loadtime,
        'timestamp': FieldValue.serverTimestamp()
      });
    }
    catch(e){
      return;
    }
  }
}