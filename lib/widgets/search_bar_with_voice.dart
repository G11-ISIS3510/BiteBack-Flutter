// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';

class SearchBarWithVoice extends StatefulWidget {
  @override
  _SearchBarWithVoiceState createState() => _SearchBarWithVoiceState();
}

class _SearchBarWithVoiceState extends State<SearchBarWithVoice> {
  TextEditingController _searchController = TextEditingController();
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_resetSearchIfEmpty);
  }

  @override
  void dispose() {
    _searchController.removeListener(_resetSearchIfEmpty);
    _searchController.dispose();
    super.dispose();
  }

  /// Restablece la búsqueda si el campo está vacío
  void _resetSearchIfEmpty() {
    if (_searchController.text.isEmpty) {
      Provider.of<HomeViewModel>(context, listen: false).resetProducts();
    }
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Provider.of<HomeViewModel>(context, listen: false).filterProducts(query);
    } else {
      Provider.of<HomeViewModel>(context, listen: false).resetProducts();
    }
  }

  void _startListening() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _searchController.text = result.recognizedWords;
            });

            // Ejecutar búsqueda al finalizar el reconocimiento
            if (result.finalResult) {
              _stopListening();
              _performSearch();
            }
          },
          listenFor: Duration(seconds: 5),
        );
      } else {
        _showPermissionError("Error al inicializar el reconocimiento de voz.");
      }
    } else {
      _showPermissionError("Permiso de micrófono denegado.");
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _showPermissionError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Busca productos, comidas o bebidas",
          prefixIcon: Icon(Icons.search),
          suffixIcon: IconButton(
            icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
            onPressed: _isListening ? _stopListening : _startListening,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onSubmitted: (value) => _performSearch(),
      ),
    );
  }
}
