import 'package:pokedex/pokeapi/base_endpoint.dart';
import 'package:pokedex/pokeapi/entities/common.dart';
import 'package:pokedex/pokeapi/entities/pokemon.dart';
import 'package:pokedex/pokeapi/pokeapi.dart';

const String _baseUrl = 'https://pokeapi.co/api/v2/';

class NamedEndpoint<T>
    with ResourceEndpointMixin<T>
    implements BaseNamedEndpoint<T> {
  final PokeAPIClient client;

  NamedEndpoint(this.client);

  @override
  Future<T> getById(int id) {
    return client.get<T>('$_baseUrl$path/$id');
  }

  @override
  Future<T> getByName(String name) {
    return client.get<T>('$_baseUrl$path/$name');
  }

  @override
  Future<NamedAPIResourceList> getAll() {
    return getPage(limit: 10_000);
  }

  @override
  Future<T> getByUrl(String url) {
    return client.get<T>(url);
  }

  @override
  Future<NamedAPIResourceList> getPage({int limit = 20, int offset = 0}) {
    return client.get<NamedAPIResourceList>(
      '$_baseUrl$path?offset=$offset&limit=$limit',
    );
  }
}

class PokeAPIEndpoints extends BasePokeAPIEndpoints {
  PokeAPIEndpoints(PokeAPIClient client)
    : super(pokemon: NamedEndpoint<Pokemon>(client));
}
