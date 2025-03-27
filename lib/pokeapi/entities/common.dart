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
