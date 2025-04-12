import 'dart:core' as core show Type;
import 'dart:core';

import 'package:pokedex/pokeapi/entities/common.dart';
import 'package:pokedex/pokeapi/entities/evolution.dart';
import 'package:pokedex/pokeapi/entities/games.dart';
import 'package:pokedex/pokeapi/entities/items.dart';
import 'package:pokedex/pokeapi/entities/moves.dart';
import 'package:pokedex/pokeapi/entities/pokemon.dart';
import 'package:pokedex/pokeapi/mappers/common_mapper.dart';
import 'package:pokedex/pokeapi/mappers/evolution_mapper.dart';
import 'package:pokedex/pokeapi/mappers/games_mapper.dart';
import 'package:pokedex/pokeapi/mappers/items_mapper.dart';
import 'package:pokedex/pokeapi/mappers/moves_mapper.dart';
import 'package:pokedex/pokeapi/mappers/pokemon_mapper.dart';

typedef Json = Map<String, dynamic>;
typedef FromJson<T> = T Function(Json json);

class Converter<T> {
  final FromJson<T> fromJson;

  const Converter({required this.fromJson});
}

abstract class BaseConverterFactory {
  Converter get<T>();
}

class ConverterFactory implements BaseConverterFactory {
  final Map<core.Type, Converter> _converters = Map.unmodifiable({
    NamedAPIResourceList: Converter<NamedAPIResourceList>(
      fromJson: (json) => NamedAPIResourceListMapper.fromMap(json),
    ),
    Pokemon: Converter<Pokemon>(
      fromJson: (json) => PokemonMapper.fromMap(json),
    ),
    PokemonSpecies: Converter<PokemonSpecies>(
      fromJson: (json) => PokemonSpeciesMapper.fromMap(json),
    ),
    Version: Converter<Version>(
      fromJson: (json) => VersionMapper.fromMap(json),
    ),
    EvolutionChain: Converter<EvolutionChain>(
      fromJson: (json) => EvolutionChainMapper.fromMap(json),
    ),
    Move: Converter<Move>(fromJson: (json) => MoveMapper.fromMap(json)),
    Ability: Converter<Ability>(
      fromJson: (json) => AbilityMapper.fromMap(json),
    ),
    Type: Converter<Type>(fromJson: (json) => TypeMapper.fromMap(json)),
    Item: Converter<Item>(fromJson: (json) => ItemMapper.fromMap(json)),
  });

  @override
  Converter get<T>() => _converters[T]!;
}
