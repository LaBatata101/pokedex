import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/custom/progress_indicator.dart';
import 'package:pokedex/pokeapi/entities/evolution.dart';
import 'package:pokedex/pokeapi/entities/pokemon.dart';
import 'package:pokedex/utils/string.dart';
import 'package:pokedex/viewmodels/pokemon_details_viewmodel.dart';
import 'package:pokedex/views/pokemon_details.dart';

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
