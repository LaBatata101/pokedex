import 'package:flutter/material.dart';
import 'package:pokedex/pokeapi/pokeapi.dart';
import 'package:pokedex/repositories/pokemon_repository.dart';
import 'package:pokedex/repositories/pokemon_repository_impl.dart';
import 'package:pokedex/viewmodels/home_view_model.dart';
import 'package:pokedex/views/pokedex_home.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final pokeApi = await PokeAPI.create();

  runApp(
    MultiProvider(
      providers: [
        Provider<PokeAPI>(create: (_) => pokeApi),
        Provider<PokemonRepository>(
          create: (context) => PokemonRepositoryImpl(context.read<PokeAPI>()),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create:
              (context) =>
                  HomeViewModel(context.read<PokemonRepository>())..init(),
        ),
      ],
      child: const PokedexApp(),
    ),
  );
}

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const PokedexHome(title: 'Pokédex'),
    );
  }
}
