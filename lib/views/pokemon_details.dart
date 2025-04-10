import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokedex/custom/progress_indicator.dart';
import 'package:pokedex/custom/sparkling_widget.dart';
import 'package:pokedex/pokeapi/entities/evolution.dart';
import 'package:pokedex/pokeapi/entities/pokemon.dart';
import 'package:pokedex/repositories/pokemon_repository.dart';
import 'package:pokedex/utils/string.dart';
import 'package:pokedex/viewmodels/pokemon_details_viewmodel.dart';
import 'package:pokedex/views/pokemon_details_widgets/moves_widget.dart';
import 'package:provider/provider.dart';

// Enhanced type colors with primary, secondary, and text colors for better theming
final pokemonTypeThemes = {
  'normal': PokemonTypeTheme(
    primary: Color(0xFFA8A878),
    secondary: Color(0xFFC6C6A7),
    text: Colors.white,
  ),
  'fire': PokemonTypeTheme(
    primary: Color(0xFFF08030),
    secondary: Color(0xFFF5AC78),
    text: Colors.white,
  ),
  'water': PokemonTypeTheme(
    primary: Color(0xFF6890F0),
    secondary: Color(0xFF9DB7F5),
    text: Colors.white,
  ),
  'grass': PokemonTypeTheme(
    primary: Color(0xFF78C850),
    secondary: Color(0xFFA7DB8D),
    text: Colors.white,
  ),
  'electric': PokemonTypeTheme(
    primary: Color(0xFFF8D030),
    secondary: Color(0xFFFAE078),
    text: Colors.black,
  ),
  'ice': PokemonTypeTheme(
    primary: Color(0xFF98D8D8),
    secondary: Color(0xFFBCE6E6),
    text: Colors.black,
  ),
  'fighting': PokemonTypeTheme(
    primary: Color(0xFFC03028),
    secondary: Color(0xFFD67873),
    text: Colors.white,
  ),
  'poison': PokemonTypeTheme(
    primary: Color(0xFFA040A0),
    secondary: Color(0xFFC183C1),
    text: Colors.white,
  ),
  'ground': PokemonTypeTheme(
    primary: Color(0xFFE0C068),
    secondary: Color(0xFFEBD69D),
    text: Colors.black,
  ),
  'flying': PokemonTypeTheme(
    primary: Color(0xFFA890F0),
    secondary: Color(0xFFC6B7F5),
    text: Colors.white,
  ),
  'psychic': PokemonTypeTheme(
    primary: Color(0xFFF85888),
    secondary: Color(0xFFFA92B2),
    text: Colors.white,
  ),
  'bug': PokemonTypeTheme(
    primary: Color(0xFFA8B820),
    secondary: Color(0xFFC6D16E),
    text: Colors.white,
  ),
  'rock': PokemonTypeTheme(
    primary: Color(0xFFB8A038),
    secondary: Color(0xFFD1C17D),
    text: Colors.white,
  ),
  'ghost': PokemonTypeTheme(
    primary: Color(0xFF705898),
    secondary: Color(0xFF9E96BC),
    text: Colors.white,
  ),
  'dragon': PokemonTypeTheme(
    primary: Color(0xFF7038F8),
    secondary: Color(0xFF9E86FA),
    text: Colors.white,
  ),
  'dark': PokemonTypeTheme(
    primary: Color(0xFF705848),
    secondary: Color(0xFF8E796B),
    text: Colors.white,
  ),
  'steel': PokemonTypeTheme(
    primary: Color(0xFFB8B8D0),
    secondary: Color(0xFFD1D1E0),
    text: Colors.black,
  ),
  'fairy': PokemonTypeTheme(
    primary: Color(0xFFEE99AC),
    secondary: Color(0xFFF4BDC9),
    text: Colors.black,
  ),
};

// Class to hold theme details for a Pokémon type
class PokemonTypeTheme {
  final Color primary; // Main color for app bar, buttons
  final Color secondary; // Accent color for cards, indicators
  final Color text; // Text color for elements on primary/secondary

  const PokemonTypeTheme({
    required this.primary,
    required this.secondary,
    required this.text,
  });
}

final statColors = {
  'hp': Colors.green,
  'attack': Colors.red,
  'defense': Colors.blue,
  'special-attack': Colors.orange,
  'special-defense': Colors.purple,
  'speed': Colors.yellow,
};

const typeColors = {
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

  // Get the theme based on the Pokémon's primary type
  PokemonTypeTheme _getTheme() {
    final primaryTypeName = pokemon.types.first.type.name;
    return pokemonTypeThemes[primaryTypeName] ??
        const PokemonTypeTheme(
          primary: Colors.grey,
          secondary: Color(0xFFCCCCCC),
          text: Colors.white,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = _getTheme();

    return ChangeNotifierProvider<PokemonDetailsViewModel>(
      create:
          (context) => PokemonDetailsViewModel(
            context.read<PokemonRepository>(),
            pokemon,
          )..init(),
      child: Theme(
        // Create a themed context that will apply throughout the page
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: theme.primary,
            secondary: theme.secondary,
            onPrimary: theme.text,
            onSecondary: theme.text,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: theme.primary,
            foregroundColor: theme.text,
            elevation: 4,
            centerTitle: true,
            shadowColor: Colors.black26,
          ),
          cardTheme: CardTheme(
            elevation: 3,
            shadowColor: Colors.black38,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          progressIndicatorTheme: ProgressIndicatorThemeData(
            color: theme.primary,
            linearTrackColor: theme.secondary.withValues(alpha: 0.3),
          ),
          dividerTheme: DividerTheme.of(
            context,
          ).copyWith(color: theme.secondary),
        ),
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nº ${pokemon.id.toString().padLeft(4, '0')}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.text,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  pokemon.name.capitalize(),
                  style: TextStyle(color: theme.text),
                ),
              ],
            ),
          ),
          body: Consumer<PokemonDetailsViewModel>(
            builder: (context, viewModel, child) {
              return Container(
                // Background gradient for the entire page
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.primary.withValues(alpha: 0.1),
                      Colors.white,
                    ],
                    stops: const [0.0, 0.3],
                  ),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        HeaderWidget(pokemon, theme),
                        BasicInfoWidget(pokemon, viewModel, theme),
                        StatsWidget(pokemon.stats),
                        AbilitiesWidget(pokemon.abilities),
                        CriesWidget(pokemon.cries, theme),
                        EvolutionChainWidget(viewModel),
                        MovesWidget(pokemon.moves, viewModel),
                        // Footer space for better scrolling UX
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class HeaderWidget extends StatefulWidget {
  final Pokemon pokemon;
  final PokemonTypeTheme theme;

  const HeaderWidget(this.pokemon, this.theme, {super.key});

  @override
  State<StatefulWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget>
    with SingleTickerProviderStateMixin {
  late List<String> spriteUrls;
  int currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  bool _isShinySprite(String url) {
    return url.contains("shiny");
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        color: widget.theme.primary.withValues(alpha: 0.2),
      ),
      child: Column(
        children: [
          // Animated image gallery
          SizedBox(
            height: 280,
            child: PageView.builder(
              itemCount: spriteUrls.length,
              itemBuilder: (context, index) {
                Widget imageWidget = CachedNetworkImage(
                  width: 220,
                  height: 220,
                  imageUrl: spriteUrls[index],
                  fit: BoxFit.contain,
                  progressIndicatorBuilder:
                      (_, __, progressDownload) => Center(
                        child: PokeballProgressIndicator(
                          color: widget.theme.primary,
                        ),
                      ),
                  errorWidget:
                      (_, __, ___) => const Center(
                        child: Icon(Icons.error, size: 64, color: Colors.red),
                      ),
                );

                if (index == 0) {
                  imageWidget = Hero(
                    tag: 'pokemon-${widget.pokemon.id}',
                    transitionOnUserGestures: true,
                    child: imageWidget,
                  );
                }

                return Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    // Subtle background shape for the image
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Container(
                          width: 220 + (_animation.value * 20),
                          height: 220 + (_animation.value * 20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.theme.secondary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        );
                      },
                    ),

                    // Apply shiny effect or regular image
                    _isShinySprite(spriteUrls[index])
                        ? ShinySparkleEffect(child: imageWidget)
                        : imageWidget,

                    // Shiny indicator badge
                    if (_isShinySprite(spriteUrls[index]))
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.white, size: 18),
                              SizedBox(width: 4),
                              Text(
                                'Shiny',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
            ),
          ),

          // Image pagination indicators
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(spriteUrls.length, (index) {
                final isActive = currentPage == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  width: isActive ? 12.0 : 8.0,
                  height: isActive ? 12.0 : 8.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? widget.theme.primary : Colors.grey,
                    boxShadow:
                        isActive
                            ? [
                              BoxShadow(
                                color: widget.theme.primary.withValues(
                                  alpha: 0.5,
                                ),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ]
                            : null,
                  ),
                );
              }),
            ),
          ),

          // Sprite type indicator
          if (spriteUrls.isNotEmpty)
            Text(
              _isShinySprite(spriteUrls[currentPage])
                  ? 'Shiny ${currentPage % 2 == 0 ? "Front" : "Back"} View'
                  : '${currentPage % 2 == 0 ? "Front" : "Back"} View',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: widget.theme.primary,
              ),
            ),

          // Pokémon type badges
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12.0,
              children:
                  widget.pokemon.types.map((type) {
                    final typeTheme =
                        pokemonTypeThemes[type.type.name] ??
                        pokemonTypeThemes['normal']!;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: typeTheme.primary,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: typeTheme.primary.withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        type.type.name.capitalize(),
                        style: TextStyle(
                          color: typeTheme.text,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class BasicInfoWidget extends StatelessWidget {
  final Pokemon pokemon;
  final PokemonDetailsViewModel viewModel;
  final PokemonTypeTheme theme;
  const BasicInfoWidget(this.pokemon, this.viewModel, this.theme, {super.key});

  Widget pokemonDescription() {
    return InfoRow(
      icon: Icons.description,
      label: 'Description',
      value:
          viewModel.isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PokeballProgressIndicator(color: theme.primary),
                    SizedBox(height: 16),
                    Text('Loading Pokémon description...'),
                  ],
                ),
              )
              : Text(
                viewModel.pokemonDescription,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final heightInMeters = pokemon.height / 10;
    final heightInFeet = heightInMeters * 3.28084;
    final weightInKg = pokemon.weight / 10;
    final weightInLbs = weightInKg * 2.20462;

    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Basic Info',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            InfoRow(
              icon: Icons.height,
              label: 'Height',
              value: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${heightInMeters.toStringAsFixed(1)} m',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('(${heightInFeet.toStringAsFixed(1)} ft)'),
                ],
              ),
            ),

            const SizedBox(height: 12),

            InfoRow(
              icon: Icons.fitness_center,
              label: 'Weight',
              value: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${weightInKg.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('(${weightInLbs.toStringAsFixed(1)} lbs)'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            InfoRow(
              icon: Icons.category,
              label: 'Species',
              value: Text(
                pokemon.species.name.capitalize(),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 12),
            pokemonDescription(),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primaryColor, size: 20),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              value,
            ],
          ),
        ),
      ],
    );
  }
}

class StatsWidget extends StatelessWidget {
  final List<PokemonStat> stats;

  const StatsWidget(this.stats, {super.key});

  Color _getStatColor(String statName) {
    final baseColors = {
      'hp': Colors.green,
      'attack': Colors.red,
      'defense': Colors.blue,
      'special-attack': Colors.orange,
      'special-defense': Colors.purple,
      'speed': Colors.yellow,
    };

    return baseColors[statName] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    // Use the theme from the context (which was set in PokemonDetails)
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Base Stats',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            ...stats.map((stat) {
              final statValue = stat.baseStat;
              final statColor = _getStatColor(stat.stat.name);
              final statPercentage = statValue / 255;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          stat.stat.name.capitalize(),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          statValue.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: statValue > 100 ? primaryColor : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          height: 8,
                          width:
                              MediaQuery.of(context).size.width *
                              0.78 *
                              statPercentage,
                          decoration: BoxDecoration(
                            color: statColor,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: statColor.withValues(alpha: 0.4),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class AbilitiesWidget extends StatelessWidget {
  final List<PokemonAbility> abilities;

  const AbilitiesWidget(this.abilities, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Abilities',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            ...abilities.map(
              (ability) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    // Ability icon/indicator
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          ability.isHidden
                              ? Icons.visibility_off
                              : Icons.flash_on,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Ability details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ability.ability.name.capitalize(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  ability.isHidden
                                      ? Colors.purple.withValues(alpha: 0.1)
                                      : primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              ability.isHidden
                                  ? 'Hidden Ability'
                                  : 'Normal Ability',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    ability.isHidden
                                        ? Colors.purple
                                        : primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Info button for future implementation
                    IconButton(
                      icon: Icon(Icons.info_outline, color: Colors.grey[400]),
                      onPressed: () {
                        // TODO: Show ability details/description
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${ability.ability.name.capitalize()} description not available yet',
                            ),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            if (abilities.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No abilities information available',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CriesWidget extends StatefulWidget {
  final PokemonCries cries;
  final PokemonTypeTheme theme;

  const CriesWidget(this.cries, this.theme, {super.key});

  @override
  State<StatefulWidget> createState() => _CriesWidgetState();
}

class _CriesWidgetState extends State<CriesWidget> {
  final AudioPlayer audioPlayer = AudioPlayer();
  String? currentlyPlaying;
  bool isPlaying = false;
  final double volume = 1.0;

  @override
  void initState() {
    super.initState();
    audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        setState(() {
          isPlaying = false;
          currentlyPlaying = null;
        });
      }
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> playCry(String? url, String cryType) async {
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$cryType cry is not available for this Pokémon'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      if (isPlaying) {
        await audioPlayer.stop();
      }

      setState(() {
        isPlaying = true;
        currentlyPlaying = cryType;
      });

      HapticFeedback.mediumImpact();

      await audioPlayer.setVolume(volume);
      await audioPlayer.play(UrlSource(url));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Playing $cryType cry...'),
            duration: const Duration(seconds: 1),
            backgroundColor: widget.theme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isPlaying = false;
          currentlyPlaying = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing sound: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final hasCries = widget.cries.latest != null || widget.cries.legacy != null;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.music_note, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Pokémon Cries',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            if (hasCries) ...[
              if (widget.cries.latest != null)
                CryButton(
                  label: 'Modern Cry',
                  description: 'Current generation sound',
                  icon: Icons.surround_sound,
                  isPlaying: isPlaying && currentlyPlaying == 'Modern',
                  theme: widget.theme,
                  onTap: () => playCry(widget.cries.latest, 'Modern'),
                ),
              if (widget.cries.latest != null && widget.cries.legacy != null)
                const SizedBox(height: 12),
              if (widget.cries.legacy != null)
                CryButton(
                  label: 'Legacy Cry',
                  description: 'Classic 8-bit sound',
                  icon: Icons.music_video,
                  isPlaying: isPlaying && currentlyPlaying == 'Legacy',
                  theme: widget.theme,
                  onTap: () => playCry(widget.cries.legacy, 'Legacy'),
                ),
              if (!hasCries)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.volume_off,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No cry sound available for this Pokémon',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class CryButton extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final bool isPlaying;
  final PokemonTypeTheme theme;
  final VoidCallback onTap;

  const CryButton({
    super.key,
    required this.label,
    required this.description,
    required this.icon,
    required this.isPlaying,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPlaying ? theme.primary : Colors.grey[300]!,
            width: isPlaying ? 2 : 1,
          ),
          color:
              isPlaying
                  ? theme.primary.withValues(alpha: 0.1)
                  : Colors.grey[100],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPlaying ? theme.primary : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  key: ValueKey<bool>(isPlaying),
                  color: isPlaying ? theme.text : theme.primary,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Cry details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isPlaying ? theme.primary : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Cry type icon
            Icon(
              icon,
              color: isPlaying ? theme.primary : Colors.grey[600],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class EvolutionChainWidget extends StatelessWidget {
  final PokemonDetailsViewModel viewModel;

  const EvolutionChainWidget(this.viewModel, {super.key});

  // Helper to find Pokemon detail by species name
  Pokemon? _findPokemonDetail(String speciesName) {
    try {
      return viewModel.pokemonEvolutionDetails.firstWhere(
        (p) => p.name.toLowerCase() == speciesName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Process the evolution chains to handle branched evolutions
  List<List<Widget>> _buildEvolutionBranches(
    BuildContext context,
    ChainLink link,
  ) {
    List<List<Widget>> branches = [];

    // Start with the base form
    Pokemon? basePokemon = _findPokemonDetail(link.species.name);
    if (basePokemon == null) return branches;

    // For each evolution path (supports branching)
    for (var nextLink in link.evolvesTo) {
      List<Widget> branch = [];

      // Add base Pokemon
      branch.add(
        _EvolutionStageWidget(
          pokemon: basePokemon,
          onTap: () => _navigateToPokemonDetails(context, basePokemon),
        ),
      );

      // Process this evolution branch
      _addEvolutionToBranch(context, nextLink, branch);
      branches.add(branch);
    }

    // If there are no evolutions, just return the base form
    if (branches.isEmpty) {
      branches.add([
        _EvolutionStageWidget(
          pokemon: basePokemon,
          onTap: () => _navigateToPokemonDetails(context, basePokemon),
        ),
      ]);
    }

    return branches;
  }

  // Recursively add evolution stages to a branch
  void _addEvolutionToBranch(
    BuildContext context,
    ChainLink link,
    List<Widget> branch,
  ) {
    Pokemon? currentPokemon = _findPokemonDetail(link.species.name);
    if (currentPokemon == null) return;

    // Add evolution arrow with condition
    String evolutionCondition = _getEvolutionCondition(link.evolutionDetails);
    branch.add(
      _EvolutionArrow(condition: evolutionCondition, theme: Theme.of(context)),
    );

    // Add the Pokemon
    branch.add(
      _EvolutionStageWidget(
        pokemon: currentPokemon,
        onTap: () => _navigateToPokemonDetails(context, currentPokemon),
      ),
    );

    // If this Pokemon evolves further, continue the chain
    if (link.evolvesTo.isNotEmpty) {
      _addEvolutionToBranch(context, link.evolvesTo.first, branch);
    }
  }

  // Navigate to the selected Pokemon's details
  void _navigateToPokemonDetails(BuildContext context, Pokemon pokemon) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PokemonDetails(pokemon: pokemon)),
    );
  }

  // Enhanced evolution condition display
  String _getEvolutionCondition(List<EvolutionDetail> details) {
    if (details.isEmpty) return "";

    // Find the appropriate detail to display
    for (var detail in details) {
      // Level-up evolution
      if (detail.trigger.name == 'level-up') {
        if (detail.minLevel != null) {
          return "Level ${detail.minLevel}";
        }
        if (detail.minHappiness != null) {
          return "Happiness ${detail.minHappiness}";
        }
        if (detail.timeOfDay.isNotEmpty) {
          return "${detail.timeOfDay.capitalize()} time";
        }
        return "Level up";
      }

      // Trade evolution
      if (detail.trigger.name == 'trade') {
        if (detail.heldItem != null) {
          String itemName = detail.heldItem!.name
              .split('-')
              .map((word) => word.capitalize())
              .join(' ');
          return "Trade with $itemName";
        }
        return "Trade";
      }

      // Item evolution
      if (detail.trigger.name == 'use-item' && detail.item != null) {
        String itemName = detail.item!.name
            .split('-')
            .map((word) => word.capitalize())
            .join(' ');
        return itemName;
      }
    }

    // Default fallback
    return details.first.trigger.name
        .split('-')
        .map((word) => word.capitalize())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PokeballProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading Pokémon evolution details...'),
          ],
        ),
      );
    }

    final branches = _buildEvolutionBranches(
      context,
      viewModel.evolutionChain!.chain,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                Icon(Icons.account_tree_outlined, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Evolution Chain',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Evolution branches
            for (int i = 0; i < branches.length; i++) ...[
              if (i > 0) const SizedBox(height: 24),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: branches[i],
                  ),
                ),
              ),
            ],

            // If there's no evolution chain data
            if (branches.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.remove_circle_outline,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'This Pokémon does not evolve',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
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

class _EvolutionStageWidget extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback onTap;

  const _EvolutionStageWidget({required this.pokemon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final String imageUrl = pokemon.sprites.frontDefault ?? '';
    final String name = pokemon.name.capitalize();
    final String id = "#${pokemon.id.toString().padLeft(3, '0')}";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pokemon image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child:
                  imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        placeholder:
                            (context, url) => const SizedBox(
                              width: 60,
                              height: 60,
                              child: Center(child: PokeballProgressIndicator()),
                            ),
                        errorWidget:
                            (context, url, error) =>
                                const Icon(Icons.error_outline, size: 40),
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      )
                      : const SizedBox(
                        width: 80,
                        height: 80,
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
            ),
            const SizedBox(height: 8),

            // Pokemon name
            Text(
              name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Pokemon ID
            Text(
              id,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),

            // Pokemon types
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  pokemon.types.take(2).map((type) {
                    final typeTheme =
                        pokemonTypeThemes[type.type.name] ??
                        pokemonTypeThemes['normal']!;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: typeTheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        type.type.name.capitalize(),
                        style: TextStyle(
                          color: typeTheme.text,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _EvolutionArrow extends StatelessWidget {
  final String condition;
  final ThemeData theme;

  const _EvolutionArrow({required this.condition, required this.theme});

  @override
  Widget build(BuildContext context) {
    final primaryColor = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.2),
                  primaryColor.withValues(alpha: 0.3),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_forward, color: primaryColor, size: 20),
              ],
            ),
          ),
          if (condition.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                condition,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
