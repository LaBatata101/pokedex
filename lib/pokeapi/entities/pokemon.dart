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

class AbilityEffectChange {
  /// The previous effect of this ability listed in different languages.
  final List<Effect> effectEntries;

  /// The version group in which the previous effect of this ability originated.
  ///
  /// See also:
  ///
  /// [VersionGroup]
  final NamedAPIResource versionGroup;

  const AbilityEffectChange({
    required this.effectEntries,
    required this.versionGroup,
  });
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

class PokemonSpecies {
  /// The identifier for this resource.
  final int id;

  /// The name for this resource.
  final String name;

  /// The order in which species should be sorted.
  /// Based on National Dex order, except families are grouped together and sorted by stage.
  final int order;

  /// The chance of this Pokémon being female, in eighths; or -1 for genderless.
  final int genderRate;

  /// The base capture rate; up to 255. The higher the number, the easier the catch.
  final int captureRate;

  /// The happiness when caught by a normal Pokéball; up to 255.
  /// The higher the number, the happier the Pokémon.
  final int? baseHappiness;

  /// Whether or not this is a baby Pokémon.
  final bool isBaby;

  /// Whether or not this is a legendary Pokémon.
  final bool isLegendary;

  /// Whether or not this is a mythical Pokémon.
  final bool isMythical;

  /// Initial hatch counter: one must walk 255 × (hatch_counter + 1) steps before
  ///  this Pokémon's egg hatches, unless utilizing bonuses like Flame Body's.
  final int? hatchCounter;

  /// Whether or not this Pokémon has visual gender differences.
  final bool hasGenderDifferences;

  /// Whether or not this Pokémon has multiple forms and can switch between them.
  final bool formsSwitchable;

  /// The rate at which this Pokémon species gains levels.
  ///
  /// See also:
  ///
  /// [GrowthRate]
  final NamedAPIResource growthRate;

  /// A list of Pokedexes and the indexes reserved within them for this Pokémon species.
  final List<PokemonSpeciesDexEntry> pokedexNumbers;

  /// A list of egg groups this Pokémon species is a member of.
  ///
  /// See also:
  ///
  /// [EggGroup]
  final List<NamedAPIResource> eggGroups;

  /// The color of this Pokémon for Pokédex search.
  ///
  /// See also:
  ///
  /// [PokemonColor]
  final NamedAPIResource color;

  /// The shape of this Pokémon for Pokédex search.
  ///
  /// See also:
  ///
  /// [PokemonShape]
  final NamedAPIResource? shape;

  /// The Pokémon species that evolves into this Pokemon_species.
  ///
  /// See also:
  ///
  /// [PokemonSpecies]
  final NamedAPIResource? evolvesFromSpecies;

  /// The evolution chain this Pokémon species is a member of.
  ///
  /// See also:
  ///
  /// [EvolutionChain]
  final APIResource? evolutionChain;

  /// The habitat this Pokémon species can be encountered in.
  ///
  /// See also:
  ///
  /// [PokemonHabitat]
  final NamedAPIResource? habitat;

  /// The generation this Pokémon species was introduced in.
  ///
  /// See also:
  ///
  /// [Generation]
  final NamedAPIResource generation;

  /// The name of this resource listed in different languages.
  final List<Name> names;

  /// A list of encounters that can be had with this Pokémon species in pal park.
  final List<PalParkEncounterArea> palParkEncounters;

  /// A list of flavor text entries for this Pokémon species.
  final List<FlavorText> flavorTextEntries;

  /// Descriptions of different forms Pokémon take on within the Pokémon species.
  final List<Description> formDescriptions;

  /// The genus of this Pokémon species listed in multiple languages.
  final List<Genus> genera;

  /// A list of the Pokémon that exist within this Pokémon species.
  final List<PokemonSpeciesVariety> varieties;

  const PokemonSpecies({
    required this.id,
    required this.name,
    required this.order,
    required this.color,
    required this.names,
    required this.isBaby,
    required this.genera,
    required this.eggGroups,
    required this.varieties,
    required this.genderRate,
    required this.isMythical,
    required this.growthRate,
    required this.generation,
    required this.captureRate,
    required this.isLegendary,
    required this.pokedexNumbers,
    required this.formsSwitchable,
    required this.formDescriptions,
    required this.palParkEncounters,
    required this.flavorTextEntries,
    required this.hasGenderDifferences,
    this.shape,
    this.habitat,
    this.hatchCounter,
    this.baseHappiness,
    this.evolutionChain,
    this.evolvesFromSpecies,
  });
}

class PokemonSpeciesDexEntry {
  /// The index number within the Pokédex.
  final int entryNumber;

  /// The Pokédex the referenced Pokémon species can be found in.
  ///
  /// See also:
  ///
  /// [PokedexData]
  final NamedAPIResource pokedex;

  const PokemonSpeciesDexEntry({
    required this.entryNumber,
    required this.pokedex,
  });
}

class PalParkEncounterArea {
  /// The base score given to the player when the referenced Pokémon is caught during a pal park run.
  final int baseScore;

  /// The base rate for encountering the referenced Pokémon in this pal park area.
  final int rate;

  /// The pal park area where this encounter happens.
  ///
  /// See also:
  ///
  /// [PalParkArea]
  final NamedAPIResource area;

  const PalParkEncounterArea({
    required this.baseScore,
    required this.rate,
    required this.area,
  });
}

class Genus {
  /// The localized genus for the referenced Pokémon species
  final String genus;

  /// The language this genus is in.
  ///
  /// See also:
  ///
  /// [Language]
  final NamedAPIResource language;

  const Genus({required this.genus, required this.language});
}

class PokemonSpeciesVariety {
  /// Whether this variety is the default variety.
  final bool isDefault;

  /// The Pokémon variety.
  ///
  /// See also:
  ///
  /// [Pokemon]
  final NamedAPIResource pokemon;

  const PokemonSpeciesVariety({required this.isDefault, required this.pokemon});
}
