import 'package:flutter/widgets.dart';
import 'package:pokedex/pokeapi/entities/common.dart';
import 'package:pokedex/pokeapi/entities/games.dart';
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
    } catch (e, s) {
      logger.e(
        "Error fetching pokémon species details",
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
