import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:pokedex/pokeapi/entities/common.dart';
import 'package:pokedex/pokeapi/entities/evolution.dart';
import 'package:pokedex/pokeapi/entities/games.dart';
import 'package:pokedex/pokeapi/entities/moves.dart';
import 'package:pokedex/pokeapi/entities/pokemon.dart';
import 'package:pokedex/repositories/pokemon_repository.dart';
import 'package:pokedex/utils/logging.dart';
import 'package:pokedex/utils/string.dart';

class PokemonDetailsViewModel extends ChangeNotifier {
  final PokemonRepository _repository;
  final Pokemon pokemon;

  PokemonDetailsViewModel(this._repository, this.pokemon);

  bool isLoading = false;
  PokemonSpecies? _species;
  FlavorText? _selectedFlavorText;
  Version? _gameVersion;
  EvolutionChain? _evolutionChain;
  List<Pokemon> _pokemonEvolutionDetails = [];

  EvolutionChain? get evolutionChain => _evolutionChain;
  List<Pokemon> get pokemonEvolutionDetails => _pokemonEvolutionDetails;

  Future<void> init() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();

    try {
      _species = await _repository.getPokemonSpeciesByUrl(pokemon.species.url);
      _selectedFlavorText = _randomEnglishDescription();
      if (_selectedFlavorText?.version != null) {
        _gameVersion = await _repository.getGameVersionByUrl(
          _selectedFlavorText!.version!.url,
        );
      }
      if (_species?.evolutionChain != null) {
        _evolutionChain = await _repository.getEvolutionChain(
          _species!.evolutionChain!.url,
        );
        if (_evolutionChain != null) {
          _pokemonEvolutionDetails = await _fetchEvolutionChain(
            _evolutionChain!.chain,
          );
        }
      }
    } catch (e, s) {
      logger.e(
        "Error fetching pokémon species details for '${pokemon.name}'",
        error: e,
        stackTrace: s,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  FlavorText? _randomEnglishDescription() {
    if (_species == null) return null;
    return _species!.flavorTextEntries.isEmpty
        ? null
        : (_species!.flavorTextEntries
                .where((flavor) => flavor.language.name == 'en')
                .toList()
              ..shuffle())
            .first;
  }

  Future<List<Pokemon>> _fetchEvolutionChain(ChainLink startLink) async {
    List<Pokemon> result = [];
    Queue<ChainLink> queue = Queue.of([startLink]);
    Set<String> visiteUrls = {};

    logger.d("Fetching Pokémon evolution chain data!");
    while (queue.isNotEmpty) {
      final currentLink = queue.removeLast();
      if (!visiteUrls.contains(currentLink.species.url)) {
        visiteUrls.add(currentLink.species.url);
        try {
          if (_species!.name == currentLink.species.name) {
            result.add(pokemon);
          } else {
            final species = await _repository.getPokemonSpeciesByUrl(
              currentLink.species.url,
            );
            final pokemonUrl =
                species.varieties
                    .where((pokemon) => pokemon.isDefault)
                    .first
                    .pokemon
                    .url;
            result.add(await _repository.getPokemonDetailsByUrl(pokemonUrl));
          }
        } catch (e, s) {
          logger.e(
            "Could not fetch details for evolution stage: ${currentLink.species.name}",
            error: e,
            stackTrace: s,
          );
        }
        queue.addAll(currentLink.evolvesTo);
      }
    }

    return result;
  }

  Future<List<Move>> fetchMovesDetails(
    Iterable<PokemonMove> pokemonMoves,
  ) async {
    return Future.wait(
      pokemonMoves.map(
        (pokemonMove) => _repository.getMoveByUrl(pokemonMove.move.url),
      ),
    );
  }

  Future<List<Pokemon>> fetchPokemonsWithAbility(
    Iterable<AbilityPokemon> abilityPokemons,
  ) async {
    return Future.wait(
      abilityPokemons.map(
        (ability) => _repository.getPokemonDetailsByUrl(ability.pokemon.url),
      ),
    );
  }

  Future<Ability> fetchAbility(PokemonAbility ability) async {
    return await _repository.getAbilityByUrl(ability.ability.url);
  }

  String get pokemonDescription {
    if (_selectedFlavorText != null) {
      final gameVersionName =
          _gameVersion?.names
              .where((version) => version.language.name == 'en')
              .first
              .name;

      return '${_selectedFlavorText!.flavorText.sanitize()}\n― Pokémon ${gameVersionName!}';
    }
    return 'No description found.';
  }
}
