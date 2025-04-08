import 'package:pokedex/pokeapi/entities/common.dart';
import 'package:pokedex/pokeapi/entities/evolution.dart';
import 'package:pokedex/pokeapi/entities/games.dart';
import 'package:pokedex/pokeapi/entities/pokemon.dart';

abstract class PokemonRepository {
  Future<Pokemon> getPokemonDetailsByUrl(String url);
  Future<NamedAPIResourceList> getAllPokemons();
  Future<PokemonSpecies> getPokemonSpeciesByUrl(String url);
  Future<Version> getGameVersionByUrl(String url);
  Future<EvolutionChain> getEvolutionChain(String url);
}
