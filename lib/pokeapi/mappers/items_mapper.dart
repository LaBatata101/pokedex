import 'dart:convert';

import 'package:pokedex/pokeapi/entities/items.dart';
import 'package:pokedex/pokeapi/mappers/common_mapper.dart';
import 'package:pokedex/pokeapi/mappers/utils.dart';

class ItemSpritesMapper {
  static ItemSprites fromMap(Map<String, dynamic> map) {
    return ItemSprites(value: map['default']);
  }

  static ItemSprites fromJson(String content) => fromMap(json.decode(content));
}

class ItemHolderPokemonVersionDetailMapper {
  static ItemHolderPokemonVersionDetail fromMap(Map<String, dynamic> map) {
    return ItemHolderPokemonVersionDetail(
      rarity: map['rarity'],
      version: NamedApiResourceMapper.fromMap(map['version']),
    );
  }

  static ItemHolderPokemonVersionDetail fromJson(String content) =>
      fromMap(json.decode(content));
}

class ItemHolderPokemonMapper {
  static ItemHolderPokemon fromMap(Map<String, dynamic> map) {
    return ItemHolderPokemon(
      pokemon: NamedApiResourceMapper.fromMap(map['pokemon']),
      versionDetails:
          (map['version_details'] as List)
              .map((item) => ItemHolderPokemonVersionDetailMapper.fromMap(item))
              .toList(),
    );
  }

  static ItemHolderPokemon fromJson(String content) =>
      fromMap(json.decode(content));
}

class ItemMapper {
  static Item fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      cost: map['cost'],
      flingPower: map['fling_power'],
      flingEffect: handleNullField(
        map['fling_effect'],
        NamedApiResourceMapper.fromMap,
      ),
      babyTriggerFor: handleNullField(
        map['baby_trigger_for'],
        APIResourceMapper.fromMap,
      ),
      attributes:
          (map['attributes'] as List)
              .map((item) => NamedApiResourceMapper.fromMap(item))
              .toList(),
      category: NamedApiResourceMapper.fromMap(map['category']),
      effectEntries:
          (map['effect_entries'] as List)
              .map((item) => VerboseEffectMapper.fromMap(item))
              .toList(),
      flavorTextEntries:
          (map['flavor_text_entries'] as List)
              .map((item) => VersionGroupFlavorTextMapper.fromMap(item))
              .toList(),
      gameIndices:
          (map['game_indices'] as List)
              .map((item) => GenerationGameIndexMapper.fromMap(item))
              .toList(),
      names:
          (map['names'] as List)
              .map((item) => NameMapper.fromMap(item))
              .toList(),
      sprites: ItemSpritesMapper.fromMap(map['sprites']),
      heldByPokemon:
          (map['held_by_pokemon'] as List)
              .map((item) => ItemHolderPokemonMapper.fromMap(item))
              .toList(),
      machines:
          (map['machines'] as List)
              .map((item) => MachineVersionDetailMapper.fromMap(item))
              .toList(),
    );
  }

  static Item fromJson(String content) => fromMap(json.decode(content));
}
