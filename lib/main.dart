import 'package:flutter/material.dart';
import 'package:pokedex/pokeapi/pokeapi.dart';
import 'package:pokedex/viewmodels/home_view_model.dart';
import 'package:pokedex/views/pokedex_home.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PokeAPI>(
      future: PokeAPI.create(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final api = snapshot.data!;
          return ChangeNotifierProvider(
            create: (_) => HomeViewModel(api)..init(),
            child: MaterialApp(
              title: 'Pokédex',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              ),
              home: const PokedexHome(title: 'Pokédex Home'),
            ),
          );
        } else if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error initializing API: ${snapshot.error}'),
              ),
            ),
          );
        }
        return MaterialApp(
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        );
      },
    );
  }
}
