import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pokedex/pokeapi/cache.dart';
import 'package:pokedex/pokeapi/converter_factory.dart';
import 'package:pokedex/pokeapi/endpoint.dart';
import 'package:pokedex/pokeapi/http_status.dart';

class PokeAPI extends PokeAPIEndpoints {
  PokeAPI._(super.client);

  static Future<PokeAPI> create() async {
    final client = await PokeAPIClient.withCache();
    return PokeAPI._(client);
  }
}

class PokeAPIClient {
  final http.Client _client;
  final BaseConverterFactory _converterFactory;
  final PokeAPICache _cache;

  static Future<PokeAPIClient> withCache({
    http.Client? client,
    BaseConverterFactory? converter,
  }) async {
    final cache = await PokeAPICache.init();
    return PokeAPIClient._(
      client ?? http.Client(),
      converter ?? ConverterFactory(),
      cache,
    );
  }

  PokeAPIClient._(this._client, this._converterFactory, this._cache);

  Future<T> get<T>(String url) async {
    if (await _cache.contains(url)) {
      final json = await _cache.get(url);
      return _converterFactory.get<T>().fromJson(jsonDecode(json!) as Json)
          as T;
    }

    final response = await _client.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw HttpStatusException(response.statusCode, url);
    }

    await _cache.insert(url, response.body);
    return _converterFactory.get<T>().fromJson(
          jsonDecode(response.body) as Json,
        )
        as T;
  }
}
