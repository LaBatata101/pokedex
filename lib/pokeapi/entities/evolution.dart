import 'package:pokedex/pokeapi/entities/common.dart';

class EvolutionChain {
  /// The identifier for this resource.
  final int id;

  /// The item that a Pokémon would be holding when mating
  /// that would trigger the egg hatching a baby Pokémon rather than a basic Pokémon.
  ///
  /// See also:
  ///
  /// [Item]
  final NamedAPIResource? babyTriggerItem;

  /// The base chain link object.
  /// Each link contains evolution details for a Pokémon in the chain.
  /// Each link references the next Pokémon in the natural evolution order.
  final ChainLink chain;

  const EvolutionChain({
    required this.id,
    this.babyTriggerItem,
    required this.chain,
  });
}

class ChainLink {
  /// Whether or not this link is for a baby Pokémon.
  /// This would only ever be true on the base link.
  final bool isBaby;

  /// The Pokémon species at this point in the evolution chain.
  ///
  /// See also:
  ///
  /// [PokemonSpecies]
  final NamedAPIResource species;

  /// All details regarding the specific details of the referenced Pokémon species evolution.
  final List<EvolutionDetail> evolutionDetails;

  /// A List of chain objects.
  final List<ChainLink> evolvesTo;

  const ChainLink({
    required this.isBaby,
    required this.species,
    required this.evolutionDetails,
    required this.evolvesTo,
  });
}

class EvolutionDetail {
  /// The item required to cause evolution this into Pokémon species.
  ///
  /// See also:
  ///
  /// [Item]
  final NamedAPIResource? item;

  /// The type of event that triggers evolution into this Pokémon species.
  ///
  /// See also:
  final NamedAPIResource trigger;

  /// The id of the gender of the evolving Pokémon species must be
  /// in order to evolve into this Pokémon species.
  final int? gender;

  /// The item the evolving Pokémon species must be holding
  /// during the evolution trigger event to evolve into this Pokémon species.
  ///
  /// See also:
  ///
  /// [Item]
  final NamedAPIResource? heldItem;

  /// The move that must be known by the evolving Pokémon species
  /// during the evolution trigger event in order to evolve into this Pokémon species.
  ///
  /// See also:
  ///
  /// [Move]
  final NamedAPIResource? knownMove;

  /// The evolving Pokémon species must know a move with this type
  /// during the evolution trigger event in order to evolve into this Pokémon species.
  ///
  /// See also:
  ///
  /// [Type]
  final NamedAPIResource? knownMoveType;

  /// The location the evolution must be triggered at.
  ///
  /// See also:
  ///
  /// [Location]
  final NamedAPIResource? location;

  /// The minimum required level of the evolving Pokémon species to evolve
  /// into this Pokémon species.
  final int? minLevel;

  /// The minimum required level of happiness the evolving Pokémon species
  /// to evolve into this Pokémon species.
  final int? minHappiness;

  /// The minimum required level of beauty the evolving Pokémon species
  /// to evolve into this Pokémon species.
  final int? minBeauty;

  /// The minimum required level of affection the evolving Pokémon species
  /// to evolve into this Pokémon species.
  final int? minAffection;

  /// Whether or not it must be raining in the overworld
  /// to cause evolution this Pokémon species.
  final bool needsOverworldRain;

  /// The Pokémon species that must be in the players party
  /// in order for the evolving Pokémon species to evolve into this Pokémon species.
  ///
  /// See also:
  ///
  /// [PokemonSpecies]
  final NamedAPIResource? partySpecies;

  /// The player must have a Pokémon of this type in their party
  /// during the evolution trigger event in order for the evolving Pokémon species
  /// to evolve into this Pokémon species.
  ///
  /// See also:
  ///
  /// [Type]
  final NamedAPIResource? partyType;

  /// The required relation between the Pokémon's Attack and Defense stats.
  /// 1 means Attack > Defense. 0 means Attack = Defense. -1 means Attack < Defense.
  final int? relativePhysicalStats;

  /// The required time of day. Day or night.
  final String timeOfDay;

  /// Pokémon species for which this one must be traded.
  ///
  /// See also:
  ///
  /// [PokemonSpecies]
  final NamedAPIResource? tradeSpecies;

  /// Whether or not the 3DS needs to be turned upside-down as this Pokémon levels up.
  final bool turnUpsideDown;

  const EvolutionDetail({
    this.item,
    this.gender,
    this.heldItem,
    this.location,
    this.minLevel,
    this.knownMove,
    this.minBeauty,
    this.partyType,
    this.minHappiness,
    this.minAffection,
    this.partySpecies,
    this.tradeSpecies,
    this.knownMoveType,
    this.relativePhysicalStats,
    required this.trigger,
    required this.timeOfDay,
    required this.turnUpsideDown,
    required this.needsOverworldRain,
  });
}

class EvolutionTrigger {
  /// The identifier for this resource.
  final int id;

  /// The name for this resource.
  final String name;

  /// The name of this resource listed in different languages.
  final List<Name> names;

  /// A list of pokemon species that result from this evolution trigger.
  ///
  /// See also:
  ///
  /// [PokemonSpecies]
  final List<NamedAPIResource> pokemonSpecies;

  const EvolutionTrigger({
    required this.id,
    required this.name,
    required this.names,
    required this.pokemonSpecies,
  });
}
