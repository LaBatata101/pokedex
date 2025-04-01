import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/pokeapi/entities/pokemon.dart';
import 'package:pokedex/utils/string.dart';

final statColors = {
  'hp': Colors.green,
  'attack': Colors.red,
  'defense': Colors.blue,
  'special-attack': Colors.orange,
  'special-defense': Colors.purple,
  'speed': Colors.yellow,
};

final typeColors = {
  'normal': Colors.brown,
  'fire': Colors.red,
  'water': Colors.blue,
  'grass': Colors.green,
  'electric': Colors.yellow,
  'ice': Colors.cyan,
  'fighting': Colors.orange,
  'poison': Colors.purple,
  'ground': Colors.brown,
  'flying': Colors.indigo,
  'psychic': Colors.pink,
  'bug': Colors.lightGreen,
  'rock': Colors.grey,
  'ghost': Colors.deepPurple,
  'dragon': Colors.indigo,
  'dark': Colors.black,
  'steel': Colors.blueGrey,
  'fairy': Colors.pinkAccent,
};

class PokemonDetails extends StatelessWidget {
  final Pokemon pokemon;
  const PokemonDetails({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nº ${pokemon.id.toString().padLeft(4, '0')}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor:
            typeColors[pokemon.types.first.type.name] ?? Colors.grey,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HeaderWidget(pokemon: pokemon),
            BasicInfoWidget(pokemon: pokemon),
            StatsWidget(stats: pokemon.stats),
            AbilitiesWidget(abilities: pokemon.abilities),
            ExpandableMovesWidget(moves: pokemon.moves),
          ],
        ),
      ),
    );
  }
}

class HeaderWidget extends StatefulWidget {
  final Pokemon pokemon;
  const HeaderWidget({super.key, required this.pokemon});

  @override
  State<StatefulWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  late List<String> spriteUrls;
  int currentPage = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: spriteUrls.length,
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: spriteUrls[index],
                fit: BoxFit.contain,
                progressIndicatorBuilder:
                    (_, _, progressDownload) => CircularProgressIndicator(
                      value: progressDownload.progress,
                    ),
                errorWidget: (_, _, _) => const Icon(Icons.error),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(spriteUrls.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                width: currentPage == index ? 12.0 : 8.0,
                height: currentPage == index ? 12.0 : 8.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentPage == index ? Colors.blue : Colors.grey,
                ),
              );
            }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            widget.pokemon.name.capitalize(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8.0,
            children:
                widget.pokemon.types
                    .map(
                      (type) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 7.0,
                        ),
                        decoration: BoxDecoration(
                          color: typeColors[type.type.name] ?? Colors.grey,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          type.type.name.capitalize(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    spriteUrls = [
      if (widget.pokemon.sprites.frontDefault != null)
        widget.pokemon.sprites.frontDefault!,
      if (widget.pokemon.sprites.backDefault != null)
        widget.pokemon.sprites.backDefault!,
      if (widget.pokemon.sprites.frontShiny != null)
        widget.pokemon.sprites.frontShiny!,
      if (widget.pokemon.sprites.backShiny != null)
        widget.pokemon.sprites.backShiny!,
    ];

    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }
}

class BasicInfoWidget extends StatelessWidget {
  final Pokemon pokemon;
  const BasicInfoWidget({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final heightInMeters = pokemon.height / 10;
    final heightInFeet = heightInMeters * 3.28084;
    final weightInKg = pokemon.weight / 10;
    final weightInLbs = weightInKg * 2.20462;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Info',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Height: ${heightInMeters.toStringAsFixed(1)} m (${heightInFeet.toStringAsFixed(1)} ft)',
            ),
            Text(
              'Weight: ${weightInKg.toStringAsFixed(1)} kg (${weightInLbs.toStringAsFixed(1)} lbs)',
            ),
            Text('Species: ${pokemon.species.name.capitalize()}'),
            // TODO: description text here (need to fetch it from the api)
          ],
        ),
      ),
    );
  }
}

class StatsWidget extends StatelessWidget {
  final List<PokemonStat> stats;

  const StatsWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Base Stats',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            ...stats.map(
              (stat) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text(stat.stat.name.capitalize())),
                    Expanded(
                      flex: 3,
                      child: LinearProgressIndicator(
                        value: stat.baseStat / 255,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          statColors[stat.stat.name] ?? Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(stat.baseStat.toString()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AbilitiesWidget extends StatelessWidget {
  final List<PokemonAbility> abilities;

  const AbilitiesWidget({super.key, required this.abilities});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Abilities', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            ...abilities.map(
              (ability) => ListTile(
                title: Text(ability.ability.name.capitalize()),
                subtitle: Text(
                  ability.isHidden ? 'Hidden Ability' : 'Normal Ability',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpandableMovesWidget extends StatelessWidget {
  final List<PokemonMove> moves;

  const ExpandableMovesWidget({super.key, required this.moves});

  @override
  Widget build(BuildContext context) {
    final Map<String, List<PokemonMove>> movesByMethod = {};
    for (final move in moves) {
      for (final detail in move.versionGroupDetails) {
        final method = detail.moveLearnMethod.name;
        movesByMethod.putIfAbsent(method, () => []).add(move);
      }
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Move', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            ...movesByMethod.keys.map(
              (method) => ExpansionTile(
                title: Text(method.capitalize()),
                children:
                    movesByMethod[method]!
                        .map(
                          (move) => ListTile(
                            title: Text(move.move.name.capitalize()),
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
