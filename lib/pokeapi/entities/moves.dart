import 'package:pokedex/pokeapi/entities/common.dart';
import 'package:pokedex/pokeapi/entities/pokemon.dart';

class Move {
  /// The identifier for this resource.
  final int id;

  /// The name for this resource.
  final String name;

  /// The percent value of how likely this move is to be successful.
  final int? accuracy;

  /// The percent value of how likely it is this moves effect will happen.
  final int? effectChance;

  /// Power points. The number of times this move can be used.
  final int? pp;

  /// A value between -8 and 8. Sets the order in which moves are executed during battle.
  /// See [Bulbapedia](https://bulbapedia.bulbagarden.net/wiki/Priority) for greater detail.
  final int priority;

  /// The base power of this move with a value of 0 if it does not have a base power.
  final int? power;

  /// A detail of normal and super contest combos that require this move.
  final ContestComboSets? contestCombos;

  /// The type of appeal this move gives a Pokémon when used in a contest.
  ///
  /// See also:
  ///
  /// [ContestType]
  final NamedAPIResource? contestType;

  /// The effect the move has when used in a contest.
  ///
  /// See also:
  ///
  /// [ContestEffect].
  final APIResource? contestEffect;

  /// The type of damage the move inflicts on the target, e.g. physical.
  ///
  /// See also:
  ///
  /// [MoveDamageClass]
  final NamedAPIResource damageClass;

  /// The effect of this move listed in different languages.
  final List<VerboseEffect> effectEntries;

  /// The list of previous effects this move has had across version groups of the games.
  final List<AbilityEffectChange> effectChanges;

  /// List of Pokemon that can learn the move.
  ///
  /// See also:
  ///
  /// [Pokemon]
  final List<NamedAPIResource> learnedByPokemon;

  /// The flavor text of this move listed in different languages.
  final List<MoveFlavorText> flavorTextEntries;

  /// The generation in which this move was introduced.
  ///
  /// See also:
  ///
  /// [Generation]
  final NamedAPIResource generation;

  /// A list of the machines that teach this move.
  final List<MachineVersionDetail> machines;

  /// Metadata about this move
  final MoveMetaData? meta;

  /// The name of this resource listed in different languages.
  final List<Name> names;

  /// A list of move resource value changes across version groups of the game.
  final List<PastMoveStatValues> pastValues;

  /// A list of stats this moves effects and how much it effects them
  final List<MoveStatChange> statChanges;

  /// The effect the move has when used in a super contest.
  ///
  /// See also:
  ///
  /// [SuperContestEffect]
  final APIResource? superContestEffect;

  /// The type of target that will receive the effects of the attack.
  ///
  /// See also:
  ///
  /// [MoveTarget]
  final NamedAPIResource target;

  /// The elemental type of this move.
  ///
  /// See also:
  ///
  /// [Type]
  final NamedAPIResource type;

  const Move({
    required this.id,
    required this.name,
    this.accuracy,
    this.effectChance,
    this.pp,
    required this.priority,
    this.power,
    this.contestCombos,
    this.contestType,
    this.contestEffect,
    required this.damageClass,
    required this.effectEntries,
    required this.effectChanges,
    required this.learnedByPokemon,
    required this.flavorTextEntries,
    required this.generation,
    required this.machines,
    this.meta,
    required this.names,
    required this.pastValues,
    required this.statChanges,
    this.superContestEffect,
    required this.target,
    required this.type,
  });
}

class ContestComboSets {
  /// A detail of moves this move can be used before or after,
  /// granting additional appeal points in contests.
  final ContestComboDetail normal;

  /// A detail of moves this move can be used before or after,
  /// granting additional appeal points in super contests.
  final ContestComboDetail superMove;

  const ContestComboSets({required this.normal, required this.superMove});
}

class ContestComboDetail {
  /// A list of moves to use before this move.
  final List<NamedAPIResource>? useBefore;

  /// A list of moves to use after this move.
  final List<NamedAPIResource>? useAfter;

  const ContestComboDetail({this.useBefore, this.useAfter});
}

class MoveFlavorText {
  /// The localized flavor text for an api resource in a specific language.
  final String flavorText;

  /// The language this name is in.
  ///
  /// See also:
  ///
  /// [Language]
  final NamedAPIResource language;

  /// The version group that uses this flavor text.
  ///
  /// See also:
  ///
  /// [VersionGroup]
  final NamedAPIResource versionGroup;

  const MoveFlavorText({
    required this.flavorText,
    required this.language,
    required this.versionGroup,
  });
}

class MoveMetaData {
  /// The status ailment this move inflicts on its target.
  ///
  /// See also:
  ///
  /// [MoveAilment]
  final NamedAPIResource ailment;

  /// The category of move this move falls under, e.g. damage or ailment.
  ///
  /// See also:
  ///
  /// [MoveCategory]
  final NamedAPIResource category;

  /// The minimum number of times this move hits. Null if it always only hits once.
  final int? minHits;

  /// The maximum number of times this move hits. Null if it always only hits once.
  final int? maxHits;

  /// The minimum number of turns this move continues to take effect.
  /// Null if it always only lasts one turn.
  final int? minTurns;

  /// The maximum number of turns this move continues to take effect.
  /// Null if it always only lasts one turn.
  final int? maxTurns;

  /// HP drain (if positive) or Recoil damage (if negative), in percent of damage done.
  final int drain;

  /// The amount of hp gained by the attacking Pokemon, in percent of it's maximum HP.
  final int healing;

  /// Critical hit rate bonus.
  final int critRate;

  /// The likelihood this attack will cause an ailment.
  final int ailmentChance;

  /// The likelihood this attack will cause the target Pokémon to flinch.
  final int flinchChance;

  /// The likelihood this attack will cause a stat change in the target Pokémon.
  final int statChance;

  const MoveMetaData({
    required this.ailment,
    required this.category,
    this.minHits,
    this.maxHits,
    this.minTurns,
    this.maxTurns,
    required this.drain,
    required this.healing,
    required this.critRate,
    required this.ailmentChance,
    required this.flinchChance,
    required this.statChance,
  });
}

class MoveStatChange {
  /// The amount of change.
  final int change;

  /// The stat being affected.
  ///
  /// See also:
  ///
  /// [Stat]
  final NamedAPIResource stat;

  const MoveStatChange({required this.change, required this.stat});
}

class PastMoveStatValues {
  /// The percent value of how likely this move is to be successful.
  final int? accuracy;

  /// The percent value of how likely it is this moves effect will take effect.
  final int? effectChance;

  /// The base power of this move with a value of 0 if it does not have a base power.
  final int? power;

  /// Power points. The number of times this move can be used.
  final int? pp;

  /// The effect of this move listed in different languages.
  final List<VerboseEffect> effectEntries;

  /// The elemental type of this move.
  ///
  /// See also:
  ///
  /// [Type]
  final NamedAPIResource? type;

  /// The version group in which these move stat values were in effect.
  ///
  /// See also:
  ///
  /// [VersionGroup]
  final NamedAPIResource versionGroup;

  const PastMoveStatValues({
    this.accuracy,
    this.effectChance,
    this.power,
    this.pp,
    required this.effectEntries,
    this.type,
    required this.versionGroup,
  });
}

class MoveAilment {
  /// The identifier for this resource.
  final int id;

  /// The name for this resource.
  final String name;

  /// A list of moves that cause this ailment.
  ///
  /// See also:
  ///
  /// [Move]
  final List<NamedAPIResource> moves;

  /// The name of this resource listed in different languages.
  final List<Name> names;

  const MoveAilment({
    required this.id,
    required this.name,
    required this.moves,
    required this.names,
  });
}

class MoveBattleStyle {
  /// The identifier for this resource.
  final int id;

  /// The name for this resource.
  final String name;

  /// The name of this resource listed in different languages.
  final List<Name> names;

  const MoveBattleStyle({
    required this.id,
    required this.name,
    required this.names,
  });
}

class MoveCategory {
  /// The identifier for this resource.
  final int id;

  /// The name for this resource.
  final String name;

  /// A list of moves that fall into this category.
  ///
  /// See also:
  ///
  /// [Move]
  final List<NamedAPIResource> moves;

  /// The description of this resource listed in different languages.
  final List<Description> descriptions;

  const MoveCategory({
    required this.id,
    required this.name,
    required this.moves,
    required this.descriptions,
  });
}

class MoveDamageClass {
  /// The identifier for this resource.
  final int id;

  /// The name for this resource.
  final String name;

  /// The description of this resource listed in different languages.
  final List<Description> descriptions;

  /// A list of moves that fall into this damage class.
  ///
  /// See also:
  ///
  /// [Move]
  final List<NamedAPIResource> moves;

  /// The name of this resource listed in different languages.
  final List<Name> names;

  const MoveDamageClass({
    required this.id,
    required this.name,
    required this.descriptions,
    required this.moves,
    required this.names,
  });
}

class MoveLearnMethod {
  /// The identifier for this resource.
  final int id;

  /// The name for this resource.
  final String name;

  /// The description of this resource listed in different languages.
  final List<Description> descriptions;

  /// The name of this resource listed in different languages.
  final List<Name> names;

  /// A list of version groups where moves can be learned through this method.
  ///
  /// See also:
  ///
  /// [VersionGroup]
  final List<NamedAPIResource> versionGroups;

  const MoveLearnMethod({
    required this.id,
    required this.name,
    required this.descriptions,
    required this.names,
    required this.versionGroups,
  });
}

class MoveTarget {
  /// The identifier for this resource.
  final int id;

  /// The name for this resource.
  final String name;

  /// The description of this resource listed in different languages.
  final List<Description> descriptions;

  /// A list of moves that that are directed at this target.
  ///
  /// See also:
  ///
  /// [Move]
  final List<NamedAPIResource> moves;

  /// The name of this resource listed in different languages.
  final List<Name> names;

  const MoveTarget({
    required this.id,
    required this.name,
    required this.descriptions,
    required this.moves,
    required this.names,
  });
}
