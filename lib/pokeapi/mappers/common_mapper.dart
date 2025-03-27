import 'dart:convert';

import 'package:pokedex/pokeapi/entities/common.dart';

class NamedApiResourceMapper {
  static NamedAPIResource fromMap(Map<String, dynamic> map) {
    return NamedAPIResource(name: map['name'], url: map['url']);
  }

  static NamedAPIResource fromJson(String content) =>
      fromMap(json.decode(content));
}

class VersionGameIndexMapper {
  static VersionGameIndex fromMap(Map<String, dynamic> map) {
    return VersionGameIndex(
      gameIndex: map['game_index'],
      version: NamedApiResourceMapper.fromMap(map['version']),
    );
  }

  static VersionGameIndex fromJson(String content) =>
      fromMap(json.decode(content));
}

class NamedAPIResourceListMapper {
  static NamedAPIResourceList fromMap(Map<String, dynamic> map) {
    return NamedAPIResourceList(
      count: map['count'],
      next: map['next'],
      previous: map['previous'],
      results:
          (map['results'] as List)
              .map((item) => NamedApiResourceMapper.fromMap(item))
              .toList(),
    );
  }

  static NamedAPIResourceList fromJson(String content) =>
      fromMap(json.decode(content));
}
