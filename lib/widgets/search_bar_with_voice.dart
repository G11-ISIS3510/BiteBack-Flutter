import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SearchBarWithVoice extends StatefulWidget {

  // Funcionalidad para manejar la búsqueda
  final Function(String) onSearch;

  SearchBarWithVoice({required this.onSearch});

  @override
  _SearchBarWithVoiceState createState() => _SearchBarWithVoiceState();
}

// Clase para crear la barra de búsqueda que permite búsquedas por voz
class _SearchBarWithVoiceState extends State<SearchBarWithVoice> {
  // Objetos para manejar la entrada
  TextEditingController _searchController = TextEditingController();
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  // Método para empezar a escuchar la query
  void _startListening() async {
    // Verifica que este disponible para escuchar
    bool available = await _speech.initialize(
      onStatus: (status) => print("Status: $status"),
      onError: (error) => print("Error: $error"),
    );

    // Leva a cabo el proceso de escucha y almacena la query
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _searchController.text = result.recognizedWords;
          });
          widget.onSearch(result.recognizedWords);
        },
      );
    }
  }

  // Método para parar la escucha
  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  // Definición UI del widget
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: _searchController,
        onChanged: widget.onSearch,
        decoration: InputDecoration(
          hintText: "Busca productos, comidas o bebidas",
          prefixIcon: Icon(Icons.search),
          suffixIcon: IconButton(
            icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
            onPressed: _isListening ? _stopListening : _startListening,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
