import 'package:pokedex/pokeapi/entities/evolution.dart';
import 'package:pokedex/pokeapi/mappers/common_mapper.dart';
import 'package:pokedex/pokeapi/mappers/utils.dart';

class EvolutionChainMapper {
  static EvolutionChain fromMap(Map<String, dynamic> map) {
    return EvolutionChain(
      id: map['id'],
      chain: ChainLinkMapper.fromMap(map['chain']),
      babyTriggerItem: handleNullField(
        map['baby_trigger_item'],
        NamedApiResourceMapper.fromMap,
      ),
    );
  }
}

class ChainLinkMapper {
  static ChainLink fromMap(Map<String, dynamic> map) {
    return ChainLink(
      isBaby: map['is_baby'],
      species: NamedApiResourceMapper.fromMap(map['species']),
      evolutionDetails:
          (map['evolution_details'] as List)
              .map((detail) => EvolutionDetailMapper.fromMap(detail))
              .toList(),
      evolvesTo:
          (map['evolves_to'] as List)
              .map((item) => ChainLinkMapper.fromMap(item))
              .toList(),
    );
  }
}

class EvolutionDetailMapper {
  static EvolutionDetail fromMap(Map<String, dynamic> map) {
    return EvolutionDetail(
      trigger: NamedApiResourceMapper.fromMap(map['trigger']),
      timeOfDay: map['time_of_day'],
      turnUpsideDown: map['turn_upside_down'],
      needsOverworldRain: map['needs_overworld_rain'],

      gender: map['gender'],
      minLevel: map['min_level'],
      minBeauty: map['min_beauty'],
      minHappiness: map['min_happiness'],
      minAffection: map['min_affection'],
      relativePhysicalStats: map['relative_physical_stats'],
      item: handleNullField(map['item'], NamedApiResourceMapper.fromMap),
      heldItem: handleNullField(
        map['held_item'],
        NamedApiResourceMapper.fromMap,
      ),
      location: handleNullField(
        map['location'],
        NamedApiResourceMapper.fromMap,
      ),
      knownMove: handleNullField(
        map['known_move'],
        NamedApiResourceMapper.fromMap,
      ),
      partyType: handleNullField(
        map['party_type'],
        NamedApiResourceMapper.fromMap,
      ),
      partySpecies: handleNullField(
        map['party_species'],
        NamedApiResourceMapper.fromMap,
      ),
      tradeSpecies: handleNullField(
        map['trade_species'],
        NamedApiResourceMapper.fromMap,
      ),
      knownMoveType: handleNullField(
        map['known_move_type'],
        NamedApiResourceMapper.fromMap,
      ),
    );
  }
}
