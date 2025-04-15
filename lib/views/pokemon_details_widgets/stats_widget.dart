import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/custom/paginated_list_view.dart';
import 'package:pokedex/custom/progress_indicator.dart';
import 'package:pokedex/pokeapi/entities/common.dart';
import 'package:pokedex/pokeapi/entities/pokemon.dart';
import 'package:pokedex/repositories/pokemon_repository.dart';
import 'package:pokedex/utils/logging.dart';
import 'package:pokedex/utils/string.dart';
import 'package:pokedex/viewmodels/pokemon_details_viewmodel.dart';
import 'package:pokedex/views/pokemon_details.dart';
import 'package:provider/provider.dart';

class StatsWidget extends StatefulWidget {
  final Pokemon pokemon;
  final PokemonDetailsViewModel viewModel;
  final PokemonTypeTheme typeTheme;

  const StatsWidget(this.pokemon, this.viewModel, this.typeTheme, {super.key});

  @override
  State<StatsWidget> createState() => _StatsWidgetState();
}

class _StatsWidgetState extends State<StatsWidget> {
  Pokemon? comparisonPokemon;
  List<PokemonStat>? comparisonStats;
  bool isComparing = false;

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

  void _showPokemonSearchDialog() async {
    final result = await showDialog<Pokemon>(
      context: context,
      builder:
          (context) => PokemonSearchDialog(
            currentPokemon: widget.pokemon,
            typeTheme: widget.typeTheme,
          ),
    );

    if (result != null) {
      setState(() {
        isComparing = true;
        comparisonPokemon = result;
        comparisonStats = result.stats;
      });
    }
  }

  void _closeComparison() {
    setState(() {
      isComparing = false;
      comparisonPokemon = null;
      comparisonStats = null;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                const Spacer(),
                if (isComparing)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _closeComparison,
                    tooltip: 'Close comparison',
                    color: theme.colorScheme.secondary,
                  )
                else
                  ElevatedButton.icon(
                    icon: const Icon(Icons.compare_arrows, size: 16),
                    label: const Text(
                      'Compare',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: _showPokemonSearchDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary.withValues(
                        alpha: 0.3,
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),

            if (isComparing && comparisonPokemon != null)
              _buildComparisonHeader(theme)
            else
              const SizedBox.shrink(),

            ...widget.pokemon.stats.asMap().entries.map((entry) {
              final stat = entry.value;
              final comparisonStat =
                  isComparing &&
                          comparisonStats != null &&
                          entry.key < comparisonStats!.length
                      ? comparisonStats![entry.key]
                      : null;

              return isComparing
                  ? _buildComparisonStatRow(stat, comparisonStat, theme)
                  : _buildSingleStatRow(stat, theme);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                widget.pokemon.name.capitalize(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(width: 2, height: 24, color: Colors.grey[300]),
          Expanded(
            child: Center(
              child: Text(
                comparisonPokemon!.name.capitalize(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleStatRow(PokemonStat stat, ThemeData theme) {
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
                  color: statValue > 100 ? theme.colorScheme.primary : null,
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
                    MediaQuery.of(context).size.width * 0.78 * statPercentage,
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
  }

  Widget _buildComparisonStatRow(
    PokemonStat stat,
    PokemonStat? comparisonStat,
    ThemeData theme,
  ) {
    final statValue = stat.baseStat;
    final comparisonStatValue = comparisonStat?.baseStat ?? 0;
    final statColor = _getStatColor(stat.stat.name);
    final statPercentage = statValue / 255;
    final comparisonStatPercentage = comparisonStatValue / 255;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stat.stat.name.capitalize(),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              // First Pokémon's stat
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      statValue.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            statValue > comparisonStatValue
                                ? Colors.green[700]
                                : (statValue < comparisonStatValue
                                    ? Colors.red
                                    : null),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 800),
                            height: 8,
                            width:
                                MediaQuery.of(context).size.width *
                                0.35 *
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Divider
              Container(
                width: 20,
                height: 30,
                alignment: Alignment.center,
                child: Container(width: 1, height: 24, color: Colors.grey[300]),
              ),

              // Second Pokémon's stat
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comparisonStatValue.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            comparisonStatValue > statValue
                                ? Colors.green[700]
                                : (comparisonStatValue < statValue
                                    ? Colors.red
                                    : null),
                      ),
                    ),
                    const SizedBox(height: 2),
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
                              0.35 *
                              comparisonStatPercentage,
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PokemonSearchDialog extends StatefulWidget {
  final Pokemon currentPokemon;
  final PokemonTypeTheme typeTheme;

  const PokemonSearchDialog({
    required this.currentPokemon,
    required this.typeTheme,
    super.key,
  });

  @override
  State<PokemonSearchDialog> createState() => _PokemonSearchDialogState();
}

class _PokemonSearchDialogState extends State<PokemonSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<NamedAPIResource> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';
  Timer? _debounceTimer;
  late PokemonRepository _repository;
  late NamedAPIResourceList _allPokemonResources;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _repository = context.read<PokemonRepository>();
    _isLoading = true;
    _repository.getAllPokemons().then((result) {
      setState(() {
        _allPokemonResources = result;
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _searchPokemon(String query) async {
    if (_isLoading) return;

    final queryNormalized = query.trim().toLowerCase();
    if (queryNormalized.isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final results =
          _allPokemonResources.results
              .where((p) => p.name.toLowerCase().contains(queryNormalized))
              .toList();
      if (results.isNotEmpty) {
        setState(() {
          _searchResults = results;
        });
      } else {
        setState(() {
          _errorMessage = 'No Pokémon found matching "$query"';
        });
      }
    } catch (e, s) {
      logger.e(
        "Error searching for Pokémon $queryNormalized",
        error: e,
        stackTrace: s,
      );
      setState(() {
        _errorMessage = 'Error searching for Pokémon: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Compare Stats',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Search for a Pokémon to compare with ${widget.currentPokemon.name.capitalize()}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter Pokémon name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
              onChanged: (query) {
                // Cancel previous timer if it exists and is active
                _debounceTimer?.cancel();
                _debounceTimer = Timer(const Duration(milliseconds: 600), () {
                  _searchPokemon(query);
                });
              },
              textInputAction: TextInputAction.search,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              Center(
                child: PokeballProgressIndicator(
                  color: widget.typeTheme.primary,
                ),
              )
            else if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              )
            else
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: PaginatedListView(
                    key: ValueKey(_searchResults),
                    shrinkWrap: true,
                    itemsPerPage: _pageSize,
                    emptyListIndicator: SizedBox.shrink(),
                    fetchPage: (_, currentItemsCount) {
                      return Future.wait(
                        _searchResults
                            .skip(currentItemsCount)
                            .take(_pageSize)
                            .map(
                              (p) => _repository.getPokemonDetailsByUrl(p.url),
                            ),
                      );
                    },
                    itemLoadingIndicator: PokeballProgressIndicator(
                      size: 30,
                      color: widget.typeTheme.primary,
                    ),
                    loadingIndicator: PokeballProgressIndicator(
                      size: 30,
                      color: widget.typeTheme.primary,
                    ),
                    itemBuilder: (context, pokemon, index) {
                      return ListTile(
                        leading: CachedNetworkImage(
                          imageUrl: pokemon.sprites.frontDefault ?? '',
                          width: 40,
                          height: 40,
                          errorWidget:
                              (_, __, _) => const Icon(Icons.catching_pokemon),
                        ),
                        title: Text(pokemon.name.capitalize()),
                        subtitle: Text('ID: #${pokemon.id}'),
                        onTap: () {
                          Navigator.of(context).pop(pokemon);
                        },
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: theme.colorScheme.secondary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
