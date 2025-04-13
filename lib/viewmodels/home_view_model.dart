import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pokedex/pokeapi/entities/common.dart';
import 'package:pokedex/pokeapi/entities/pokemon.dart';
import 'package:pokedex/repositories/pokemon_repository.dart';
import 'package:pokedex/utils/logging.dart';
import 'package:pokedex/utils/string.dart';

class HomeViewModel extends ChangeNotifier {
  final PokemonRepository repository;
  List<NamedAPIResource> allPokemonResources = [];
  List<NamedAPIResource> _filteredPokemonResources = [];
  List<NamedAPIResource> displayedPokemon = [];
  String searchQuery = '';
  int pageSize = 20;
  int currentPage = 0;
  bool isLoading = false;
  bool _isDisposed = false;
  String errorMsg = '';

  List<Type> selectedTypes = [];
  bool isTypesLoading = false;
  List<Type> availableTypes = [];

  Timer? _debounceTimer;

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
    _filteredPokemonResources = [];

    if (!_isDisposed) notifyListeners();

    try {
      final list = await repository.getAllPokemons();
      allPokemonResources = list.results;
      displayedPokemon = allPokemonResources.take(pageSize).toList();
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
    var filteredList = allPokemonResources;

    // Apply search filter if search query exists
    if (queryNormalized.isNotEmpty) {
      filteredList =
          filteredList
              .where((p) => p.name.toLowerCase().contains(queryNormalized))
              .toList();
    }

    _filteredPokemonResources = filteredList;
    logger.i("Total Filtered By Search: ${_filteredPokemonResources.length}");

    displayedPokemon = _filteredPokemonResources.take(pageSize).toList();
    currentPage = 1;

    isLoading = false;
    if (!_isDisposed) notifyListeners();
  }

  Future<void> loadMore() async {
    if (isLoading || _isDisposed) return;

    final bool isSearching = searchQuery.trim().isNotEmpty;
    final List<NamedAPIResource> sourceList =
        isSearching ? _filteredPokemonResources : allPokemonResources;
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
      final nextPage = sourceList.skip(currentItemCount).take(pageSize);

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

  Future<void> applyTypeFiltering() async {
    if (selectedTypes.isEmpty) {
      init().whenComplete(() => _applySearchFilter());
      return;
    }

    isLoading = true;
    if (!_isDisposed) notifyListeners();

    logger.i(
      "Filtering pokémons with types: ${selectedTypes.map((type) => type.name.capitalize()).join(', ')}",
    );
    try {
      var seenPokemons = <String>{};
      List<NamedAPIResource> pokemonFilteredByType = [];

      for (final typePokemon in selectedTypes
          .map((type) => type.pokemon)
          .expand((typePokemonList) => typePokemonList)) {
        if (seenPokemons.add(typePokemon.pokemon.url)) {
          pokemonFilteredByType.add(typePokemon.pokemon);
        }
      }
      logger.i("Total Filtered By Type: ${pokemonFilteredByType.length}");

      pokemonFilteredByType.sort((a, b) {
        final idA = _extractIdFromUrl(a.url);
        final idB = _extractIdFromUrl(b.url);

        // Handle cases where ID might not be extractable (put nulls last)
        if (idA == null && idB == null) return 0;
        if (idA == null) return 1; // Treat null ID as greater
        if (idB == null) return -1; // Treat null ID as greater
        return idA.compareTo(idB);
      });

      if (searchQuery.trim().isNotEmpty) {
        allPokemonResources =
            pokemonFilteredByType
                .where(
                  (pokemon) =>
                      pokemon.name.contains(searchQuery.trim().toLowerCase()),
                )
                .toList();
        logger.i("Total Filtered By Search: ${allPokemonResources.length}");
      } else {
        allPokemonResources = pokemonFilteredByType;
      }

      displayedPokemon = allPokemonResources.take(pageSize).toList();
    } catch (e, s) {
      logger.e("Error applying type filters", error: e, stackTrace: s);
      errorMsg = "Error applying type filters $e";
    } finally {
      isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  void setSelectedTypes(List<Type> types) {
    selectedTypes = types;
    applyTypeFiltering();
  }

  bool isPokemonOfTypes(Pokemon pokemon, List<String> types) {
    if (types.isEmpty) return true;

    return pokemon.types.any(
      (pokemonType) => types.contains(pokemonType.type.name.toLowerCase()),
    );
  }
}
