import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const PokeApp());
}

class PokeApp extends StatelessWidget {
  const PokeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokémon HTTP Search',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      home: const PokeSearchScreen(),
    );
  }
}

class PokeSearchScreen extends StatefulWidget {
  const PokeSearchScreen({super.key});

  @override
  State<PokeSearchScreen> createState() => _PokeSearchScreenState();
}

class _PokeSearchScreenState extends State<PokeSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  
  // Variables para almacenar los datos de la API
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _pokeData;

  // Función para realizar la petición HTTP GET a la PokéAPI
  Future<void> _buscarPokemon(String nombrePokemon) async {
    if (nombrePokemon.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _pokeData = null;
    });

    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/${nombrePokemon.toLowerCase().trim()}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _pokeData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Pokémon no encontrado. Intenta con otro nombre (ej. pikachu).';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión. Verifica tu acceso a Internet.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscador PokéAPI - HTTP Requests'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de texto para buscar
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Nombre del Pokémon (ej. pikachu, charizard)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.catching_pokemon),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _buscarPokemon(_controller.text),
                ),
              ),
              onSubmitted: (value) => _buscarPokemon(value),
            ),
            const SizedBox(height: 20),

            // Indicador de carga
            if (_isLoading)
              const CircularProgressIndicator(),

            // Mensaje de error
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

            // Resultados de la petición HTTP
            if (_pokeData != null && !_isLoading)
              Expanded(
                child: ListView(
                  children: [
                    // Imagen oficial del Pokémon
                    Center(
                      child: Image.network(
                        _pokeData!['sprites']['front_default'] ?? '',
                        height: 150,
                        width: 150,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
                      ),
                    ),
                    Text(
                      _pokeData!['name'].toString().toUpperCase(),
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    // Tipos del Pokémon
                    const Text('Tipos:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                    Wrap(
                      spacing: 8.0,
                      children: (_pokeData!['types'] as List).map((t) {
                        return Chip(
                          label: Text(t['type']['name'].toString().toUpperCase()),
                          backgroundColor: Colors.amber.shade200,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 15),

                    // Ataques (Movimientos) principales
                    const Text('Ataques principales:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: (_pokeData!['moves'] as List).take(8).map((m) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text('• ${m['move']['name']}'),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}