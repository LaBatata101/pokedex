import 'package:pokedex/pokeapi/entities/common.dart';
import 'package:pokedex/pokeapi/entities/evolution.dart';
import 'package:pokedex/pokeapi/entities/games.dart';
import 'package:pokedex/pokeapi/entities/items.dart';
import 'package:pokedex/pokeapi/entities/moves.dart';
import 'package:pokedex/pokeapi/entities/pokemon.dart';

mixin ResourceEndpointMixin<T> {
  String? _resource;
  String get path => _resource ?? _createResource();

  String _createResource() {
    final endpoint = T;
    switch (endpoint) {
      case const (Pokemon):
        _resource = 'pokemon';
        break;
      case const (PokemonSpecies):
        _resource = 'pokemon-species';
        break;
      case const (Version):
        _resource = 'version';
        break;
      case const (EvolutionChain):
        _resource = 'evolution-chain';
        break;
      case const (Move):
        _resource = 'move';
        break;
      case const (Ability):
        _resource = 'ability';
        break;
      case const (Type):
        _resource = 'type';
        break;
      case const (Item):
        _resource = 'item';
        break;
      case const (Generation):
        _resource = 'generation';
        break;
      default:
        throw UnimplementedError('Endpoint not implemented: ${T.toString()}');
    }

    return _resource!;
  }
}

abstract class BaseNamedEndpoint<T> with ResourceEndpointMixin<T> {
  Future<T> getById(int id);
  Future<T> getByName(String name);
  Future<NamedAPIResourceList> getPage({int limit = 20, int offset = 0});
  Future<NamedAPIResourceList> getAll();
  Future<T> getByUrl(String url);
}

abstract class BaseEndpoint<T> with ResourceEndpointMixin<T> {
  Future<T> get(int id);
  Future<APIResourceList> getPage({int limit = 20, int offset = 0});
  Future<APIResourceList> getAll();
  Future<T> getByUrl(String url);
}

abstract class BasePokeAPIEndpoints {
  final BaseNamedEndpoint<Pokemon> pokemon;
  final BaseNamedEndpoint<PokemonSpecies> pokemonSpecies;
  final BaseNamedEndpoint<Version> version;
  final BaseNamedEndpoint<Move> move;
  final BaseNamedEndpoint<Ability> ability;
  final BaseNamedEndpoint<Type> type;
  final BaseNamedEndpoint<Item> item;
  final BaseNamedEndpoint<Generation> generation;
  final BaseEndpoint<EvolutionChain> evolutionChain;

  const BasePokeAPIEndpoints({
    required this.pokemon,
    required this.pokemonSpecies,
    required this.version,
    required this.evolutionChain,
    required this.move,
    required this.ability,
    required this.type,
    required this.item,
    required this.generation,
  });
}
