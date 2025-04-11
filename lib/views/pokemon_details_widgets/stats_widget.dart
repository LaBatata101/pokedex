import 'package:flutter/material.dart';
import 'package:pokedex/pokeapi/entities/pokemon.dart';
import 'package:pokedex/utils/string.dart';

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
