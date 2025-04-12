import 'package:pokedex/pokeapi/entities/common.dart';

class Item {
  /// The identifier for this resource.
  final int id;

  /// The name for this resource.
  final String name;

  /// The price of this item in stores.
  final int cost;

  /// The power of the move Fling when used with this item.
  final int? flingPower;

  /// The effect of the move Fling when used with this item.
  ///
  /// See also:
  ///
  /// [ItemFlingEffect]
  final NamedAPIResource? flingEffect;

  /// A list of attributes this item has.
  ///
  /// See also:
  ///
  /// [ItemAttribute]
  final List<NamedAPIResource> attributes;

  /// The category of items this item falls into.
  ///
  /// See also:
  ///
  /// [ItemCategory]
  final NamedAPIResource category;

  /// The effect of this ability listed in different languages.
  final List<VerboseEffect> effectEntries;

  /// The flavor text of this ability listed in different languages.
  final List<VersionGroupFlavorText> flavorTextEntries;

  /// A list of game indices relevent to this item by generation.
  final List<GenerationGameIndex> gameIndices;

  /// The name of this item listed in different languages.
  final List<Name> names;

  /// A set of sprites used to depict this item in the game.
  final ItemSprites sprites;

  /// A list of Pokémon that might be found in the wild holding this item
  final List<ItemHolderPokemon> heldByPokemon;

  /// An evolution chain this item requires to produce a bay during mating.
  ///
  /// See also:
  ///
  /// [EvolutionChain]
  final APIResource? babyTriggerFor;

  /// A list of the machines related to this item.
  final List<MachineVersionDetail> machines;

  const Item({
    required this.id,
    required this.name,
    required this.cost,
    required this.attributes,
    required this.category,
    required this.effectEntries,
    required this.flavorTextEntries,
    required this.gameIndices,
    required this.names,
    required this.sprites,
    required this.heldByPokemon,
    required this.machines,
    this.flingPower,
    this.flingEffect,
    this.babyTriggerFor,
  });

  @override
  String toString() {
    return '''Item(
id: $id,
name: $name,
cost: $cost,
flingPower: $flingPower,
flingEffect: $flingEffect,
attributes: $attributes,
category: $category,
effectEntries: $effectEntries,
flavorTextEntries: $flavorTextEntries,
gameIndices: $gameIndices,
names: $names,
sprites: $sprites,
heldByPokemon: $heldByPokemon,
babyTriggerFor: $babyTriggerFor,
machines: $machines
)''';
  }
}

class ItemSprites {
  /// The default depiction of this item.
  // Since default is a Dart keyword we have to use this instead
  final String? value;

  const ItemSprites({this.value});

  @override
  String toString() {
    return '''ItemSprites(
value: $value
)''';
  }
}

class ItemHolderPokemon {
  /// The Pokémon that holds this item.
  ///
  /// See also:
  ///
  /// [Pokemon]
  final NamedAPIResource pokemon;

  /// The details for the version that this item is held in by the Pokémon.
  final List<ItemHolderPokemonVersionDetail> versionDetails;

  const ItemHolderPokemon({
    required this.pokemon,
    required this.versionDetails,
  });

  @override
  String toString() {
    return '''ItemHolderPokemon(
pokemon: $pokemon,
versionDetails: $versionDetails
)''';
  }
}

class ItemHolderPokemonVersionDetail {
  /// How often this Pokémon holds this item in this version.
  final int rarity;

  /// The version that this item is held in by the Pokémon.
  ///
  /// See also:
  ///
  /// [Version]
  final NamedAPIResource version;

  const ItemHolderPokemonVersionDetail({
    required this.rarity,
    required this.version,
  });

  @override
  String toString() {
    return '''ItemHolderPokemonVersionDetail(
rarity: $rarity,
version: $version
)''';
  }
}
