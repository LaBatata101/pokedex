import 'dart:convert';

import 'package:pokedex/pokeapi/mappers/common_mapper.dart';

import '../entities/pokemon.dart';

class PokemonMapper {
  static Map<String, dynamic> toMap(Pokemon pokemon) {
    return {
      'id': pokemon.id,
      'name': pokemon.name,
      'base_experience': pokemon.baseExperience,
      'order': pokemon.order,
      'height': pokemon.height,
      'weight': pokemon.weight,
      'is_default': pokemon.isDefault,
      'location_area_encounters': pokemon.locationAreaEncounters,
      'forms':
          pokemon.forms
              .map((item) => NamedApiResourceMapper.toMap(item))
              .toList(),
      'moves':
          pokemon.moves.map((item) => PokemonMoveMapper.toMap(item)).toList(),
      'stats':
          pokemon.stats.map((item) => PokemonStatMapper.toMap(item)).toList(),
      'types':
          pokemon.types.map((item) => PokemonTypeMapper.toMap(item)).toList(),
      'sprites': PokemonSpritesMapper.toMap(pokemon.sprites),
      'cries': PokemonCriesMapper.toMap(pokemon.cries),
      'species': NamedApiResourceMapper.toMap(pokemon.species),
      'abilities':
          pokemon.abilities
              .map((item) => PokemonAbilityMapper.toMap(item))
              .toList(),
      'heldItems':
          pokemon.heldItems
              .map((item) => PokemonHeldItemMapper.toMap(item))
              .toList(),
      'pastTypes':
          pokemon.pastTypes
              .map((item) => PokemonTypePastMapper.toMap(item))
              .toList(),
      'gameIndices':
          pokemon.gameIndices
              .map((item) => VersionGameIndexMapper.toMap(item))
              .toList(),
    };
  }

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

  static String toJson(Pokemon pokemon) => json.encode(toMap(pokemon));
  static Pokemon fromJson(String content) => fromMap(json.decode(content));
}

class PokemonAbilityMapper {
  static Map<String, dynamic> toMap(PokemonAbility ability) {
    return {
      'slot': ability.slot,
      'is_hidden': ability.isHidden,
      'ability': NamedApiResourceMapper.toMap(ability.ability),
    };
  }

  static PokemonAbility fromMap(Map<String, dynamic> map) {
    return PokemonAbility(
      slot: map['slot'],
      isHidden: map['is_hidden'],
      ability: NamedApiResourceMapper.fromMap(map['ability']),
    );
  }

  static String toJson(PokemonAbility ability) => json.encode(toMap(ability));
  static PokemonAbility fromJson(String content) =>
      fromMap(json.decode(content));
}

class PokemonHeldItemMapper {
  static Map<String, dynamic> toMap(PokemonHeldItem item) {
    return {
      'item': NamedApiResourceMapper.toMap(item.item),
      'version_details':
          item.versionDetails
              .map((item) => PokemonHeldItemVersionMapper.toMap(item))
              .toList(),
    };
  }

  static PokemonHeldItem fromMap(Map<String, dynamic> map) {
    return PokemonHeldItem(
      item: NamedApiResourceMapper.fromMap(map['item']),
      versionDetails:
          (map['version_details'] as List)
              .map((item) => PokemonHeldItemVersionMapper.fromMap(item))
              .toList(),
    );
  }

  static String toJson(PokemonHeldItem item) => json.encode(toMap(item));
  static PokemonHeldItem fromJson(String content) =>
      fromMap(json.decode(content));
}

class PokemonHeldItemVersionMapper {
  static Map<String, dynamic> toMap(PokemonHeldItemVersion version) {
    return {
      'version': NamedApiResourceMapper.toMap(version.version),
      'rarity': version.rarity,
    };
  }

  static PokemonHeldItemVersion fromMap(Map<String, dynamic> map) {
    return PokemonHeldItemVersion(
      version: NamedApiResourceMapper.fromMap(map['version']),
      rarity: map['rarity'],
    );
  }

  static String toJson(PokemonHeldItemVersion move) => json.encode(toMap(move));
  static PokemonHeldItemVersion fromJson(String content) =>
      fromMap(json.decode(content));
}

class PokemonMoveMapper {
  static Map<String, dynamic> toMap(PokemonMove move) {
    return {
      'move': NamedApiResourceMapper.toMap(move.move),
      'version_group_details':
          move.versionGroupDetails
              .map((item) => PokemonMoveVersionMapper.toMap(item))
              .toList(),
    };
  }

  static PokemonMove fromMap(Map<String, dynamic> map) {
    return PokemonMove(
      move: NamedApiResourceMapper.fromMap(map['move']),
      versionGroupDetails:
          (map['version_group_details'] as List)
              .map((item) => PokemonMoveVersionMapper.fromMap(item))
              .toList(),
    );
  }

  static String toJson(PokemonMove move) => json.encode(toMap(move));
  static PokemonMove fromJson(String content) => fromMap(json.decode(content));
}

class PokemonMoveVersionMapper {
  static Map<String, dynamic> toMap(PokemonMoveVersion version) {
    return {
      'move_learn_method': NamedApiResourceMapper.toMap(
        version.moveLearnMethod,
      ),
      'version_group': NamedApiResourceMapper.toMap(version.versionGroup),
      'level_learned_at': version.levelLearnedAt,
    };
  }

  static PokemonMoveVersion fromMap(Map<String, dynamic> map) {
    return PokemonMoveVersion(
      moveLearnMethod: NamedApiResourceMapper.fromMap(map['move_learn_method']),
      versionGroup: NamedApiResourceMapper.fromMap(map['version_group']),
      levelLearnedAt: map['level_learned_at'],
    );
  }

  static String toJson(PokemonMoveVersion version) =>
      json.encode(toMap(version));
  static PokemonMoveVersion fromJson(String content) =>
      fromMap(json.decode(content));
}

class PokemonTypePastMapper {
  static Map<String, dynamic> toMap(PokemonTypePast typePast) {
    return {
      'generation': NamedApiResourceMapper.toMap(typePast.generation),
      'types':
          typePast.types.map((item) => PokemonTypeMapper.toMap(item)).toList(),
    };
  }

  static PokemonTypePast fromMap(Map<String, dynamic> map) {
    return PokemonTypePast(
      generation: NamedApiResourceMapper.fromMap(map['generation']),
      types:
          (map['types'] as List)
              .map((item) => PokemonTypeMapper.fromMap(item))
              .toList(),
    );
  }

  static String toJson(PokemonTypePast typePast) =>
      json.encode(toMap(typePast));
  static PokemonTypePast fromJson(String content) =>
      fromMap(json.decode(content));
}

class PokemonTypeMapper {
  static Map<String, dynamic> toMap(PokemonType type) {
    return {'slot': type.slot, 'type': NamedApiResourceMapper.toMap(type.type)};
  }

  static PokemonType fromMap(Map<String, dynamic> map) {
    return PokemonType(
      slot: map['slot'],
      type: NamedApiResourceMapper.fromMap(map['type']),
    );
  }

  static String toJson(PokemonType type) => json.encode(toMap(type));
  static PokemonType fromJson(String content) => fromMap(json.decode(content));
}

class PokemonStatMapper {
  static Map<String, dynamic> toMap(PokemonStat stat) {
    return {
      'stat': NamedApiResourceMapper.toMap(stat.stat),
      'effort': stat.effort,
      'base_stat': stat.baseStat,
    };
  }

  static PokemonStat fromMap(Map<String, dynamic> map) {
    return PokemonStat(
      stat: NamedApiResourceMapper.fromMap(map['stat']),
      effort: map['effort'],
      baseStat: map['base_stat'],
    );
  }

  static String toJson(PokemonStat stat) => json.encode(toMap(stat));
  static PokemonStat fromJson(String content) => fromMap(json.decode(content));
}

class PokemonCriesMapper {
  static Map<String, dynamic> toMap(PokemonCries cries) {
    return {'latest': cries.latest, 'legacy': cries.legacy};
  }

  static PokemonCries fromMap(Map<String, dynamic> map) {
    return PokemonCries(latest: map['latest'], legacy: map['legacy']);
  }

  static String toJson(PokemonCries cries) => json.encode(toMap(cries));
  static PokemonCries fromJson(String content) => fromMap(json.decode(content));
}

class PokemonSpritesMapper {
  static Map<String, dynamic> toMap(PokemonSprites sprites) {
    return {
      'front_default': sprites.frontDefault,
      'front_shiny': sprites.frontShiny,
      'front_female': sprites.frontFemale,
      'front_shiny_female': sprites.frontShinyFemale,
      'back_default': sprites.backDefault,
      'back_shiny': sprites.backShiny,
      'back_female': sprites.backFemale,
      'back_shiny_female': sprites.backShinyFemale,
    };
  }

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
      other: OtherMapper.fromMap(map['other']),
    );
  }

  static String toJson(PokemonSprites sprites) => json.encode(toMap(sprites));
  static PokemonSprites fromJson(String content) =>
      fromMap(json.decode(content));
}

class OtherMapper {
  static Other fromMap(Map<String, dynamic> map) {
    return Other(
      home: HomeMapper.fromMap(map['home']),
      dreamWorld: DreamWorldMapper.fromMap(map['dream_world']),
      showdown: ShowdownMapper.fromMap(map['showdown']),
    );
  }

  static Other fromJson(String content) => fromMap(json.decode(content));
}

class HomeMapper {
  static Home fromMap(Map<String, dynamic> map) {
    return Home(
      frontDefault: map['front_default'],
      frontShiny: map['front_shiny'],
      frontFemale: map['front_female'],
      frontShinyFemale: map['front_shiny_female'],
    );
  }

  static Home fromJson(String content) => fromMap(json.decode(content));
}

class DreamWorldMapper {
  static DreamWorld fromMap(Map<String, dynamic> map) {
    return DreamWorld(
      frontFemale: map['front_female'],
      frontDefault: map['front_default'],
    );
  }

  static DreamWorld fromJson(String content) => fromMap(json.decode(content));
}

class ShowdownMapper {
  static Showdown fromMap(Map<String, dynamic> map) {
    return Showdown(
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

  static Showdown fromJson(String content) => fromMap(json.decode(content));
}
