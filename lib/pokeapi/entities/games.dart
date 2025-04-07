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
