import 'dart:convert';

import 'package:pokedex/pokeapi/entities/common.dart';
import 'package:pokedex/pokeapi/entities/games.dart';
import 'package:pokedex/pokeapi/mappers/common_mapper.dart';

class VersionMapper {
  static Version fromMap(Map<String, dynamic> map) {
    return Version(
      id: map['id'],
      name: map['name'],
      names:
          (map['names'] as List)
              .map((name) => NameMapper.fromMap(name))
              .toList(),
      versionGroup: NamedApiResourceMapper.fromMap(map['version_group']),
    );
  }
}

class GenerationMapper {
  static Generation fromMap(Map<String, dynamic> map) {
    // Helper para mapear listas de NamedAPIResource
    List<NamedAPIResource> mapResourceList(String key) {
      // Adiciona verificação para caso a chave não exista ou seja nula no JSON,
      // retornando uma lista vazia para evitar erros.
      if (map[key] == null) return [];
      return (map[key] as List)
          .map((item) => NamedApiResourceMapper.fromMap(item))
          .toList();
    }

    return Generation(
      id: map['id'],
      name: map['name'],
      abilities: mapResourceList('abilities'),
      names:
          (map['names'] as List)
              .map((item) => NameMapper.fromMap(item))
              .toList(),
      mainRegion: NamedApiResourceMapper.fromMap(map['main_region']),
      moves: mapResourceList('moves'),
      pokemonSpecies: mapResourceList('pokemon_species'),
      types: mapResourceList('types'),
      versionGroups: mapResourceList('version_groups'),
    );
  }

  static Generation fromJson(String content) => fromMap(json.decode(content));
}
