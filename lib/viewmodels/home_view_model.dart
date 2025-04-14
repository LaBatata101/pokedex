import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pokedex/pokeapi/entities/common.dart';
import 'package:pokedex/pokeapi/entities/games.dart';
import 'package:pokedex/pokeapi/entities/pokemon.dart';
import 'package:pokedex/repositories/pokemon_repository.dart';
import 'package:pokedex/utils/logging.dart';
import 'package:pokedex/utils/string.dart';

enum _PokemonType {
  normal,
  fire,
  water,
  grass,
  electric,
  ice,
  fighting,
  poison,
  ground,
  flying,
  bug,
  rock,
  ghost,
  dragon,
  dark,
  steel,
  fairy,
  stellar,
  shadow,
  unknown,

  /// Special case
  any;

  factory _PokemonType.fromStr(String type) {
    switch (type) {
      case "normal":
        return normal;
      case "fire":
        return fire;
      case "water":
        return water;
      case "grass":
        return grass;
      case "electric":
        return electric;
      case "ice":
        return ice;
      case "fighting":
        return fighting;
      case "poison":
        return poison;
      case "ground":
        return ground;
      case "flying":
        return flying;
      case "bug":
        return bug;
      case "rock":
        return rock;
      case "ghost":
        return ghost;
      case "dragon":
        return dragon;
      case "dark":
        return dark;
      case "steel":
        return steel;
      case "fairy":
        return fairy;
      case "stellar":
        return stellar;
      case "shadow":
        return shadow;
      case "unknow":
        return unknown;

      default:
        throw Exception("Unknown pokémon type '$type'!");
    }
  }
}

enum _PokemonGeneration {
  first,
  second,
  third,
  fourth,
  fifth,
  sixth,
  seventh,
  eighth,
  ninth,

  /// Special case
  any;

  factory _PokemonGeneration.fromStr(String generation) {
    switch (generation) {
      case 'generation-i':
        return first;
      case 'generation-ii':
        return second;
      case 'generation-iii':
        return third;
      case 'generation-iv':
        return fourth;
      case 'generation-v':
        return fifth;
      case 'generation-vi':
        return sixth;
      case 'generation-vii':
        return seventh;
      case 'generation-viii':
        return eighth;
      case 'generation-ix':
        return ninth;
      default:
        throw Exception("Unknown pokémon generation '$generation'!");
    }
  }
}

class _PokemonResource {
  final NamedAPIResource resource;
  final _PokemonType type;
  final _PokemonGeneration generation;

  const _PokemonResource(
    this.resource, {
    this.type = _PokemonType.any,
    this.generation = _PokemonGeneration.any,
  });

  @override
  String toString() {
    return "_PokemonResource($resource, type: $type, generation: $generation)";
  }
}

class HomeViewModel extends ChangeNotifier {
  final PokemonRepository repository;
  List<_PokemonResource> _allPokemonResources = [];
  List<_PokemonResource> _pokemonsFilteredBySearch = [];
  List<NamedAPIResource> displayedPokemon = [];
  String searchQuery = '';
  int pageSize = 20;
  int currentPage = 0;
  bool isLoading = false;
  bool _isDisposed = false;
  String errorMsg = '';

  List<Type> selectedTypes = [];
  List<Generation> selectedGenerations = [];
  bool isTypesLoading = false;
  bool isGenerationsLoading = false;
  List<Type> availableTypes = [];
  List<Generation> availableGenerations = [];
  List<_PokemonResource> _pokemonsFilteredByType = [];
  List<_PokemonResource> _pokemonsFilteredByGen = [];

  Timer? _debounceTimer;

  int get totalPokemonCount => _allPokemonResources.length;

  HomeViewModel(this.repository);

  @override
  void dispose() {
    _isDisposed = true;
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> init() async {
    if (isLoading) return;

    isLoading = true;
    errorMsg = '';
    _pokemonsFilteredBySearch = [];

    if (!_isDisposed) notifyListeners();

    try {
      final list = await repository.getAllPokemons();
      _allPokemonResources =
          list.results.map((resource) => _PokemonResource(resource)).toList();
      displayedPokemon =
          _allPokemonResources
              .take(pageSize)
              .map((pokemonResource) => pokemonResource.resource)
              .toList();
      currentPage = 1;
    } catch (e, s) {
      logger.e("Error initializing Pokémon data", error: e, stackTrace: s);
      if (!_isDisposed) errorMsg = 'Error initializing Pokémon data: $e';
    } finally {
      if (!_isDisposed) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  void onSearchChanged(String query) {
    // Cancel previous timer if it exists and is active
    _debounceTimer?.cancel();

    // clear the search if the current search is empty and the
    // previous search was not empty.
    if (query.trim().isEmpty && searchQuery.isNotEmpty) {
      searchQuery = "";
      _applySearchFilter();
    } else {
      // Execute the search after 600ms with no typing
      _debounceTimer = Timer(const Duration(milliseconds: 600), () {
        final normalizedQuery = query.trim().toLowerCase();
        if (searchQuery != normalizedQuery) {
          searchQuery = normalizedQuery;
          logger.d("Debounced search executing for query: $searchQuery");
          _applySearchFilter();
        }
      });
    }
  }

  void _applySearchFilter() {
    if (isLoading) return;
    isLoading = true;
    if (!_isDisposed) notifyListeners();

    final queryNormalized = searchQuery.trim().toLowerCase();
    var filteredList = _allPokemonResources;

    // Apply search filter if search query exists
    if (queryNormalized.isNotEmpty) {
      filteredList =
          filteredList
              .where(
                (p) => p.resource.name.toLowerCase().contains(queryNormalized),
              )
              .toList();
    }

    _pokemonsFilteredBySearch = filteredList;
    logger.i("Total Filtered By Search: ${_pokemonsFilteredBySearch.length}");

    displayedPokemon =
        _pokemonsFilteredBySearch
            .take(pageSize)
            .map((pokemonResource) => pokemonResource.resource)
            .toList();
    currentPage = 1;

    isLoading = false;
    if (!_isDisposed) notifyListeners();
  }

  Future<void> loadMore() async {
    if (isLoading || _isDisposed) return;

    final bool isSearching = searchQuery.trim().isNotEmpty;
    final List<_PokemonResource> sourceList =
        isSearching ? _pokemonsFilteredBySearch : _allPokemonResources;
    final int totalAvailableItems = sourceList.length;
    final currentItemCount = displayedPokemon.length;

    // No more items to display
    if (currentItemCount >= totalAvailableItems) {
      logger.i(
        "No more items to load for ${isSearching ? 'search results' : 'full list'}"
        " (Displayed: $currentItemCount, Total: $totalAvailableItems).",
      );
      return;
    }

    isLoading = true;
    if (!_isDisposed) notifyListeners();

    logger.i(
      "Loading more items (Page ${currentPage + 1}) for ${isSearching ? 'search results' : 'full list'}..."
      " Current count: $currentItemCount, Total available: $totalAvailableItems",
    );

    try {
      final nextPage = sourceList
          .skip(currentItemCount)
          .take(pageSize)
          .map((pokemonResource) => pokemonResource.resource);

      if (nextPage.isNotEmpty) {
        displayedPokemon.addAll(nextPage);
        currentPage++;
        logger.i(
          "Loaded ${nextPage.length} more items. New display count: ${displayedPokemon.length}."
          " Current Page: $currentPage",
        );
      } else {
        logger.d(
          "Load more called but nextPageItems was empty (Shouldn't happen if previous guards are correct).",
        );
      }
    } catch (e, s) {
      logger.e("Error loading more Pokémon", error: e, stackTrace: s);
      errorMsg = 'Error loading more Pokémon: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPokemonTypes() async {
    if (isTypesLoading || availableTypes.isNotEmpty) return;

    isTypesLoading = true;
    if (!_isDisposed) notifyListeners();
    logger.d("loading pokemon types");
    try {
      final allTypes = await repository.getAllTypes();
      availableTypes = await Future.wait(
        allTypes.results.map((type) => repository.getTypeByUrl(type.url)),
      );
    } catch (e, s) {
      logger.e("Error loading Pokémon types", error: e, stackTrace: s);
      errorMsg = 'Error loading Pokémon types: $e';
    } finally {
      isTypesLoading = false;
      logger.d("finished loading pokemon types");
      if (!_isDisposed) notifyListeners();
    }
  }

  Future<void> loadPokemonGenerations() async {
    if (isGenerationsLoading || availableGenerations.isNotEmpty) return;

    isGenerationsLoading = true;
    if (!_isDisposed) notifyListeners();
    try {
      final allGenerations = await repository.getAllGenerations();
      availableGenerations = await Future.wait(
        allGenerations.results.map(
          (generation) => repository.getGenerationByUrl(generation.url),
        ),
      );
    } catch (e, s) {
      logger.e(
        "Error loading Pokémon generation data",
        error: e,
        stackTrace: s,
      );
      errorMsg = 'Error loading generation data: $e';
    } finally {
      isGenerationsLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  int? _extractIdFromUrl(String url) {
    final uri = Uri.parse(url);
    // Get non-empty path segments (e.g., ['api', 'v2', 'pokemon', '25'])
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    // Check if the second-to-last segment is 'pokemon' and the last is a number
    if (segments.length >= 2 && segments[segments.length - 2] == 'pokemon') {
      return int.tryParse(segments.last);
    }
    logger.w("Could not extract ID from URL: $url");
    return null;
  }

  void applyFilters(List<Type> types, List<Generation> generations) {
    selectedGenerations = generations;
    selectedTypes = types;

    isLoading = true;
    if (!_isDisposed) notifyListeners();

    if (generations.isNotEmpty) {
      _applyGenerationFilter();
    }
    if (types.isNotEmpty) {
      _applyTypeFilter();
    }

    _allPokemonResources.sort((a, b) {
      final idA = _extractIdFromUrl(a.resource.url);
      final idB = _extractIdFromUrl(b.resource.url);

      // Handle cases where ID might not be extractable (put nulls last)
      if (idA == null && idB == null) return 0;
      if (idA == null) return 1; // Treat null ID as greater
      if (idB == null) return -1; // Treat null ID as greater
      return idA.compareTo(idB);
    });
    displayedPokemon =
        _allPokemonResources
            .take(pageSize)
            .map((pokemonResource) => pokemonResource.resource)
            .toList();

    isLoading = false;
    if (!_isDisposed) notifyListeners();
  }

  void clearFilters() {
    selectedTypes = [];
    selectedGenerations = [];
    _pokemonsFilteredByGen = [];
    _pokemonsFilteredByType = [];
    init().whenComplete(() => _applySearchFilter());
  }

  void removeTypeFilter(Type type) {
    logger.d("Removed type ${type.name} filter");
    selectedTypes.remove(type);
    final removedType = _PokemonType.fromStr(type.name);
    _pokemonsFilteredByType =
        _pokemonsFilteredByType
            .where((pokemonResource) => pokemonResource.type != removedType)
            .toList();

    // Case where no type filters are active but we still have generation filters active
    if (selectedTypes.isEmpty && selectedGenerations.isNotEmpty) {
      _allPokemonResources = _pokemonsFilteredByGen;
    }
    // Case where no generation filters are active but we still have type filters active
    else if (selectedTypes.isNotEmpty && selectedGenerations.isEmpty) {
      // keep just the pokemons filtered by type
      _allPokemonResources = _pokemonsFilteredByType;
    }
    // Case where there is a type and generation filter active
    else if (selectedTypes.isNotEmpty && selectedGenerations.isNotEmpty) {
      // remove just the pokemons with specific type
      _allPokemonResources =
          _allPokemonResources
              .where((pokemonResource) => pokemonResource.type != removedType)
              .toList();
    }
    // Case where no type and generation filters are active
    else if (selectedTypes.isEmpty && selectedGenerations.isEmpty) {
      // Reset the list
      init();
      return;
    }

    _allPokemonResources.sort((a, b) {
      final idA = _extractIdFromUrl(a.resource.url);
      final idB = _extractIdFromUrl(b.resource.url);

      // Handle cases where ID might not be extractable (put nulls last)
      if (idA == null && idB == null) return 0;
      if (idA == null) return 1; // Treat null ID as greater
      if (idB == null) return -1; // Treat null ID as greater
      return idA.compareTo(idB);
    });

    displayedPokemon =
        _allPokemonResources
            .take(pageSize)
            .map((pokemonResource) => pokemonResource.resource)
            .toList();
    if (!_isDisposed) notifyListeners();
  }

  void removeGenerationFilter(Generation gen) {
    logger.d("Removed ${gen.name} filter");
    selectedGenerations.remove(gen);
    final removedGen = _PokemonGeneration.fromStr(gen.name);
    _pokemonsFilteredByGen =
        _pokemonsFilteredByGen
            .where(
              (pokemonResource) => pokemonResource.generation != removedGen,
            )
            .toList();

    // Case where no type filters are active but we still have generation filters active
    if (selectedTypes.isEmpty && selectedGenerations.isNotEmpty) {
      _allPokemonResources = _pokemonsFilteredByGen;
    }
    // Case where no generation filters are active but we still have type filters active
    else if (selectedTypes.isNotEmpty && selectedGenerations.isEmpty) {
      // keep just the pokemons filtered by type
      _allPokemonResources = _pokemonsFilteredByType;
    }
    // Case where there is a type and generation filter active
    else if (selectedTypes.isNotEmpty && selectedGenerations.isNotEmpty) {
      // remove just the pokemons with specific generation
      _allPokemonResources =
          _allPokemonResources
              .where(
                (pokemonResource) => pokemonResource.generation != removedGen,
              )
              .toList();
    }
    // Case where no type and generation filters are active
    else if (selectedTypes.isEmpty && selectedGenerations.isEmpty) {
      // Reset the list
      init();
      return;
    }

    _allPokemonResources.sort((a, b) {
      final idA = _extractIdFromUrl(a.resource.url);
      final idB = _extractIdFromUrl(b.resource.url);

      // Handle cases where ID might not be extractable (put nulls last)
      if (idA == null && idB == null) return 0;
      if (idA == null) return 1; // Treat null ID as greater
      if (idB == null) return -1; // Treat null ID as greater
      return idA.compareTo(idB);
    });

    displayedPokemon =
        _allPokemonResources
            .take(pageSize)
            .map((pokemonResource) => pokemonResource.resource)
            .toList();
    if (!_isDisposed) notifyListeners();
  }

  void _applyGenerationFilter() {
    _pokemonsFilteredByGen = [];
    logger.i(
      "Filtering pokémons from generations: ${selectedGenerations.map((generation) => generation.name.capitalize()).join(', ')}",
    );
    for (final generation in selectedGenerations) {
      for (final pokemonSpecies in generation.pokemonSpecies) {
        _pokemonsFilteredByGen.add(
          _PokemonResource(
            NamedAPIResource(
              name: pokemonSpecies.name,
              url: pokemonSpecies.url.replaceAll('-species', ''),
            ),
            generation: _PokemonGeneration.fromStr(generation.name),
          ),
        );
      }
    }
    _allPokemonResources = _pokemonsFilteredByGen;
    logger.i("Total Filterd By Generation: ${_allPokemonResources.length}");
  }

  void _applyTypeFilter() {
    _pokemonsFilteredByType = [];
    logger.i(
      "Filtering pokémons with types: ${selectedTypes.map((type) => type.name.capitalize()).join(', ')}",
    );
    var seenPokemons = <String>{};

    for (final type in selectedTypes) {
      for (final typePokemon in type.pokemon) {
        if (seenPokemons.add(typePokemon.pokemon.url)) {
          _pokemonsFilteredByType.add(
            _PokemonResource(
              typePokemon.pokemon,
              type: _PokemonType.fromStr(type.name),
            ),
          );
        }
      }
    }

    if (selectedGenerations.isNotEmpty) {
      _allPokemonResources =
          _pokemonsFilteredByGen
              .where(
                (pokemon) => _pokemonsFilteredByType
                    .map((pokemonResource) => pokemonResource.resource.name)
                    .contains(pokemon.resource.name),
              )
              .toList();
    } else {
      _allPokemonResources = _pokemonsFilteredByType;
    }
    logger.i("Total Filtered By Type: ${_allPokemonResources.length}");
  }

  bool isPokemonOfTypes(Pokemon pokemon, List<String> types) {
    if (types.isEmpty) return true;

    return pokemon.types.any(
      (pokemonType) => types.contains(pokemonType.type.name.toLowerCase()),
    );
  }
}
