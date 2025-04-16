import 'package:flutter/material.dart';
import 'package:pokedex/custom/progress_indicator.dart';
import 'package:pokedex/utils/string.dart';
import 'package:pokedex/viewmodels/pokemon_details_viewmodel.dart';
import 'package:pokedex/views/pokemon_details.dart';

class TypeEffectivenessWidget extends StatefulWidget {
  final PokemonDetailsViewModel viewModel;
  final PokemonTypeTheme typeTheme;

  const TypeEffectivenessWidget(this.viewModel, this.typeTheme, {super.key});

  @override
  State<TypeEffectivenessWidget> createState() =>
      _TypeEffectivenessWidgetState();
}

class _TypeEffectivenessWidgetState extends State<TypeEffectivenessWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

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
                Icon(Icons.security, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Type Effectiveness',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Tab bar for switching between defense and offense
            Container(
              decoration: BoxDecoration(
                color: secondaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: secondaryColor.withValues(alpha: 0.3),
                ),
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield),
                        SizedBox(width: 8),
                        Text('Defense'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.flash_on),
                        SizedBox(width: 8),
                        Text('Offense'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tab content
            widget.viewModel.isLoadingTypeEffectiveness
                ? _buildLoadingIndicator()
                : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    key: ValueKey<int>(_tabController.index),
                    child:
                        _tabController.index == 0
                            ? _buildDefenseTab(context)
                            : _buildOffenseTab(context),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PokeballProgressIndicator(color: widget.typeTheme.primary),
          const SizedBox(height: 16),
          const Text('Loading type effectiveness data...'),
        ],
      ),
    );
  }

  Widget _buildDefenseTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEffectivenessSection(
          context,
          'Weak Against (4× damage)',
          widget.viewModel.quadrupleDamageFrom,
          4.0,
        ),
        _buildEffectivenessSection(
          context,
          'Weak Against (2× damage)',
          widget.viewModel.doubleDamageFrom,
          2.0,
        ),
        _buildEffectivenessSection(
          context,
          'Resistant To (½× damage)',
          widget.viewModel.halfDamageFrom,
          0.5,
        ),
        _buildEffectivenessSection(
          context,
          'Resistant To (¼× damage)',
          widget.viewModel.quarterDamageFrom,
          0.25,
        ),
        _buildEffectivenessSection(
          context,
          'Immune To (0× damage)',
          widget.viewModel.noDamageFrom,
          0.0,
        ),
      ],
    );
  }

  Widget _buildOffenseTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEffectivenessSection(
          context,
          'Super Effective Against (2× damage)',
          widget.viewModel.doubleDamageTo,
          2.0,
          isOffensive: true,
        ),
        _buildEffectivenessSection(
          context,
          'Not Very Effective Against (½× damage)',
          widget.viewModel.halfDamageTo,
          0.5,
          isOffensive: true,
        ),
        _buildEffectivenessSection(
          context,
          'No Effect Against (0× damage)',
          widget.viewModel.noDamageTo,
          0.0,
          isOffensive: true,
        ),
      ],
    );
  }

  Widget _buildEffectivenessSection(
    BuildContext context,
    String title,
    List<String> types,
    double damageMultiplier, {
    bool isOffensive = false,
  }) {
    if (types.isEmpty) {
      return const SizedBox.shrink();
    }

    Color textColor;
    if (isOffensive) {
      // For offensive, high multipliers are good (green), low are bad (red)
      textColor =
          damageMultiplier > 1
              ? Colors.green.shade700
              : (damageMultiplier == 0
                  ? Colors.red.shade700
                  : Colors.orange.shade700);
    } else {
      // For defensive, high multipliers are bad (red), low are good (green)
      textColor =
          damageMultiplier > 1
              ? Colors.red.shade700
              : (damageMultiplier == 0 ? Colors.indigo : Colors.green.shade700);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                _getIconForMultiplier(damageMultiplier, isOffensive),
                color: textColor,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children:
                types.map((type) => _buildTypeChip(context, type)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(BuildContext context, String typeName) {
    final typeTheme =
        pokemonTypeThemes[typeName] ?? pokemonTypeThemes['normal']!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: typeTheme.primary,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: typeTheme.primary.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        typeName.capitalize(),
        style: TextStyle(
          color: typeTheme.text,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  IconData _getIconForMultiplier(double multiplier, bool isOffensive) {
    if (isOffensive) {
      // Offensive icons
      if (multiplier > 1) {
        return Icons.flash_on; // Super effective
      } else if (multiplier == 0) {
        return Icons.block; // No effect
      } else {
        return Icons.remove_circle_outline; // Not very effective
      }
    } else {
      // Defensive icons
      if (multiplier > 1) {
        return Icons.dangerous_rounded; // Weak against
      } else if (multiplier == 0) {
        return Icons.shield; // Immune to
      } else {
        return Icons.security; // Resistant to
      }
    }
  }
}
