import 'dart:convert';

import 'package:pokedex/pokeapi/entities/moves.dart';
import 'package:pokedex/pokeapi/mappers/common_mapper.dart';
import 'package:pokedex/pokeapi/mappers/pokemon_mapper.dart';

class MoveMapper {
  static Move fromMap(Map<String, dynamic> map) {
    return Move(
      id: map['id'],
      name: map['name'],
      accuracy: map['accuracy'],
      effectChance: map['effect_chance'],
      pp: map['pp'],
      priority: map['priority'],
      power: map['power'],
      contestCombos: handleNullField(
        map['contest_combos'],
        ContestComboSetsMapper.fromMap,
      ),
      contestType: handleNullField(
        map['contest_type'],
        NamedApiResourceMapper.fromMap,
      ),
      contestEffect: handleNullField(
        map['contest_effect'],
        APIResourceMapper.fromMap,
      ),
      damageClass: NamedApiResourceMapper.fromMap(map['damage_class']),
      effectEntries:
          (map['effect_entries'] as List)
              .map((item) => VerboseEffectMapper.fromMap(item))
              .toList(),
      effectChanges:
          (map['effect_changes'] as List)
              .map((item) => AbilityEffectChangeMapper.fromMap(item))
              .toList(),
      learnedByPokemon:
          (map['learned_by_pokemon'] as List)
              .map((item) => NamedApiResourceMapper.fromMap(item))
              .toList(),
      flavorTextEntries:
          (map['flavor_text_entries'] as List)
              .map((item) => MoveFlavorTextMapper.fromMap(item))
              .toList(),
      generation: NamedApiResourceMapper.fromMap(map['generation']),
      machines:
          (map['machines'] as List)
              .map((item) => MachineVersionDetailMapper.fromMap(item))
              .toList(),
      meta: handleNullField(map['meta'], MoveMetaDataMapper.fromMap),
      names:
          (map['names'] as List)
              .map((item) => NameMapper.fromMap(item))
              .toList(),
      pastValues:
          (map['past_values'] as List)
              .map((item) => PastMoveStatValuesMapper.fromMap(item))
              .toList(),
      statChanges:
          (map['stat_changes'] as List)
              .map((item) => MoveStatChangeMapper.fromMap(item))
              .toList(),
      superContestEffect: handleNullField(
        map['super_contest_effect'],
        APIResourceMapper.fromMap,
      ),
      target: NamedApiResourceMapper.fromMap(map['target']),
      type: NamedApiResourceMapper.fromMap(map['type']),
    );
  }

  static Move fromJson(String source) => fromMap(json.decode(source));
}

class ContestComboSetsMapper {
  static ContestComboSets fromMap(Map<String, dynamic> map) {
    return ContestComboSets(
      normal: ContestComboDetailMapper.fromMap(map['normal']),
      superMove: ContestComboDetailMapper.fromMap(map['super']),
    );
  }

  static ContestComboSets fromJson(String source) =>
      fromMap(json.decode(source));
}

class ContestComboDetailMapper {
  static ContestComboDetail fromMap(Map<String, dynamic> map) {
    return ContestComboDetail(
      useBefore: handleNullField(
        map['use_before'],
        (list) =>
            (list as List)
                .map((item) => NamedApiResourceMapper.fromMap(item))
                .toList(),
      ),
      useAfter: handleNullField(
        map['use_after'],
        (list) =>
            (list as List)
                .map((item) => NamedApiResourceMapper.fromMap(item))
                .toList(),
      ),
    );
  }

  static ContestComboDetail fromJson(String source) =>
      fromMap(json.decode(source));
}

class MoveFlavorTextMapper {
  static MoveFlavorText fromMap(Map<String, dynamic> map) {
    return MoveFlavorText(
      flavorText: map['flavor_text'],
      language: NamedApiResourceMapper.fromMap(map['language']),
      versionGroup: NamedApiResourceMapper.fromMap(map['version_group']),
    );
  }

  static MoveFlavorText fromJson(String source) => fromMap(json.decode(source));
}

class MoveMetaDataMapper {
  static MoveMetaData fromMap(Map<String, dynamic> map) {
    return MoveMetaData(
      ailment: NamedApiResourceMapper.fromMap(map['ailment']),
      category: NamedApiResourceMapper.fromMap(map['category']),
      minHits: map['min_hits'],
      maxHits: map['max_hits'],
      minTurns: map['min_turns'],
      maxTurns: map['max_turns'],
      drain: map['drain'],
      healing: map['healing'],
      critRate: map['crit_rate'],
      ailmentChance: map['ailment_chance'],
      flinchChance: map['flinch_chance'],
      statChance: map['stat_chance'],
    );
  }

  static MoveMetaData fromJson(String source) => fromMap(json.decode(source));
}

class MoveStatChangeMapper {
  static MoveStatChange fromMap(Map<String, dynamic> map) {
    return MoveStatChange(
      change: map['change'],
      stat: NamedApiResourceMapper.fromMap(map['stat']),
    );
  }

  static MoveStatChange fromJson(String source) => fromMap(json.decode(source));
}

class PastMoveStatValuesMapper {
  static PastMoveStatValues fromMap(Map<String, dynamic> map) {
    return PastMoveStatValues(
      accuracy: map['accuracy'],
      effectChance: map['effect_chance'],
      power: map['power'],
      pp: map['pp'],
      effectEntries:
          (map['effect_entries'] as List)
              .map((item) => VerboseEffectMapper.fromMap(item))
              .toList(),
      type: handleNullField(map['type'], NamedApiResourceMapper.fromMap),
      versionGroup: NamedApiResourceMapper.fromMap(map['version_group']),
    );
  }

  static PastMoveStatValues fromJson(String source) =>
      fromMap(json.decode(source));
}

class MoveAilmentMapper {
  static MoveAilment fromMap(Map<String, dynamic> map) {
    return MoveAilment(
      id: map['id'],
      name: map['name'],
      moves:
          (map['moves'] as List)
              .map((item) => NamedApiResourceMapper.fromMap(item))
              .toList(),
      names:
          (map['names'] as List)
              .map((item) => NameMapper.fromMap(item))
              .toList(),
    );
  }

  static MoveAilment fromJson(String source) => fromMap(json.decode(source));
}

class MoveBattleStyleMapper {
  static MoveBattleStyle fromMap(Map<String, dynamic> map) {
    return MoveBattleStyle(
      id: map['id'],
      name: map['name'],
      names:
          (map['names'] as List)
              .map((item) => NameMapper.fromMap(item))
              .toList(),
    );
  }

  static MoveBattleStyle fromJson(String source) =>
      fromMap(json.decode(source));
}

class MoveCategoryMapper {
  static MoveCategory fromMap(Map<String, dynamic> map) {
    return MoveCategory(
      id: map['id'],
      name: map['name'],
      moves:
          (map['moves'] as List)
              .map((item) => NamedApiResourceMapper.fromMap(item))
              .toList(),
      descriptions:
          (map['descriptions'] as List)
              .map((item) => DescriptionMapper.fromMap(item))
              .toList(),
    );
  }

  static MoveCategory fromJson(String source) => fromMap(json.decode(source));
}

class MoveDamageClassMapper {
  static MoveDamageClass fromMap(Map<String, dynamic> map) {
    return MoveDamageClass(
      id: map['id'],
      name: map['name'],
      descriptions:
          (map['descriptions'] as List)
              .map((item) => DescriptionMapper.fromMap(item))
              .toList(),
      moves:
          (map['moves'] as List)
              .map((item) => NamedApiResourceMapper.fromMap(item))
              .toList(),
      names:
          (map['names'] as List)
              .map((item) => NameMapper.fromMap(item))
              .toList(),
    );
  }

  static MoveDamageClass fromJson(String source) =>
      fromMap(json.decode(source));
}

class MoveLearnMethodMapper {
  static MoveLearnMethod fromMap(Map<String, dynamic> map) {
    return MoveLearnMethod(
      id: map['id'],
      name: map['name'],
      descriptions:
          (map['descriptions'] as List)
              .map((item) => DescriptionMapper.fromMap(item))
              .toList(),
      names:
          (map['names'] as List)
              .map((item) => NameMapper.fromMap(item))
              .toList(),
      versionGroups:
          (map['version_groups'] as List)
              .map((item) => NamedApiResourceMapper.fromMap(item))
              .toList(),
    );
  }

  static MoveLearnMethod fromJson(String source) =>
      fromMap(json.decode(source));
}

class MoveTargetMapper {
  static MoveTarget fromMap(Map<String, dynamic> map) {
    return MoveTarget(
      id: map['id'],
      name: map['name'],
      descriptions:
          (map['descriptions'] as List)
              .map((item) => DescriptionMapper.fromMap(item))
              .toList(),
      moves:
          (map['moves'] as List)
              .map((item) => NamedApiResourceMapper.fromMap(item))
              .toList(),
      names:
          (map['names'] as List)
              .map((item) => NameMapper.fromMap(item))
              .toList(),
    );
  }

  static MoveTarget fromJson(String source) => fromMap(json.decode(source));
}
