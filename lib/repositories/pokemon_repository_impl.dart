import 'package:pokedex/pokeapi/entities/common.dart';
import 'package:pokedex/pokeapi/entities/evolution.dart';
import 'package:pokedex/pokeapi/entities/games.dart';
import 'package:pokedex/pokeapi/entities/items.dart';
import 'package:pokedex/pokeapi/entities/moves.dart';
import 'package:pokedex/pokeapi/entities/pokemon.dart';
import 'package:pokedex/pokeapi/pokeapi.dart';
import 'package:pokedex/repositories/pokemon_repository.dart';

class PokemonRepositoryImpl implements PokemonRepository {
  final PokeAPI _api;

  PokemonRepositoryImpl(this._api);

  @override
  Future<Pokemon> getPokemonDetailsByUrl(String url) async {
    return await _api.pokemon.getByUrl(url);
  }

  @override
  Future<NamedAPIResourceList> getAllPokemons() async {
    return await _api.pokemon.getAll();
  }

  @override
  Future<PokemonSpecies> getPokemonSpeciesByUrl(String url) async {
    return await _api.pokemonSpecies.getByUrl(url);
  }

  @override
  Future<Version> getGameVersionByUrl(String url) async {
    return await _api.version.getByUrl(url);
  }

  @override
  Future<EvolutionChain> getEvolutionChain(String url) async {
    return await _api.evolutionChain.getByUrl(url);
  }

  @override
  Future<Move> getMoveByUrl(String url) async {
    return await _api.move.getByUrl(url);
  }

  @override
  Future<Ability> getAbilityByUrl(String url) async {
    return await _api.ability.getByUrl(url);
  }

  @override
  Future<Type> getTypeByUrl(String url) async {
    return await _api.type.getByUrl(url);
  }

  @override
  Future<Item> getItemByUrl(String url) async {
    return await _api.item.getByUrl(url);
  }
}
