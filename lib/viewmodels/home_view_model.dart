import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pokedex/pokeapi/entities/common.dart';
import 'package:pokedex/repositories/pokemon_repository.dart';
import 'package:pokedex/utils/logging.dart';

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
      _applyFilter();
    } else {
      // Execute the search after 600ms with no typing
      _debounceTimer = Timer(const Duration(milliseconds: 600), () {
        if (searchQuery != query) {
          searchQuery = query;
          logger.d("Debounced search executing for query: $searchQuery");
          _applyFilter();
        }
      });
    }
  }

  void _applyFilter() {
    if (isLoading) return;
    isLoading = true;
    if (!_isDisposed) notifyListeners();

    final queryNormalized = searchQuery.trim().toLowerCase();
    if (queryNormalized.isEmpty) {
      displayedPokemon = allPokemonResources.take(pageSize).toList();
      currentPage = 1;
    } else {
      _filteredPokemonResources =
          allPokemonResources
              .where((p) => p.name.toLowerCase().contains(searchQuery))
              .toList();
      displayedPokemon = _filteredPokemonResources.take(pageSize).toList();
      currentPage = 1;
    }
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
}
