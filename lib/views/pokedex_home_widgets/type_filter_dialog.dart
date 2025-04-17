import 'package:flutter/material.dart';
import 'package:pokedex/custom/progress_indicator.dart';
import 'package:pokedex/pokeapi/entities/games.dart';
import 'package:pokedex/utils/logging.dart';
import 'package:pokedex/viewmodels/home_view_model.dart';
import 'package:pokedex/utils/string.dart';
import 'package:pokedex/views/pokemon_details.dart';
import 'package:pokedex/pokeapi/entities/pokemon.dart';
import 'package:provider/provider.dart';

class TypeFilterDialog extends StatefulWidget {
  final List<Type> initialSelectedTypes;
  final List<Generation> initialSelectedGenerations;

  const TypeFilterDialog({
    super.key,
    required this.initialSelectedTypes,
    required this.initialSelectedGenerations,
  });

  @override
  State<TypeFilterDialog> createState() => _TypeFilterDialogState();
}

class _TypeFilterDialogState extends State<TypeFilterDialog>
    with SingleTickerProviderStateMixin {
  List<Type> _selectedTypes = [];
  List<Generation> _selectedGenerations = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selectedTypes = widget.initialSelectedTypes;
    _selectedGenerations = widget.initialSelectedGenerations;

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final viewModel = context.read<HomeViewModel>();
        viewModel.loadPokemonTypes();
        viewModel.loadPokemonGenerations();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  PokemonTypeTheme _getTypeColor(String type) {
    return pokemonTypeThemes[type.toLowerCase()] ??
        pokemonTypeThemes['normal']!;
  }

  Widget _buildTypeChip(Type type) {
    final typeName = type.name;
    final isSelected = _selectedTypes.contains(type);
    final typeTheme = _getTypeColor(typeName);

    return FilterChip(
      selected: isSelected,
      backgroundColor: typeTheme.primary.withValues(alpha: 0.9),
      selectedColor: typeTheme.primary,
      checkmarkColor: Colors.white,
      label: Text(
        typeName.capitalize(),
        style: TextStyle(
          color: typeTheme.text,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onSelected: (selected) {
        setState(() {
          if (selected) {
            logger.i("selected type ${type.name}");
            _selectedTypes.add(type);
          } else {
            logger.i("unselected type ${type.name}");
            _selectedTypes.remove(type);
          }
        });
      },
    );
  }

  Widget _buildGenerationChip(Generation generation) {
    final displayName = _formatGenerationName(generation.name);
    final isSelected = _selectedGenerations.contains(generation);

    return FilterChip(
      selected: isSelected,
      backgroundColor: Colors.blueGrey.withValues(alpha: 0.2),
      selectedColor: Colors.blueGrey.withValues(alpha: 0.8),
      checkmarkColor: Colors.white,
      label: Text(
        displayName,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onSelected: (selected) {
        setState(() {
          if (selected) {
            logger.i("selected ${generation.name}");
            _selectedGenerations.add(generation);
          } else {
            logger.i("unselected ${generation.name}");
            _selectedGenerations.remove(generation);
          }
        });
      },
    );
  }

  String _formatGenerationName(String name) {
    final parts = name.split('-');
    if (parts.length == 2 && parts[0] == 'generation') {
      return 'Generation ${parts[1].toUpperCase()}';
    }
    return name.capitalize();
  }

  Widget _buildTypesTab(HomeViewModel viewModel) {
    return viewModel.isTypesLoading
        ? const Center(child: PokeballProgressIndicator())
        : viewModel.availableTypes.isEmpty
        ? const Center(child: Text('No types available'))
        : SingleChildScrollView(
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children:
                viewModel.availableTypes
                    .map((type) => _buildTypeChip(type))
                    .toList(),
          ),
        );
  }

  Widget _buildGenerationsTab(HomeViewModel viewModel) {
    return viewModel.isGenerationsLoading
        ? const Center(child: PokeballProgressIndicator())
        : viewModel.availableGenerations.isEmpty
        ? const Center(child: Text('No generations available'))
        : SingleChildScrollView(
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children:
                viewModel.availableGenerations
                    .map((gen) => _buildGenerationChip(gen))
                    .toList(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (_, viewModel, _) {
        return AlertDialog(
          title: const Text(
            'Filter Pokémon By',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.red,
                  unselectedLabelColor: Colors.black54,
                  indicatorColor: Colors.red,
                  tabs: const [Tab(text: 'Type'), Tab(text: 'Generation')],
                ),

                // Selected count indicators
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    children: [
                      if (_selectedTypes.isNotEmpty)
                        Chip(
                          backgroundColor: Colors.red.withValues(alpha: 0.2),
                          label: Text(
                            '${_selectedTypes.length} Type${_selectedTypes.length > 1 ? "s" : ""} Selected',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (_selectedGenerations.isNotEmpty)
                        Chip(
                          backgroundColor: Colors.blueGrey.withValues(
                            alpha: 0.2,
                          ),
                          label: Text(
                            '${_selectedGenerations.length} Generation${_selectedGenerations.length > 1 ? "s" : ""} Selected',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_selectedTypes.isNotEmpty ||
                    _selectedGenerations.isNotEmpty)
                  const Divider(),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTypesTab(viewModel),
                      _buildGenerationsTab(viewModel),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  if (_tabController.index == 0) {
                    _selectedTypes.clear();
                  } else {
                    _selectedGenerations.clear();
                  }
                });
              },
              child: Text(
                'Clear ${_tabController.index == 0 ? "Types" : "Generations"}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedTypes.clear();
                  _selectedGenerations.clear();
                });
              },
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                viewModel.applyFilters(_selectedTypes, _selectedGenerations);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}
