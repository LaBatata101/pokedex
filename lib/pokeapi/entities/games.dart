import 'package:pokedex/pokeapi/entities/common.dart';

class Version {
  /// The identifier for this resource.
  final int id;

  /// The name for this resource.
  final String name;

  /// The name of this resource listed in different languages.
  final List<Name> names;

  /// The version group this version belongs to.
  ///
  /// See also:
  ///
  /// [VersionGroup]
  final NamedAPIResource versionGroup;

  const Version({
    required this.id,
    required this.name,
    required this.names,
    required this.versionGroup,
  });
}

class Generation {
  /// The identifier for this resource.
  final int id;

  /// The name for this resource.
  final String name;

  /// A list of abilities that were introduced in this generation.
  ///
  /// See also:
  ///
  /// [Ability]
  final List<NamedAPIResource> abilities;

  /// The name of this resource listed in different languages.
  final List<Name> names;

  /// The main region travelled in this generation.
  ///
  /// See also:
  ///
  /// [Region]
  final NamedAPIResource mainRegion;

  /// A list of moves that were introduced in this generation.
  ///
  /// See also:
  ///
  /// [Move]
  final List<NamedAPIResource> moves;

  /// A list of Pokémon species that were introduced in this generation.
  ///
  /// See also:
  ///
  /// [PokemonSpecies]
  final List<NamedAPIResource> pokemonSpecies;

  /// A list of types that were introduced in this generation.
  ///
  /// See also:
  ///
  /// [Type]
  final List<NamedAPIResource> types;

  /// A list of version groups that were introduced in this generation.
  ///
  /// See also:
  ///
  /// [VersionGroup]
  final List<NamedAPIResource> versionGroups;

  const Generation({
    required this.id,
    required this.name,
    required this.abilities,
    required this.names,
    required this.mainRegion,
    required this.moves,
    required this.pokemonSpecies,
    required this.types,
    required this.versionGroups,
  });

  @override
  String toString() {
    return '''Generation(
id: $id,
name: $name,
abilities: $abilities,
names: $names,
mainRegion: $mainRegion,
moves: $moves,
pokemonSpecies: $pokemonSpecies,
types: $types,
versionGroups: $versionGroups)''';
  }
}
