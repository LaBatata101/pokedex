class APIResource {
  /// The URL of the referenced resource.
  final String url;

  const APIResource({required this.url});
}

class NamedAPIResource {
  /// The name of the referenced resource.
  final String name;

  /// The URL of the referenced resource.
  final String url;

  const NamedAPIResource({required this.name, required this.url});

  @override
  String toString() {
    return '''NamedAPIResource(
    name: $name,
    url: $url)''';
  }
}

class APIResourceList {
  /// The total number of resources available from this API.
  final int count;

  /// The URL for the next page in the list.
  final String? next;

  /// The URL for the previous page in the list.
  final String? previous;

  /// A list of API resources.
  final List<APIResource> results;

  const APIResourceList({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  @override
  String toString() {
    return '''APIResource(
    count: $count,
    next: $next,
    previous: $previous,
    results: $results)''';
  }
}

class VersionGameIndex {
  /// The internal id of an API resource within game data.
  final int gameIndex;

  /// The version relevent to this game index.
  ///
  /// See also:
  ///
  /// [Version]
  final NamedAPIResource version;

  const VersionGameIndex({required this.gameIndex, required this.version});

  @override
  String toString() {
    return '''VersionGameIndex(
    gameIndex: $gameIndex,
    version: ${version.toString()})''';
  }
}

class NamedAPIResourceList {
  /// The total number of resources available from this API.
  final int count;

  /// The URL for the next page in the list.
  final String? next;

  ///	The URL for the previous page in the list.
  final String? previous;

  /// A list of named API resources.
  final List<NamedAPIResource> results;

  const NamedAPIResourceList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  @override
  String toString() {
    return '''NamedAPIResourceList(
    count: $count,
    next: $next,
    previous: $previous,
    results: $results)''';
  }
}

class Name {
  /// The localized name for an API resource in a specific language.
  final String name;

  /// The language this name is in.
  ///
  /// See also:
  ///
  /// [Language]
  final NamedAPIResource language;

  const Name({required this.name, required this.language});
}

class FlavorText {
  /// The localized flavor text for an API resource in a specific language.
  final String flavorText;

  /// The language this name is in.
  ///
  /// See also:
  ///
  /// [Language]
  final NamedAPIResource language;

  /// The game version this flavor text is extracted from.
  ///
  /// See also:
  ///
  /// [Version]
  final NamedAPIResource? version;

  const FlavorText({
    required this.flavorText,
    required this.language,
    required this.version,
  });
}

class Description {
  /// The localized description for an API resource in a specific language.
  final String description;

  /// The language this name is in.
  ///
  /// See also:
  ///
  /// [Language]
  final NamedAPIResource language;

  const Description({required this.description, required this.language});
}

class VerboseEffect {
  /// The localized effect text for an API resource in a specific language.
  final String effect;

  /// The localized effect text in brief.
  final String shortEffect;

  /// The language this effect is in.
  ///
  /// See also:
  ///
  /// [Language]
  final NamedAPIResource language;

  const VerboseEffect({
    required this.effect,
    required this.shortEffect,
    required this.language,
  });
}

class Effect {
  /// The localized effect text for an API resource in a specific language.
  final String effect;

  /// The language this effect is in.
  ///
  /// See also:
  ///
  /// [Language]
  final NamedAPIResource language;

  const Effect({required this.effect, required this.language});
}

class MachineVersionDetail {
  /// The machine that teaches a move from an item.
  ///
  /// See also:
  ///
  /// [Machine]
  final APIResource machine;

  /// The version group of this specific machine.
  ///
  /// See also:
  ///
  /// [VersionGroup]
  final NamedAPIResource versionGroup;

  const MachineVersionDetail({
    required this.machine,
    required this.versionGroup,
  });
}

class GenerationGameIndex {
  /// The internal id of an API resource within game data.
  final int gameIndex;

  /// The generation relevent to this game index.
  ///
  /// See also:
  ///
  /// [Generation]
  final NamedAPIResource generation;

  const GenerationGameIndex({
    required this.gameIndex,
    required this.generation,
  });

  @override
  String toString() {
    return '''GenerationGameIndex(
gameIndex: $gameIndex,
generation: $generation)''';
  }
}

class VersionGroupFlavorText {
  /// The localized name for an API resource in a specific language.
  final String text;

  /// The language this name is in.
  ///
  /// See also:
  ///
  /// [Language]
  final NamedAPIResource language;

  /// The version group which uses this flavor text.
  ///
  /// See also:
  ///
  /// [VersionGroup]
  final NamedAPIResource versionGroup;

  const VersionGroupFlavorText({
    required this.text,
    required this.language,
    required this.versionGroup,
  });

  @override
  String toString() {
    return '''VersionGroupFlavorText(
text: $text,
language: $language,
versionGroup: $versionGroup)''';
  }
}
