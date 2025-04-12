import 'dart:convert';

import 'package:pokedex/pokeapi/entities/common.dart';

class APIResourceMapper {
  static APIResource fromMap(Map<String, dynamic> map) {
    return APIResource(url: map['url']);
  }
}

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

class NameMapper {
  static Name fromMap(Map<String, dynamic> map) {
    return Name(
      name: map['name'],
      language: NamedApiResourceMapper.fromMap(map['language']),
    );
  }
}

class FlavorTextMapper {
  static FlavorText fromMap(Map<String, dynamic> map) {
    return FlavorText(
      flavorText: map['flavor_text'],
      language: NamedApiResourceMapper.fromMap(map['language']),
      version: NamedApiResourceMapper.fromMap(map['version']),
    );
  }
}

class DescriptionMapper {
  static Description fromMap(Map<String, dynamic> map) {
    return Description(
      description: map['description'],
      language: NamedApiResourceMapper.fromMap(map['language']),
    );
  }
}

class VerboseEffectMapper {
  static VerboseEffect fromMap(Map<String, dynamic> map) {
    return VerboseEffect(
      effect: map['effect'],
      // Assuming the JSON key is in snake_case.
      shortEffect: map['short_effect'],
      language: NamedApiResourceMapper.fromMap(map['language']),
    );
  }

  static VerboseEffect fromJson(String source) => fromMap(json.decode(source));
}

class EffectMapper {
  static Effect fromMap(Map<String, dynamic> map) {
    return Effect(
      effect: map['effect'],
      language: NamedApiResourceMapper.fromMap(map['language']),
    );
  }

  static Effect fromJson(String source) => fromMap(json.decode(source));
}

class MachineVersionDetailMapper {
  static MachineVersionDetail fromMap(Map<String, dynamic> map) {
    return MachineVersionDetail(
      machine: APIResourceMapper.fromMap(map['machine']),
      versionGroup: NamedApiResourceMapper.fromMap(map['version_group']),
    );
  }

  static MachineVersionDetail fromJson(String source) =>
      fromMap(json.decode(source));
}

class GenerationGameIndexMapper {
  static GenerationGameIndex fromMap(Map<String, dynamic> map) {
    return GenerationGameIndex(
      gameIndex: map['game_index'],
      generation: NamedApiResourceMapper.fromMap(map['generation']),
    );
  }

  static GenerationGameIndex fromJson(String content) =>
      fromMap(json.decode(content));
}

class VersionGroupFlavorTextMapper {
  static VersionGroupFlavorText fromMap(Map<String, dynamic> map) {
    return VersionGroupFlavorText(
      text: map['text'],
      language: NamedApiResourceMapper.fromMap(map['language']),
      versionGroup: NamedApiResourceMapper.fromMap(map['version_group']),
    );
  }

  static VersionGroupFlavorText fromJson(String content) =>
      fromMap(json.decode(content));
}
