import 'dart:convert';

import 'package:pokedex/pokeapi/mappers/common_mapper.dart';

import '../entities/pokemon.dart';

class PokemonMapper {
  static Pokemon fromMap(Map<String, dynamic> map) {
    return Pokemon(
      id: map['id'],
      name: map['name'],
      baseExperience: map['base_experience'],
      order: map['order'],
      height: map['height'],
      weight: map['weight'],
      isDefault: map['is_default'],
      locationAreaEncounters: map['location_area_encounters'],
      forms:
          (map['forms'] as List)
              .map((item) => NamedApiResourceMapper.fromMap(item))
              .toList(),
      moves:
          (map['moves'] as List)
              .map((item) => PokemonMoveMapper.fromMap(item))
              .toList(),
      stats:
          (map['stats'] as List)
              .map((item) => PokemonStatMapper.fromMap(item))
              .toList(),
      types:
          (map['types'] as List)
              .map((item) => PokemonTypeMapper.fromMap(item))
              .toList(),
      sprites: PokemonSpritesMapper.fromMap(map['sprites']),
      cries: PokemonCriesMapper.fromMap(map['cries']),
      species: NamedApiResourceMapper.fromMap(map['species']),
      abilities:
          (map['abilities'] as List)
              .map((item) => PokemonAbilityMapper.fromMap(item))
              .toList(),
      heldItems:
          (map['held_items'] as List)
              .map((item) => PokemonHeldItemMapper.fromMap(item))
              .toList(),
      pastTypes:
          (map['past_types'] as List)
              .map((item) => PokemonTypePastMapper.fromMap(item))
              .toList(),
      gameIndices:
          (map['game_indices'] as List)
              .map((item) => VersionGameIndexMapper.fromMap(item))
              .toList(),
    );
  }

  static Pokemon fromJson(String content) => fromMap(json.decode(content));
}

class PokemonAbilityMapper {
  static PokemonAbility fromMap(Map<String, dynamic> map) {
    return PokemonAbility(
      slot: map['slot'],
      isHidden: map['is_hidden'],
      ability: NamedApiResourceMapper.fromMap(map['ability']),
    );
  }

  static PokemonAbility fromJson(String content) =>
      fromMap(json.decode(content));
}

class PokemonHeldItemMapper {
  static PokemonHeldItem fromMap(Map<String, dynamic> map) {
    return PokemonHeldItem(
      item: NamedApiResourceMapper.fromMap(map['item']),
      versionDetails:
          (map['version_details'] as List)
              .map((item) => PokemonHeldItemVersionMapper.fromMap(item))
              .toList(),
    );
  }

  static PokemonHeldItem fromJson(String content) =>
      fromMap(json.decode(content));
}

class PokemonHeldItemVersionMapper {
  static PokemonHeldItemVersion fromMap(Map<String, dynamic> map) {
    return PokemonHeldItemVersion(
      version: NamedApiResourceMapper.fromMap(map['version']),
      rarity: map['rarity'],
    );
  }

  static PokemonHeldItemVersion fromJson(String content) =>
      fromMap(json.decode(content));
}

class PokemonMoveMapper {
  static PokemonMove fromMap(Map<String, dynamic> map) {
    return PokemonMove(
      move: NamedApiResourceMapper.fromMap(map['move']),
      versionGroupDetails:
          (map['version_group_details'] as List)
              .map((item) => PokemonMoveVersionMapper.fromMap(item))
              .toList(),
    );
  }

  static PokemonMove fromJson(String content) => fromMap(json.decode(content));
}

class PokemonMoveVersionMapper {
  static PokemonMoveVersion fromMap(Map<String, dynamic> map) {
    return PokemonMoveVersion(
      moveLearnMethod: NamedApiResourceMapper.fromMap(map['move_learn_method']),
      versionGroup: NamedApiResourceMapper.fromMap(map['version_group']),
      levelLearnedAt: map['level_learned_at'],
    );
  }

  static PokemonMoveVersion fromJson(String content) =>
      fromMap(json.decode(content));
}

class PokemonTypePastMapper {
  static PokemonTypePast fromMap(Map<String, dynamic> map) {
    return PokemonTypePast(
      generation: NamedApiResourceMapper.fromMap(map['generation']),
      types:
          (map['types'] as List)
              .map((item) => PokemonTypeMapper.fromMap(item))
              .toList(),
    );
  }

  static PokemonTypePast fromJson(String content) =>
      fromMap(json.decode(content));
}

class PokemonTypeMapper {
  static PokemonType fromMap(Map<String, dynamic> map) {
    return PokemonType(
      slot: map['slot'],
      type: NamedApiResourceMapper.fromMap(map['type']),
    );
  }

  static PokemonType fromJson(String content) => fromMap(json.decode(content));
}

class PokemonStatMapper {
  static PokemonStat fromMap(Map<String, dynamic> map) {
    return PokemonStat(
      stat: NamedApiResourceMapper.fromMap(map['stat']),
      effort: map['effort'],
      baseStat: map['base_stat'],
    );
  }

  static PokemonStat fromJson(String content) => fromMap(json.decode(content));
}

class PokemonCriesMapper {
  static PokemonCries fromMap(Map<String, dynamic> map) {
    return PokemonCries(latest: map['latest'], legacy: map['legacy']);
  }

  static PokemonCries fromJson(String content) => fromMap(json.decode(content));
}

class PokemonSpritesMapper {
  static PokemonSprites fromMap(Map<String, dynamic> map) {
    return PokemonSprites(
      frontDefault: map['front_default'],
      frontShiny: map['front_shiny'],
      frontFemale: map['front_female'],
      frontShinyFemale: map['front_shiny_female'],
      backDefault: map['back_default'],
      backShiny: map['back_shiny'],
      backFemale: map['back_female'],
      backShinyFemale: map['back_shiny_female'],
    );
  }

  static PokemonSprites fromJson(String content) =>
      fromMap(json.decode(content));
}
