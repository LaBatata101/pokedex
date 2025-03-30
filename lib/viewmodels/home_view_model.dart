import 'package:flutter/material.dart';
import 'package:pokedex/pokeapi/entities/common.dart';
import 'package:pokedex/pokeapi/pokeapi.dart';

class HomeViewModel extends ChangeNotifier {
  final PokeAPI api;
  List<NamedAPIResource> allPokemonResources = [];
  List<NamedAPIResource> displayedPokemon = [];
  String searhQuery = '';
  int pageSize = 20;
  int currentPage = 0;
  bool isLoading = false;
  String errorMsg = '';

  HomeViewModel(this.api);

  Future<void> init() async {
    isLoading = true;
    notifyListeners();
    try {
      final list = await api.pokemon.getAll();
      allPokemonResources = list.results;
      displayedPokemon = allPokemonResources.take(pageSize).toList();
      currentPage = 1;
    } catch (e) {
      errorMsg = 'Error initializing Pokémon data: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void onSearchChanged(String query) {
    searhQuery = query.trim();
    if (searhQuery.isEmpty) {
      displayedPokemon = allPokemonResources.take(pageSize).toList();
      currentPage = 1;
    } else {
      displayedPokemon =
          allPokemonResources
              .where(
                (p) => p.name.toLowerCase().contains(searhQuery.toLowerCase()),
              )
              .toList();
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (searhQuery.isNotEmpty || isLoading) return;
    // No more items
    if (currentPage * pageSize >= allPokemonResources.length) return;

    isLoading = true;
    notifyListeners();
    try {
      final nextPage = allPokemonResources
          .skip(currentPage * pageSize)
          .take(pageSize);
      displayedPokemon.addAll(nextPage);
      currentPage++;
    } catch (e) {
      errorMsg = 'Error loading more Pokémon: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
