import 'package:flutter/material.dart';
import 'package:pokedex/pokeapi/entities/pokemon.dart';
import 'package:pokedex/repositories/pokemon_repository.dart';
import 'package:pokedex/utils/string.dart';
import 'package:pokedex/viewmodels/pokemon_details_viewmodel.dart';
import 'package:pokedex/views/pokemon_details_widgets/abilities_widget.dart';
import 'package:pokedex/views/pokemon_details_widgets/basic_info_widget.dart';
import 'package:pokedex/views/pokemon_details_widgets/cries_widget.dart';
import 'package:pokedex/views/pokemon_details_widgets/evolution_chain_widget.dart';
import 'package:pokedex/views/pokemon_details_widgets/header_widget.dart';
import 'package:pokedex/views/pokemon_details_widgets/held_items_widget.dart';
import 'package:pokedex/views/pokemon_details_widgets/legendary_effect_widget.dart';
import 'package:pokedex/views/pokemon_details_widgets/moves_widget.dart';
import 'package:pokedex/views/pokemon_details_widgets/stats_widget.dart';
import 'package:pokedex/views/pokemon_details_widgets/type_effectiveness_widget.dart';
import 'package:provider/provider.dart';

// Enhanced type colors with primary, secondary, and text colors for better theming
final pokemonTypeThemes = {
  'normal': PokemonTypeTheme(
    primary: Color(0xFFA8A878),
    secondary: Color(0xFFC6C6A7),
    text: Colors.white,
  ),
  'fire': PokemonTypeTheme(
    primary: Color(0xFFF08030),
    secondary: Color(0xFFF5AC78),
    text: Colors.white,
  ),
  'water': PokemonTypeTheme(
    primary: Color(0xFF6890F0),
    secondary: Color(0xFF9DB7F5),
    text: Colors.white,
  ),
  'grass': PokemonTypeTheme(
    primary: Color(0xFF78C850),
    secondary: Color(0xFFA7DB8D),
    text: Colors.white,
  ),
  'electric': PokemonTypeTheme(
    primary: Color(0xFFF8D030),
    secondary: Color(0xFFFAE078),
    text: Colors.black,
  ),
  'ice': PokemonTypeTheme(
    primary: Color(0xFF98D8D8),
    secondary: Color(0xFFBCE6E6),
    text: Colors.black,
  ),
  'fighting': PokemonTypeTheme(
    primary: Color(0xFFC03028),
    secondary: Color(0xFFD67873),
    text: Colors.white,
  ),
  'poison': PokemonTypeTheme(
    primary: Color(0xFFA040A0),
    secondary: Color(0xFFC183C1),
    text: Colors.white,
  ),
  'ground': PokemonTypeTheme(
    primary: Color(0xFFE0C068),
    secondary: Color(0xFFEBD69D),
    text: Colors.black,
  ),
  'flying': PokemonTypeTheme(
    primary: Color(0xFFA890F0),
    secondary: Color(0xFFC6B7F5),
    text: Colors.white,
  ),
  'psychic': PokemonTypeTheme(
    primary: Color(0xFFF85888),
    secondary: Color(0xFFFA92B2),
    text: Colors.white,
  ),
  'bug': PokemonTypeTheme(
    primary: Color(0xFFA8B820),
    secondary: Color(0xFFC6D16E),
    text: Colors.white,
  ),
  'rock': PokemonTypeTheme(
    primary: Color(0xFFB8A038),
    secondary: Color(0xFFD1C17D),
    text: Colors.white,
  ),
  'ghost': PokemonTypeTheme(
    primary: Color(0xFF705898),
    secondary: Color(0xFF9E96BC),
    text: Colors.white,
  ),
  'dragon': PokemonTypeTheme(
    primary: Color(0xFF7038F8),
    secondary: Color(0xFF9E86FA),
    text: Colors.white,
  ),
  'dark': PokemonTypeTheme(
    primary: Color(0xFF705848),
    secondary: Color(0xFF8E796B),
    text: Colors.white,
  ),
  'steel': PokemonTypeTheme(
    primary: Color(0xFFB8B8D0),
    secondary: Color(0xFFD1D1E0),
    text: Colors.black,
  ),
  'fairy': PokemonTypeTheme(
    primary: Color(0xFFEE99AC),
    secondary: Color(0xFFF4BDC9),
    text: Colors.black,
  ),
};

// Class to hold theme details for a Pokémon type
class PokemonTypeTheme {
  final Color primary; // Main color for app bar, buttons
  final Color secondary; // Accent color for cards, indicators
  final Color text; // Text color for elements on primary/secondary

  const PokemonTypeTheme({
    required this.primary,
    required this.secondary,
    required this.text,
  });
}

final statColors = {
  'hp': Colors.green,
  'attack': Colors.red,
  'defense': Colors.blue,
  'special-attack': Colors.orange,
  'special-defense': Colors.purple,
  'speed': Colors.yellow,
};

const typeColors = {
  'normal': Colors.brown,
  'fire': Colors.red,
  'water': Colors.blue,
  'grass': Colors.green,
  'electric': Colors.yellow,
  'ice': Colors.cyan,
  'fighting': Colors.orange,
  'poison': Colors.purple,
  'ground': Colors.brown,
  'flying': Colors.indigo,
  'psychic': Colors.pink,
  'bug': Colors.lightGreen,
  'rock': Colors.grey,
  'ghost': Colors.deepPurple,
  'dragon': Colors.indigo,
  'dark': Colors.black,
  'steel': Colors.blueGrey,
  'fairy': Colors.pinkAccent,
};

class PokemonDetails extends StatelessWidget {
  final Pokemon pokemon;
  const PokemonDetails(this.pokemon, {super.key});

  // Get the theme based on the Pokémon's primary type
  PokemonTypeTheme _getTheme() {
    final primaryTypeName = pokemon.types.first.type.name;
    return pokemonTypeThemes[primaryTypeName] ??
        const PokemonTypeTheme(
          primary: Colors.grey,
          secondary: Color(0xFFCCCCCC),
          text: Colors.white,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = _getTheme();

    return ChangeNotifierProvider<PokemonDetailsViewModel>(
      create:
          (context) => PokemonDetailsViewModel(
            context.read<PokemonRepository>(),
            pokemon,
          )..init(),
      child: Theme(
        // Create a themed context that will apply throughout the page
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: theme.primary,
            secondary: theme.secondary,
            onPrimary: theme.text,
            onSecondary: theme.text,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: theme.primary,
            foregroundColor: theme.text,
            elevation: 4,
            centerTitle: true,
            shadowColor: Colors.black26,
          ),
          cardTheme: CardTheme(
            elevation: 3,
            shadowColor: Colors.black38,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          progressIndicatorTheme: ProgressIndicatorThemeData(
            color: theme.primary,
            linearTrackColor: theme.secondary.withValues(alpha: 0.3),
          ),
          dividerTheme: DividerTheme.of(
            context,
          ).copyWith(color: theme.secondary),
        ),
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nº ${pokemon.id.toString().padLeft(4, '0')}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.text,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  pokemon.name.capitalize(),
                  style: TextStyle(color: theme.text),
                ),
              ],
            ),
          ),
          body: Consumer<PokemonDetailsViewModel>(
            builder: (context, viewModel, child) {
              return LegendaryMythicalEffectWidget(
                viewModel: viewModel,
                theme: theme,
                child: Container(
                  // Background gradient for the entire page
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.primary.withValues(alpha: 0.1),
                        Colors.white,
                      ],
                      stops: const [0.0, 0.3],
                    ),
                  ),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          HeaderWidget(pokemon, theme),
                          BasicInfoWidget(pokemon, viewModel, theme),
                          HeldItemsWidget(pokemon.heldItems, viewModel, theme),
                          TypeEffectivenessWidget(viewModel, theme),
                          StatsWidget(pokemon.stats),
                          AbilitiesWidget(pokemon.abilities, viewModel, theme),
                          CriesWidget(pokemon.cries, theme),
                          EvolutionChainWidget(viewModel),
                          MovesWidget(pokemon.moves, viewModel),
                          // Footer space for better scrolling UX
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
