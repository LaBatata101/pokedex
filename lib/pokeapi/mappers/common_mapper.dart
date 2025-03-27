import 'dart:convert';

import 'package:pokedex/pokeapi/entities/common.dart';

class NamedApiResourceMapper {
  static Map<String, dynamic> toMap(NamedAPIResource resource) {
    return {'name': resource.name, 'url': resource.url};
  }

  static NamedAPIResource fromMap(Map<String, dynamic> map) {
    return NamedAPIResource(name: map['name'], url: map['url']);
  }

  static String toJson(NamedAPIResource resource) =>
      json.encode(toMap(resource));
  static NamedAPIResource fromJson(String content) =>
      fromMap(json.decode(content));
}

class VersionGameIndexMapper {
  static Map<String, dynamic> toMap(VersionGameIndex index) {
    return {'game_index': index.gameIndex, 'version': index.version};
  }

  static VersionGameIndex fromMap(Map<String, dynamic> map) {
    return VersionGameIndex(
      gameIndex: map['game_index'],
      version: NamedApiResourceMapper.fromMap(map['version']),
    );
  }

  static String toJson(VersionGameIndex index) => json.encode(toMap(index));
  static VersionGameIndex fromJson(String content) =>
      fromMap(json.decode(content));
}

class NamedAPIResourceListMapper {
  static Map<String, dynamic> toMap(NamedAPIResourceList list) {
    return {
      'count': list.count,
      'next': list.next,
      'previous': list.previous,
      'results':
          list.results
              .map((item) => NamedApiResourceMapper.toMap(item))
              .toList(),
    };
  }

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

  static String toJson(NamedAPIResourceList list) => json.encode(toMap(list));
  static NamedAPIResourceList fromJson(String content) =>
      fromMap(json.decode(content));
}
