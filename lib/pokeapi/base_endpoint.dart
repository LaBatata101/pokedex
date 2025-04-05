import 'package:pokedex/pokeapi/entities/common.dart';
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

abstract class BasePokeAPIEndpoints {
  final BaseNamedEndpoint<Pokemon> pokemon;
  final BaseNamedEndpoint<PokemonSpecies> pokemonSpecies;

  const BasePokeAPIEndpoints({
    required this.pokemon,
    required this.pokemonSpecies,
  });
}
