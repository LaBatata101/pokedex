import 'package:pokedex/pokeapi/entities/common.dart';

class Pokemon {
  /// The identifier for this resource.
  final int id;

  /// The name for this resource.
  final String name;

  /// The base experience gained for defeating this Pokémon.
  final int baseExperience;

  /// The height of this Pokémon in decimetres.
  final int height;

  /// Set for exactly one Pokémon used as the default for each species.
  final bool isDefault;

  /// Order for sorting. Almost national order; except families are grouped together.
  final int order;

  /// The weight of this Pokémon in hectograms.
  final int weight;

  /// A list of abilities this Pokémon could potentially have.
  final List<PokemonAbility> abilities;

  /// A list of forms this Pokémon can take on.
  ///
  /// See also:
  ///
  /// [PokemonForm]
  final List<NamedAPIResource> forms;

  /// A list of game indices relevent to Pokémon item by generation.
  final List<VersionGameIndex> gameIndices;

  /// A list of items this Pokémon may be holding when encountered.
  final List<PokemonHeldItem> heldItems;

  /// A link to a list of location areas; as well as encounter details
  /// pertaining to specific versions.
  final String locationAreaEncounters;

  /// A list of moves along with learn methods and level details pertaining
  /// to specific version groups.
  final List<PokemonMove> moves;

  /// A list of details showing types this pokémon had in previous generations
  final List<PokemonTypePast> pastTypes;

  /// A set of sprites used to depict this Pokémon in the game.
  /// A visual representation of the various sprites can be found at
  /// [PokeAPI/sprites](https://github.com/PokeAPI/sprites#sprites)
  final PokemonSprites sprites;

  /// A set of cries used to depict this Pokémon in the game.
  /// A visual representation of the various cries can be found at
  /// [PokeAPI/cries](https://github.com/PokeAPI/cries#cries)
  final PokemonCries cries;

  /// The species this Pokémon belongs to.
  ///
  /// See also:
  ///
  /// [PokemonSpecies]
  final NamedAPIResource species;

  /// A list of base stat values for this Pokémon.
  final List<PokemonStat> stats;

  /// A list of details showing types this Pokémon has.
  final List<PokemonType> types;

  const Pokemon({
    required this.id,
    required this.name,
    required this.order,
    required this.forms,
    required this.moves,
    required this.stats,
    required this.types,
    required this.height,
    required this.weight,
    required this.sprites,
    required this.cries,
    required this.species,
    required this.isDefault,
    required this.abilities,
    required this.heldItems,
    required this.pastTypes,
    required this.gameIndices,
    required this.baseExperience,
    required this.locationAreaEncounters,
  });

  @override
  String toString() {
    return '''Pokemon(
    id: $id,
    name: $name,
    baseExperience: $baseExperience,
    height: $height,
    weight: $weight,
    order: $order,
    isDefault: $isDefault,
    abilities: $abilities,
    forms: $forms,
    gameIndices: $gameIndices,
    heldItems: $heldItems,
    locationAreaEncounters: $locationAreaEncounters,
    moves: $moves,
    pastTypes: $pastTypes,
    sprites: $sprites,
    cries: $cries,
    species: $species,
    stats: $stats,
    types: $types)''';
  }
}

class PokemonAbility {
  /// Whether or not this is a hidden ability.
  final bool isHidden;

  /// The slot this ability occupies in this Pokémon species.
  final int slot;

  /// The ability the Pokémon may have.
  ///
  /// See also:
  ///
  /// [Ability]
  final NamedAPIResource ability;

  const PokemonAbility({
    required this.slot,
    required this.isHidden,
    required this.ability,
  });

  @override
  String toString() {
    return '''PokemonAbility(
    slot: $slot,
    isHidden: $isHidden,
    ability: $ability)''';
  }
}

class PokemonType {
  /// The order the Pokémon's types are listed in.
  final int slot;

  /// The type the referenced Pokémon has.
  ///
  /// See also:
  ///
  /// [Type]
  final NamedAPIResource type;

  const PokemonType({required this.slot, required this.type});

  @override
  String toString() {
    return '''PokemonType(
    slot: $slot,
    type: $type)''';
  }
}

class PokemonStat {
  /// The stat the Pokémon has.
  ///
  /// See also:
  ///
  /// [Stat]
  final NamedAPIResource stat;

  /// The effort points (EV) the Pokémon has in the stat.
  final int effort;

  /// The base value of the stat.
  final int baseStat;

  const PokemonStat({
    required this.stat,
    required this.effort,
    required this.baseStat,
  });

  @override
  String toString() {
    return '''PokemonStat(
    effort: $effort,
    baseStat: $baseStat,
    stat: $stat)''';
  }
}

class PokemonSprites {
  /// The default depiction of this Pokémon from the front in battle.
  final String? frontDefault;

  /// The shiny depiction of this Pokémon from the front in battle.
  final String? frontShiny;

  /// The female depiction of this Pokémon from the front in battle.
  final String? frontFemale;

  /// The shiny female depiction of this Pokémon from the front in battle.
  final String? frontShinyFemale;

  /// The default depiction of this Pokémon from the back in battle.
  final String? backDefault;

  /// The shiny depiction of this Pokémon from the back in battle.
  final String? backShiny;

  /// The female depiction of this Pokémon from the back in battle.
  final String? backFemale;

  /// The shiny female depiction of this Pokémon from the back in battle.
  final String? backShinyFemale;

  final Other other;

  const PokemonSprites({
    this.frontDefault,
    this.frontShiny,
    this.frontFemale,
    this.frontShinyFemale,
    this.backDefault,
    this.backShiny,
    this.backFemale,
    this.backShinyFemale,
    required this.other,
  });

  @override
  String toString() {
    return '''PokemonSprites(
    frontDefault: $frontDefault,
    frontShiny: $frontShiny,
    frontFemale: $frontFemale,
    frontShinyFemale: $frontShinyFemale,
    backDefault: $backDefault,
    backShiny: $backShiny,
    backFemale: $backFemale,
    backShinyFemale: $backShinyFemale,
    other: $other)''';
  }
}

class Other {
  final Home home;
  final DreamWorld dreamWorld;
  final Showdown showdown;

  const Other({
    required this.home,
    required this.dreamWorld,
    required this.showdown,
  });
  @override
  String toString() {
    return '''Other(
    home: $home,
    dreamWorld: $dreamWorld,
    showdown: $showdown)''';
  }
}

class DreamWorld {
  final String? frontDefault;
  final String? frontFemale;

  const DreamWorld({this.frontDefault, this.frontFemale});
  @override
  String toString() {
    return '''DreamWorld(
    frontDefault: $frontDefault,
    frontFemale: $frontFemale)''';
  }
}

class Home {
  final String? frontDefault;
  final String? frontShiny;
  final String? frontFemale;
  final String? frontShinyFemale;

  const Home({
    this.frontDefault,
    this.frontShiny,
    this.frontFemale,
    this.frontShinyFemale,
  });

  @override
  String toString() {
    return '''Home(
    frontDefault: $frontDefault,
    frontShiny: $frontShiny,
    frontFemale: $frontFemale,
    frontShinyFemale: $frontShinyFemale)''';
  }
}

class OfficialArtwork {
  final String? frontDefault;
  final String? frontShiny;

  const OfficialArtwork({this.frontDefault, this.frontShiny});

  @override
  String toString() {
    return '''OfficialArtwork(
    frontDefault: $frontDefault,
    frontFemale: $frontShiny)''';
  }
}

class Showdown {
  final String? frontDefault;
  final String? frontShiny;
  final String? frontFemale;
  final String? frontShinyFemale;
  final String? backDefault;
  final String? backShiny;
  final String? backFemale;
  final String? backShinyFemale;

  const Showdown({
    this.frontDefault,
    this.frontShiny,
    this.frontFemale,
    this.frontShinyFemale,
    this.backDefault,
    this.backShiny,
    this.backFemale,
    this.backShinyFemale,
  });

  @override
  String toString() {
    return '''Showdown(
    frontDefault: $frontDefault,
    frontShiny: $frontShiny,
    frontFemale: $frontFemale,
    frontShinyFemale: $frontShinyFemale,
    backDefault: $backDefault,
    backShiny: $backShiny,
    backFemale: $backFemale,
    backShinyFemale: $backShinyFemale)''';
  }
}

class PokemonCries {
  /// The latest depiction of this Pokémon's cry.
  final String? latest;

  /// The legacy depiction of this Pokémon's cry.
  final String? legacy;

  const PokemonCries({this.latest, this.legacy});

  @override
  String toString() {
    return '''PokemonCries(
    latest: $latest,
    legacy: $legacy)''';
  }
}

class PokemonTypePast {
  /// The last generation in which the referenced pokémon had the listed types.
  ///
  /// See also:
  ///
  /// [Generation]
  final NamedAPIResource generation;

  /// The types the referenced pokémon had up to and including the listed generation.
  final List<PokemonType> types;

  const PokemonTypePast({required this.generation, required this.types});
}

class PokemonMove {
  /// The move the Pokémon can learn.
  ///
  /// See also:
  ///
  /// [Move]
  final NamedAPIResource move;

  /// The details of the version in which the Pokémon can learn the move.
  final List<PokemonMoveVersion> versionGroupDetails;

  const PokemonMove({required this.move, required this.versionGroupDetails});

  @override
  String toString() {
    return '''PokemonMove(
    move: $move,
    versionGroupDetails: $versionGroupDetails)''';
  }
}

class PokemonMoveVersion {
  /// The method by which the move is learned.
  ///
  /// See also:
  ///
  /// [MoveLearnMethod]
  final NamedAPIResource moveLearnMethod;

  /// The version group in which the move is learned.
  ///
  /// See also:
  ///
  /// [VersionGroup]
  final NamedAPIResource versionGroup;

  /// The minimum level to learn the move.
  final int levelLearnedAt;

  const PokemonMoveVersion({
    required this.moveLearnMethod,
    required this.versionGroup,
    required this.levelLearnedAt,
  });

  @override
  String toString() {
    return '''PokemonMoveVersion(
    levelLearnedAt: $levelLearnedAt,
    moveLearnMethod: $moveLearnMethod,
    versionGroup: $versionGroup)''';
  }
}

class PokemonHeldItem {
  /// The item the referenced Pokémon holds.
  ///
  /// See also:
  ///
  /// [Item]
  final NamedAPIResource item;

  /// The details of the different versions in which the item is held.
  final List<PokemonHeldItemVersion> versionDetails;

  const PokemonHeldItem({required this.item, required this.versionDetails});
}

class PokemonHeldItemVersion {
  /// The version in which the item is held.
  ///
  /// See also:
  ///
  /// [Version]
  final NamedAPIResource version;

  /// How often the item is held.
  final int rarity;

  const PokemonHeldItemVersion({required this.version, required this.rarity});
}
