import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pokedex/pokeapi/converter_factory.dart';
import 'package:pokedex/pokeapi/endpoint.dart';

class PokeAPI extends PokeAPIEndpoints {
  PokeAPI({PokeAPIClient? client}) : super(client ?? PokeAPIClient());
}

class PokeAPIClient {
  final http.Client _client;
  final BaseConverterFactory _converterFactory;

  factory PokeAPIClient({
    http.Client? client,
    BaseConverterFactory? converter,
  }) {
    return PokeAPIClient._(
      client ?? http.Client(),
      converter ?? ConverterFactory(),
    );
  }

  PokeAPIClient._(this._client, this._converterFactory);

  Future<T> get<T>(String url) async {
    final response = await _client.get(Uri.parse(url));
    return _converterFactory.get<T>().fromJson(
          jsonDecode(response.body) as Json,
        )
        as T;
  }
}
