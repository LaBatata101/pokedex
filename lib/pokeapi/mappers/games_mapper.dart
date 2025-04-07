import 'package:pokedex/pokeapi/entities/games.dart';
import 'package:pokedex/pokeapi/mappers/common_mapper.dart';

class VersionMapper {
  static Version fromMap(Map<String, dynamic> map) {
    return Version(
      id: map['id'],
      name: map['name'],
      names:
          (map['names'] as List)
              .map((name) => NameMapper.fromMap(name))
              .toList(),
      versionGroup: NamedApiResourceMapper.fromMap(map['version_group']),
    );
  }
}
