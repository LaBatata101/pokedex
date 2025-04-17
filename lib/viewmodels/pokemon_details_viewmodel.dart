import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:pokedex/pokeapi/entities/common.dart';
import 'package:pokedex/pokeapi/entities/evolution.dart';
import 'package:pokedex/pokeapi/entities/games.dart';
import 'package:pokedex/pokeapi/entities/items.dart';
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

  bool _isLoadingTypeEffectiveness = false;

  String? errorMsg;

  // Defensive effectiveness
  List<String> _quadrupleDamageFrom = [];
  List<String> _doubleDamageFrom = [];
  List<String> _halfDamageFrom = [];
  List<String> _quarterDamageFrom = [];
  List<String> _noDamageFrom = [];

  // Offensive effectiveness
  List<String> _doubleDamageTo = [];
  List<String> _halfDamageTo = [];
  List<String> _noDamageTo = [];

  bool get isLegendary => _species?.isLegendary ?? false;
  bool get isMythical => _species?.isMythical ?? false;

  int? get captureRate => _species?.captureRate;
  int? get baseHappiness => _species?.baseHappiness;
  NamedAPIResource? get growthRate => _species?.growthRate;
  NamedAPIResource? get habitat => _species?.habitat;

  EvolutionChain? get evolutionChain => _evolutionChain;
  List<Pokemon> get pokemonEvolutionDetails => _pokemonEvolutionDetails;

  bool get isLoadingTypeEffectiveness => _isLoadingTypeEffectiveness;
  List<String> get quadrupleDamageFrom => _quadrupleDamageFrom;
  List<String> get doubleDamageFrom => _doubleDamageFrom;
  List<String> get halfDamageFrom => _halfDamageFrom;
  List<String> get quarterDamageFrom => _quarterDamageFrom;
  List<String> get noDamageFrom => _noDamageFrom;
  List<String> get doubleDamageTo => _doubleDamageTo;
  List<String> get halfDamageTo => _halfDamageTo;
  List<String> get noDamageTo => _noDamageTo;

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
      errorMsg = "Error fetching pokémon details: $e";
    } finally {
      isLoading = false;
      notifyListeners();
      _fetchTypeEffectiveness();
    }
  }

  Future<void> retry() async {
    errorMsg = null;
    _pokemonEvolutionDetails = [];
    _quadrupleDamageFrom = [];
    _doubleDamageFrom = [];
    _halfDamageFrom = [];
    _quarterDamageFrom = [];
    _noDamageFrom = [];
    _doubleDamageTo = [];
    _halfDamageTo = [];
    _noDamageTo = [];
    await init();
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
      if (visiteUrls.add(currentLink.species.url)) {
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

  Future<void> _fetchTypeEffectiveness() async {
    if (_isLoadingTypeEffectiveness) return;
    _isLoadingTypeEffectiveness = true;
    notifyListeners();

    try {
      final typeEffectiveness = await Future.wait(
        pokemon.types.map((type) => _repository.getTypeByUrl(type.type.url)),
      );

      Map<String, double> defensiveMap = {};
      Map<String, double> offensiveMap = {};

      // For each of the pokemon's types, get damage relations and combine them
      for (final typeData in typeEffectiveness) {
        // Process defensive damage relations
        for (final damageType in typeData.damageRelations.doubleDamageFrom) {
          defensiveMap[damageType.name] =
              (defensiveMap[damageType.name] ?? 1.0) * 2.0;
        }

        for (final damageType in typeData.damageRelations.halfDamageFrom) {
          defensiveMap[damageType.name] =
              (defensiveMap[damageType.name] ?? 1.0) * 0.5;
        }

        for (final damageType in typeData.damageRelations.noDamageFrom) {
          defensiveMap[damageType.name] = 0.0;
        }

        // Process offensive damage relations
        for (final damageType in typeData.damageRelations.doubleDamageTo) {
          offensiveMap[damageType.name] =
              (offensiveMap[damageType.name] ?? 1.0) * 2.0;
        }

        for (final damageType in typeData.damageRelations.halfDamageTo) {
          offensiveMap[damageType.name] =
              (offensiveMap[damageType.name] ?? 1.0) * 0.5;
        }

        for (final damageType in typeData.damageRelations.noDamageTo) {
          offensiveMap[damageType.name] = 0.0;
        }
      }

      // Sort types into appropriate lists based on calculated multipliers
      defensiveMap.forEach((type, multiplier) {
        if (multiplier == 4.0) {
          _quadrupleDamageFrom.add(type);
        } else if (multiplier == 2.0) {
          _doubleDamageFrom.add(type);
        } else if (multiplier == 0.5) {
          _halfDamageFrom.add(type);
        } else if (multiplier == 0.25) {
          _quarterDamageFrom.add(type);
        } else if (multiplier == 0.0) {
          _noDamageFrom.add(type);
        }
      });

      offensiveMap.forEach((type, multiplier) {
        if (multiplier == 2.0 || multiplier == 4.0) {
          _doubleDamageTo.add(type);
        } else if (multiplier == 0.5 || multiplier == 0.25) {
          _halfDamageTo.add(type);
        } else if (multiplier == 0.0) {
          _noDamageTo.add(type);
        }
      });

      // Sort lists alphabetically for consistent display
      _quadrupleDamageFrom.sort();
      _doubleDamageFrom.sort();
      _halfDamageFrom.sort();
      _quarterDamageFrom.sort();
      _noDamageFrom.sort();
      _doubleDamageTo.sort();
      _halfDamageTo.sort();
      _noDamageTo.sort();

      _isLoadingTypeEffectiveness = false;
    } catch (e, s) {
      logger.e("Error fetching types information", error: e, stackTrace: s);
    } finally {
      _isLoadingTypeEffectiveness = false;
      notifyListeners();
    }
  }

  Future<Ability> fetchAbility(PokemonAbility ability) async {
    return await _repository.getAbilityByUrl(ability.ability.url);
  }

  Future<Item> fetchPokemonItem(PokemonHeldItem heldItem) async {
    return await _repository.getItemByUrl(heldItem.item.url);
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

  String get pokemonGeneration {
    if (_species != null) {
      final generationParts = _species!.generation.name.split('-');
      return '${generationParts[0].capitalize()} ${generationParts[1].toUpperCase()}';
    }
    return 'N/A';
  }
}
