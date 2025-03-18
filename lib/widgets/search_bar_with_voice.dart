// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

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
    // Se solicitan los permisos necesarios para usar el microfono
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      bool available = await _speech.initialize();
      // Si el microfono esta disponible, se prepara para uso
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
    else {
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}