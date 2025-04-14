import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pokedex/pokeapi/entities/common.dart';
import 'package:pokedex/pokeapi/entities/games.dart';
import 'package:pokedex/pokeapi/entities/pokemon.dart';
import 'package:pokedex/repositories/pokemon_repository.dart';
import 'package:pokedex/utils/logging.dart';

class HomeViewModel extends ChangeNotifier {
  final PokemonRepository repository;

  /// Holds the original, complete list fetched from the repository.
  List<NamedAPIResource> _basePokemonList = [];

  /// Holds the currently filtered and sorted list, used for pagination and display.
  List<NamedAPIResource> _currentFilteredList = [];

  List<NamedAPIResource> displayedPokemon = [];
  String searchQuery = '';
  int pageSize = 20;
  int _currentPage = 0;
  bool isLoading = false;
  bool _isDisposed = false;
  String errorMsg = '';

  List<Type> selectedTypes = [];
  List<Generation> selectedGenerations = [];

  bool isTypesLoading = false;
  bool isGenerationsLoading = false;

  List<Type> availableTypes = [];
  List<Generation> availableGenerations = [];

  Timer? _debounceTimer;

  int get totalPokemonCount => _currentFilteredList.length;

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
    _basePokemonList = [];
    _currentFilteredList = [];

    if (!_isDisposed) notifyListeners();

    try {
      final list = await repository.getAllPokemons();
      _basePokemonList = list.results;

      _currentFilteredList = List.from(_basePokemonList);
      _updateDisplayedPokemonPage();
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

  Future<void> loadMore() async {
    if (isLoading || _isDisposed) return;

    final int totalAvailableItems = _currentFilteredList.length;
    final currentItemCount = displayedPokemon.length;

    // No more items to display
    if (currentItemCount >= totalAvailableItems) {
      logger.i(
        "No more items to load"
        " (Displayed: $currentItemCount, Total: $totalAvailableItems).",
      );
      return;
    }

    isLoading = true;
    if (!_isDisposed) notifyListeners();

    logger.i(
      "Loading more items (Page ${_currentPage + 1})..."
      " Current count: $currentItemCount, Total available: $totalAvailableItems",
    );

    try {
      final nextPageItems = _currentFilteredList
          .skip(currentItemCount)
          .take(pageSize);

      if (nextPageItems.isNotEmpty) {
        displayedPokemon.addAll(nextPageItems);
        _currentPage++;
        logger.i(
          "Loaded ${nextPageItems.length} more items. New display count: ${displayedPokemon.length}."
          " Current Page: $_currentPage",
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
    logger.d(
      "Applying filters - "
      "${selectedTypes.isEmpty ? '' : '${selectedTypes.map((type) => type.name).join(', ')} | '}"
      "${selectedGenerations.isEmpty ? '' : selectedGenerations.map((generation) => generation.name).join(', ')}",
    );

    _updateFilteredPokemonList();
  }

  void onSearchChanged(String query) {
    // Cancel previous timer if it exists and is active
    _debounceTimer?.cancel();
    // Execute the search after 600ms with no typing
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      final normalizedQuery = query.trim().toLowerCase();
      if (searchQuery != normalizedQuery) {
        searchQuery = normalizedQuery;
        logger.d("Debounced search executing for query: $searchQuery");
        _updateFilteredPokemonList();
      }
    });
  }

  void _updateFilteredPokemonList() {
    if (isLoading) return;
    isLoading = true;

    if (!_isDisposed) notifyListeners();

    List<NamedAPIResource> result = List.from(_basePokemonList);

    // Apply generation filter
    if (selectedGenerations.isNotEmpty) {
      final genPokemonUrls =
          selectedGenerations
              .map((g) => g.pokemonSpecies)
              .expand((speciesList) => speciesList)
              .map(
                (species) => species.url.replaceAll('-species', ''),
              ) // Get pokemon URL
              .toSet();

      result = result.where((p) => genPokemonUrls.contains(p.url)).toList();
      logger.i("After Generation Filter: ${result.length}");
    }

    // Apply type filter
    if (selectedTypes.isNotEmpty) {
      final Set<String> typePokemonUrls = {};
      for (final type in selectedTypes) {
        for (final typePokemon in type.pokemon) {
          typePokemonUrls.add(typePokemon.pokemon.url);
        }
      }
      result = result.where((p) => typePokemonUrls.contains(p.url)).toList();
      logger.i("After Type Filter: ${result.length}");
    }

    result.sort(_sortPokemonById);

    // Apply Search Filter (to the type/gen filtered and sorted list)
    final queryNormalized = searchQuery.trim().toLowerCase();
    if (queryNormalized.isNotEmpty) {
      result =
          result
              .where((p) => p.name.toLowerCase().contains(queryNormalized))
              .toList();
      logger.i("After Search Filter: ${result.length}");
    }

    // Update the list used for display and pagination
    _currentFilteredList = result;

    _currentPage = 0;
    _updateDisplayedPokemonPage();

    isLoading = false;
    if (!_isDisposed) notifyListeners();
  }

  void _updateDisplayedPokemonPage() {
    final startIndex = _currentPage * pageSize;
    if (startIndex < _currentFilteredList.length) {
      displayedPokemon =
          _currentFilteredList.skip(startIndex).take(pageSize).toList();
    }
  }

  int _sortPokemonById(NamedAPIResource a, NamedAPIResource b) {
    final idA = _extractIdFromUrl(a.url);
    final idB = _extractIdFromUrl(b.url);

    // Handle cases where ID might not be extractable (put nulls last)
    if (idA == null && idB == null) return 0;
    if (idA == null) return 1; // Treat null ID as greater
    if (idB == null) return -1; // Treat null ID as greater
    return idA.compareTo(idB);
  }

  void clearFilters() {
    selectedTypes = [];
    selectedGenerations = [];

    logger.d("Cleared all filters.");
    _updateFilteredPokemonList();
  }

  void removeTypeFilter(Type type) {
    if (selectedTypes.remove(type)) {
      logger.d("Removed type filter: ${type.name}");
      _updateFilteredPokemonList(); // Re-apply remaining filters
    }
  }

  void removeGenerationFilter(Generation gen) {
    if (selectedGenerations.remove(gen)) {
      logger.d("Removed generation filter: ${gen.name}");
      _updateFilteredPokemonList(); // Re-apply remaining filters
    }
  }

  bool isPokemonOfTypes(Pokemon pokemon, List<String> types) {
    if (types.isEmpty) return true;

    return pokemon.types.any(
      (pokemonType) => types.contains(pokemonType.type.name.toLowerCase()),
    );
  }
}
