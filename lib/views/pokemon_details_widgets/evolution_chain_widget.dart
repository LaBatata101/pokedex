import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/custom/progress_indicator.dart';
import 'package:pokedex/pokeapi/entities/evolution.dart';
import 'package:pokedex/pokeapi/entities/pokemon.dart';
import 'package:pokedex/repositories/pokemon_repository.dart';
import 'package:pokedex/utils/logging.dart';
import 'package:pokedex/utils/string.dart';
import 'package:pokedex/viewmodels/pokemon_details_viewmodel.dart';
import 'package:pokedex/views/pokemon_details.dart';
import 'package:provider/provider.dart';

enum ConditionType {
  level,
  useItem,
  heldItem,
  trade,
  timeOfDay,
  happiness,
  affection,
  location,
  knownMove,
  knownMoveType,
  minBeauty,
  gender,
  relativePhysicalStats,
  needsOverworldRain,
  turnUpsideDown,
  other,
}

class ConditionDetail {
  final ConditionType type;
  final String displayValue;
  final String? iconIdentifier;
  final dynamic value;

  ConditionDetail({
    required this.type,
    required this.displayValue,
    this.iconIdentifier,
    this.value,
  });
}

class EvolutionChainWidget extends StatelessWidget {
  final PokemonDetailsViewModel viewModel;

  const EvolutionChainWidget(this.viewModel, {super.key});

  // Helper to find Pokemon detail by species name
  Pokemon? _findPokemonDetail(String speciesName) {
    try {
      return viewModel.pokemonEvolutionDetails.firstWhere((p) {
        return p.name.contains(speciesName);
      });
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

    // If there are no evolutions, just return the base form
    if (link.evolvesTo.isEmpty) {
      branches.add([
        _EvolutionStageWidget(
          pokemon: basePokemon,
          viewModel: viewModel,
          onTap: () => _navigateToPokemonDetails(context, basePokemon),
        ),
      ]);
    } else {
      // For each evolution path (supports branching)
      for (var nextLink in link.evolvesTo) {
        List<Widget> branch = [];

        final firstEvolutionConditions = _getEvolutionConditions(
          nextLink.evolutionDetails,
        );
        String? baseHeldItemName =
            firstEvolutionConditions
                    .firstWhere(
                      (cond) => cond.type == ConditionType.heldItem,
                      // Retorna um dummy se não encontrar para evitar erro no orElse
                      orElse:
                          () => ConditionDetail(
                            type: ConditionType.other,
                            displayValue: '',
                          ),
                    )
                    .value
                as String?;

        // Add base Pokemon
        branch.add(
          _EvolutionStageWidget(
            pokemon: basePokemon,
            viewModel: viewModel,
            onTap: () => _navigateToPokemonDetails(context, basePokemon),
            heldItemName: baseHeldItemName,
          ),
        );

        // Process this evolution branch
        _addEvolutionToBranch(
          context,
          nextLink,
          branch,
          firstEvolutionConditions,
        );
        branches.add(branch);
      }
    }

    return branches;
  }

  // Recursively add evolution stages to a branch
  void _addEvolutionToBranch(
    BuildContext context,
    ChainLink link,
    List<Widget> branch,
    List<ConditionDetail> conditions,
  ) {
    Pokemon? currentPokemon = _findPokemonDetail(link.species.name);
    if (currentPokemon == null) return;

    branch.add(
      _EvolutionArrow(conditions: conditions, theme: Theme.of(context)),
    );

    String? nextHeldItemName;
    ChainLink? nextLink;
    List<ConditionDetail> nextStepConditions = [];

    if (link.evolvesTo.isNotEmpty) {
      // gets the first branch
      nextLink = link.evolvesTo.first;
      nextStepConditions = _getEvolutionConditions(nextLink.evolutionDetails);
      nextHeldItemName =
          nextStepConditions
                  .firstWhere(
                    (cond) => cond.type == ConditionType.heldItem,
                    orElse:
                        () => ConditionDetail(
                          type: ConditionType.other,
                          displayValue: '',
                        ),
                  )
                  .value
              as String?;
    }

    branch.add(
      _EvolutionStageWidget(
        pokemon: currentPokemon,
        viewModel: viewModel,
        onTap: () => _navigateToPokemonDetails(context, currentPokemon),
        heldItemName: nextHeldItemName,
      ),
    );

    // If this Pokemon evolves further, continue the chain
    if (nextLink != null) {
      _addEvolutionToBranch(context, nextLink, branch, nextStepConditions);
    }
  }

  // Navigate to the selected Pokemon's details
  void _navigateToPokemonDetails(BuildContext context, Pokemon pokemon) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PokemonDetails(pokemon)),
    );
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
  final PokemonDetailsViewModel viewModel;
  final VoidCallback onTap;
  final String? heldItemName;

  const _EvolutionStageWidget({
    required this.pokemon,
    required this.onTap,
    required this.viewModel,
    this.heldItemName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final String imageUrl = pokemon.sprites.frontDefault ?? '';
    final String name = pokemon.formattedName;
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
        child: Stack(
          children: [
            Column(
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
                                  child: Center(
                                    child: PokeballProgressIndicator(),
                                  ),
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

            // Display the held item badge with improved tooltip
            if (heldItemName != null)
              Positioned(
                right: 5,
                bottom: 60,
                child: Tooltip(
                  message:
                      'Must hold ${heldItemName!.split('-').map((word) => word.capitalize()).join(' ')}',
                  child: InkWell(
                    onTap: () {
                      final repository = context.read<PokemonRepository>();
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: Text(
                                heldItemName!
                                    .split('-')
                                    .map((word) => word.capitalize())
                                    .join(' '),
                                style: TextStyle(color: primaryColor),
                              ),
                              content: FutureBuilder(
                                future: repository.getItemByName(heldItemName!),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final item = snapshot.data!;
                                    return Text(
                                      (item.flavorTextEntries
                                              .where(
                                                (flavor) =>
                                                    flavor.language.name ==
                                                    'en',
                                              )
                                              .toList()
                                            ..shuffle())
                                          .first
                                          .text
                                          .replaceAll('\n', ' '),
                                    );
                                  } else if (snapshot.hasError) {
                                    logger.e(
                                      "Error loading item info!",
                                      error: snapshot.error,
                                      stackTrace: snapshot.stackTrace,
                                    );
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.red[400],
                                          size: 48,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          "Could not load item information",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.red[700],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "There was a problem fetching data for this item. Please try again later.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return PokeballProgressIndicator(
                                    color: primaryColor,
                                    size: 35,
                                  );
                                },
                              ),
                              actions: [
                                TextButton(
                                  child: Text(
                                    'Close',
                                    style: TextStyle(color: primaryColor),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CachedNetworkImage(
                            imageUrl: _getItemUrl(heldItemName!),
                            placeholder:
                                (context, url) => const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: PokeballProgressIndicator(),
                                ),
                            errorWidget:
                                (context, url, error) => const Icon(
                                  Icons.inventory,
                                  color: Colors.white,
                                  size: 16,
                                ),
                            width: 20,
                            height: 20,
                          ),
                        ],
                      ),
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

class _EvolutionArrow extends StatelessWidget {
  final List<ConditionDetail> conditions;
  final ThemeData theme;

  const _EvolutionArrow({required this.conditions, required this.theme});

  Widget _buildConditionChip(ConditionDetail condition) {
    final primaryColor = theme.colorScheme.primary;
    Widget? icon;
    String label = condition.displayValue;
    Color? chipColor;

    switch (condition.type) {
      case ConditionType.useItem:
        icon = CachedNetworkImage(
          imageUrl: _getItemUrl(condition.iconIdentifier),
          width: 16,
          height: 16,
          placeholder:
              (context, url) => const SizedBox(
                width: 16,
                height: 16,
                child: PokeballProgressIndicator(),
              ),
          errorWidget:
              (context, url, error) => const Icon(
                Icons.inventory_2_outlined,
                size: 16,
                color: Colors.blueAccent,
              ),
        );
        chipColor = Colors.blueAccent.withValues(alpha: 0.15);
        break;
      case ConditionType.heldItem:
        // Skip held item conditions as they're shown by the pokemon widget
        return const SizedBox.shrink();
      case ConditionType.trade:
        icon = const Icon(
          Icons.swap_horiz,
          size: 16,
          color: Colors.purpleAccent,
        );
        chipColor = Colors.purpleAccent.withValues(alpha: 0.15);
        break;
      case ConditionType.timeOfDay:
        if (condition.iconIdentifier == 'day') {
          icon = const Icon(
            Icons.wb_sunny_outlined,
            size: 16,
            color: Colors.orangeAccent,
          );
          chipColor = Colors.orangeAccent.withValues(alpha: 0.15);
        } else if (condition.iconIdentifier == 'night') {
          icon = const Icon(
            Icons.nightlight_round,
            size: 16,
            color: Colors.indigoAccent,
          );
          chipColor = Colors.indigoAccent.withValues(alpha: 0.15);
        }
        break;
      case ConditionType.happiness:
        icon = const Icon(
          Icons.favorite_border,
          size: 16,
          color: Colors.pinkAccent,
        );
        chipColor = Colors.pinkAccent.withValues(alpha: 0.15);
        break;
      case ConditionType.affection:
        icon = const Icon(Icons.favorite, size: 16, color: Colors.redAccent);
        chipColor = Colors.redAccent.withValues(alpha: 0.15);
        break;
      case ConditionType.location:
        icon = const Icon(
          Icons.location_on_outlined,
          size: 16,
          color: Colors.green,
        );
        chipColor = Colors.green.withValues(alpha: 0.15);
        break;
      case ConditionType.gender:
        if (condition.value == 1) {
          icon = const Icon(Icons.female, size: 16, color: Colors.pink);
          chipColor = Colors.pink.withValues(alpha: 0.15);
        } else if (condition.value == 2) {
          icon = const Icon(Icons.male, size: 16, color: Colors.blue);
          chipColor = Colors.blue.withValues(alpha: 0.15);
        }
        break;
      case ConditionType.needsOverworldRain:
        icon = const Icon(
          Icons.water_drop_outlined,
          size: 16,
          color: Colors.blue,
        );
        chipColor = Colors.blue.withValues(alpha: 0.15);
        break;
      case ConditionType.level:
        icon = const Icon(Icons.upgrade, size: 16, color: Colors.amber);
        chipColor = Colors.amber.withValues(alpha: 0.15);
        break;
      case ConditionType.knownMove:
      case ConditionType.knownMoveType:
        icon = const Icon(Icons.flash_on, size: 16, color: Colors.orangeAccent);
        chipColor = Colors.orangeAccent.withValues(alpha: 0.15);
        break;
      case ConditionType.minBeauty:
        icon = const Icon(Icons.spa, size: 16, color: Colors.pinkAccent);
        chipColor = Colors.pinkAccent.withValues(alpha: 0.15);
        break;
      case ConditionType.relativePhysicalStats:
        icon = const Icon(Icons.compare_arrows, size: 16, color: Colors.teal);
        chipColor = Colors.teal.withValues(alpha: 0.15);
        break;
      case ConditionType.turnUpsideDown:
        icon = const Icon(
          Icons.screen_rotation,
          size: 16,
          color: Colors.purpleAccent,
        );
        chipColor = Colors.purpleAccent.withValues(alpha: 0.15);
        break;
      default:
        chipColor = primaryColor.withValues(alpha: 0.15);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor ?? primaryColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon, const SizedBox(width: 4)],
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = theme.colorScheme.primary;

    // Group similar conditions together
    List<Widget> conditionChips = [];

    // Filter out held item conditions as they're shown on the Pokémon avatar
    var displayableConditions =
        conditions.where((c) => c.type != ConditionType.heldItem).toList();

    // Create condition chips
    conditionChips = displayableConditions.map(_buildConditionChip).toList();

    // Make sure we don't have empty widgets
    conditionChips =
        conditionChips.where((w) {
          if (w is SizedBox) {
            return w.width != null && w.width! > 0;
          }
          return true;
        }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Arrow with gradient background
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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

          // Condition chips
          if (conditionChips.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                runSpacing: 4,
                children: conditionChips,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

List<ConditionDetail> _getEvolutionConditions(List<EvolutionDetail> details) {
  if (details.isEmpty) return [];
  List<ConditionDetail> conditions = [];

  final detail = details.first;
  final triggerName = detail.trigger.name;

  // Set up trigger condition first
  if (triggerName == 'level-up') {
    if (detail.minLevel != null) {
      conditions.add(
        ConditionDetail(
          type: ConditionType.level,
          displayValue: "Level ${detail.minLevel}",
          value: detail.minLevel,
        ),
      );
    } else {
      // Generic level up with no specific level
      conditions.add(
        ConditionDetail(type: ConditionType.level, displayValue: "Level Up"),
      );
    }
  } else if (triggerName == 'trade') {
    conditions.add(
      ConditionDetail(
        type: ConditionType.trade,
        displayValue: "Trade",
        iconIdentifier: 'trade',
      ),
    );
  } else if (triggerName == 'use-item' && detail.item != null) {
    String itemName = detail.item!.name
        .split('-')
        .map((word) => word.capitalize())
        .join(' ');
    conditions.add(
      ConditionDetail(
        type: ConditionType.useItem,
        displayValue: itemName,
        iconIdentifier: detail.item!.name,
        value: detail.item!.name,
      ),
    );
  } else {
    // Other triggers
    conditions.add(
      ConditionDetail(
        type: ConditionType.other,
        displayValue: triggerName
            .split('-')
            .map((e) => e.capitalize())
            .join(' '),
      ),
    );
  }

  // Add additional conditions
  if (detail.heldItem != null) {
    String itemName = detail.heldItem!.name
        .split('-')
        .map((word) => word.capitalize())
        .join(' ');
    conditions.add(
      ConditionDetail(
        type: ConditionType.heldItem,
        displayValue: "Hold $itemName",
        iconIdentifier: detail.heldItem!.name,
        value: detail.heldItem!.name,
      ),
    );
  }

  if (detail.timeOfDay.isNotEmpty) {
    conditions.add(
      ConditionDetail(
        type: ConditionType.timeOfDay,
        displayValue: detail.timeOfDay.capitalize(),
        iconIdentifier: detail.timeOfDay,
        value: detail.timeOfDay,
      ),
    );
  }

  if (detail.minHappiness != null) {
    conditions.add(
      ConditionDetail(
        type: ConditionType.happiness,
        displayValue: "High Friendship",
        value: detail.minHappiness,
      ),
    );
  }

  if (detail.minAffection != null) {
    conditions.add(
      ConditionDetail(
        type: ConditionType.affection,
        displayValue: "Affection ${detail.minAffection}",
        value: detail.minAffection,
      ),
    );
  }

  if (detail.minBeauty != null) {
    conditions.add(
      ConditionDetail(
        type: ConditionType.minBeauty,
        displayValue: "Beauty ${detail.minBeauty}+",
        value: detail.minBeauty,
      ),
    );
  }

  if (detail.location != null) {
    String locationName = detail.location!.name
        .split('-')
        .map((word) => word.capitalize())
        .join(' ');
    conditions.add(
      ConditionDetail(
        type: ConditionType.location,
        displayValue: locationName,
        value: detail.location!.name,
      ),
    );
  }

  if (detail.knownMove != null) {
    String moveName = detail.knownMove!.name
        .split('-')
        .map((word) => word.capitalize())
        .join(' ');
    conditions.add(
      ConditionDetail(
        type: ConditionType.knownMove,
        displayValue: "Knows $moveName",
        value: detail.knownMove!.name,
      ),
    );
  }

  if (detail.knownMoveType != null) {
    String typeName = detail.knownMoveType!.name.capitalize();
    conditions.add(
      ConditionDetail(
        type: ConditionType.knownMoveType,
        displayValue: "$typeName Move",
        value: detail.knownMoveType!.name,
      ),
    );
  }

  if (detail.gender != null) {
    String genderDisplay = detail.gender == 1 ? "Female" : "Male";
    conditions.add(
      ConditionDetail(
        type: ConditionType.gender,
        displayValue: genderDisplay,
        value: detail.gender,
      ),
    );
  }

  if (detail.relativePhysicalStats != null) {
    String statsDisplay;
    if (detail.relativePhysicalStats == 1) {
      statsDisplay = "Atk > Def";
    } else if (detail.relativePhysicalStats == -1) {
      statsDisplay = "Atk < Def";
    } else {
      statsDisplay = "Atk = Def";
    }
    conditions.add(
      ConditionDetail(
        type: ConditionType.relativePhysicalStats,
        displayValue: statsDisplay,
        value: detail.relativePhysicalStats,
      ),
    );
  }

  if (detail.needsOverworldRain) {
    conditions.add(
      ConditionDetail(
        type: ConditionType.needsOverworldRain,
        displayValue: "Rainy Weather",
      ),
    );
  }

  if (detail.turnUpsideDown) {
    conditions.add(
      ConditionDetail(
        type: ConditionType.turnUpsideDown,
        displayValue: "Turn Device Upside Down",
      ),
    );
  }

  return conditions;
}

String _getItemUrl(String? itemName) {
  return "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/$itemName.png";
}
