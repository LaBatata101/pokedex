import 'package:flutter/material.dart';
import 'package:pokedex/viewmodels/home_view_model.dart';
import 'package:pokedex/utils/string.dart';
import 'package:pokedex/views/pokemon_details.dart';
import 'package:pokedex/pokeapi/entities/pokemon.dart';
import 'package:provider/provider.dart';

class TypeFilterDialog extends StatefulWidget {
  const TypeFilterDialog({super.key});

  @override
  State<TypeFilterDialog> createState() => _TypeFilterDialogState();
}

class _TypeFilterDialogState extends State<TypeFilterDialog> {
  final List<Type> _selectedTypes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HomeViewModel>().loadPokemonTypes();
      }
    });
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
            _selectedTypes.add(type);
          } else {
            _selectedTypes.remove(type);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (_, viewModel, _) {
        return AlertDialog(
          title: const Text(
            'Filter by Type',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child:
                viewModel.isTypesLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: Colors.red),
                    )
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
                    ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedTypes.clear();
                });
              },
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                viewModel.setSelectedTypes(_selectedTypes);
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
