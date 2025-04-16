import 'package:flutter/material.dart';
import 'package:pokedex/custom/progress_indicator.dart';
import 'package:pokedex/pokeapi/entities/pokemon.dart';
import 'package:pokedex/utils/string.dart';
import 'package:pokedex/viewmodels/pokemon_details_viewmodel.dart';
import 'package:pokedex/views/pokemon_details.dart';

class BasicInfoWidget extends StatelessWidget {
  final Pokemon pokemon;
  final PokemonDetailsViewModel viewModel;
  final PokemonTypeTheme typeTheme;
  const BasicInfoWidget(
    this.pokemon,
    this.viewModel,
    this.typeTheme, {
    super.key,
  });

  Widget pokemonDescription() {
    return _InfoRow(
      icon: Icons.description,
      label: 'Description',
      value:
          viewModel.isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PokeballProgressIndicator(color: typeTheme.primary),
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

    final primaryColor = Theme.of(context).colorScheme.primary;

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

            _InfoRow(
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

            _InfoRow(
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

            _InfoRow(
              icon: Icons.star,
              label: 'Base Experience',
              value: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${pokemon.baseExperience} XP',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            viewModel.isLoading
                ? SizedBox.shrink()
                : _InfoRow(
                  icon: Icons.mood,
                  label: 'Base Happiness',
                  value: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value:
                                viewModel.baseHappiness != null
                                    ? viewModel.baseHappiness! / 255
                                    : 0.0,
                            backgroundColor: Colors.grey[200],
                            color:
                                viewModel.baseHappiness != null
                                    ? _getHappinessColor(
                                      viewModel.baseHappiness!,
                                    )
                                    : primaryColor,
                            minHeight: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${viewModel.baseHappiness ?? "N/A"}/255',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
            const SizedBox(height: 12),

            viewModel.isLoading
                ? SizedBox.shrink()
                : _InfoRow(
                  icon: Icons.catching_pokemon,
                  label: 'Capture Rate',
                  value: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value:
                                viewModel.captureRate != null
                                    ? viewModel.captureRate! / 255
                                    : 0.0,
                            backgroundColor: Colors.grey[200],
                            color: primaryColor,
                            minHeight: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${viewModel.captureRate ?? "N/A"}/255',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
            const SizedBox(height: 12),

            viewModel.isLoading
                ? SizedBox.shrink()
                : _InfoRow(
                  icon: Icons.trending_up,
                  label: 'Growth Rate',
                  value: Text(
                    viewModel.growthRate?.name.capitalize().replaceAll(
                          '-',
                          ' ',
                        ) ??
                        'N/A',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
            const SizedBox(height: 12),

            viewModel.isLoading
                ? SizedBox.shrink()
                : _InfoRow(
                  icon: Icons.terrain,
                  label: 'Habitat',
                  value:
                      viewModel.habitat != null
                          ? Text(
                            viewModel.habitat!.name.capitalize(),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          )
                          : Text(
                            'Unknown',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                          ),
                ),
            const SizedBox(height: 12),

            viewModel.isLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PokeballProgressIndicator(color: typeTheme.primary),
                      SizedBox(height: 16),
                      Text('Loading Pokémon generation...'),
                    ],
                  ),
                )
                : _InfoRow(
                  icon: Icons.timeline,
                  label: "Generation",
                  value: Text(
                    viewModel.pokemonGeneration,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
            const SizedBox(height: 12),

            _InfoRow(
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

Color _getHappinessColor(int happiness) {
  if (happiness < 70) {
    return Colors.red;
  } else if (happiness < 140) {
    return Colors.orange;
  } else if (happiness < 200) {
    return Colors.lime;
  } else {
    return Colors.green;
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget value;

  const _InfoRow({
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
