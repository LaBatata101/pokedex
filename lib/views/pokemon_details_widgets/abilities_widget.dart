import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/custom/paginated_list_view.dart';
import 'package:pokedex/custom/progress_indicator.dart';
import 'package:pokedex/pokeapi/entities/pokemon.dart';
import 'package:pokedex/utils/logging.dart';
import 'package:pokedex/utils/string.dart';
import 'package:pokedex/viewmodels/pokemon_details_viewmodel.dart';
import 'package:pokedex/views/pokemon_details.dart';

class AbilitiesWidget extends StatelessWidget {
  final List<PokemonAbility> abilities;
  final PokemonDetailsViewModel viewModel;
  final PokemonTypeTheme typeTheme;

  const AbilitiesWidget(
    this.abilities,
    this.viewModel,
    this.typeTheme, {
    super.key,
  });

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

                    IconButton(
                      icon: Icon(Icons.info_outline, color: Colors.grey[400]),
                      onPressed: () {
                        _showAbilityDetails(context, ability);
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

  void _showAbilityDetails(
    BuildContext context,
    PokemonAbility pokemonAbility,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderSection(pokemonAbility),
                _buildContentSection(pokemonAbility),
              ],
            ),
          ),
    );
  }

  Widget _buildContentSection(PokemonAbility pokemonAbility) {
    return Expanded(
      child: FutureBuilder(
        future: viewModel.fetchAbility(pokemonAbility),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final ability = snapshot.data!;
            final String randomDescriptionEn =
                (ability.flavorTextEntries
                        .where((flavor) => flavor.language.name == 'en')
                        .toList()
                      ..shuffle())
                    .first
                    .flavorText
                    .sanitize();

            // Get effect in English
            final englishEffects =
                ability.effectEntries
                    .where((effect) => effect.language.name == 'en')
                    .toList();
            final String effect =
                englishEffects.isNotEmpty
                    ? englishEffects.first.effect
                    : 'No effect description available.';

            final pageSize = 6;
            final generationParts = ability.generation.name.split('-');
            final generationStr =
                '${generationParts[0].capitalize()} ${generationParts[1].toUpperCase()}';
            logger.d(generationStr);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description section
                  _buildSectionTitle(
                    context,
                    'Description',
                    Icons.description_outlined,
                  ),
                  Card(
                    elevation: 0,
                    color: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        randomDescriptionEn,
                        style: const TextStyle(fontSize: 16, height: 1.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Effect section
                  _buildSectionTitle(
                    context,
                    'Effect',
                    Icons.auto_awesome_outlined,
                  ),
                  Card(
                    elevation: 0,
                    color: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        effect,
                        style: const TextStyle(fontSize: 16, height: 1.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Generation info
                  _buildSectionTitle(context, 'Details', Icons.info_outline),
                  Card(
                    elevation: 0,
                    color: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            'Generation',
                            generationStr,
                            Icons.timeline,
                            typeTheme.primary,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Main Series',
                            ability.isMainSeries ? 'Yes' : 'No',
                            Icons.videogame_asset,
                            typeTheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Pokémon with this ability
                  if (ability.pokemon.isNotEmpty) ...[
                    _buildSectionTitle(
                      context,
                      'Related Pokémon',
                      Icons.catching_pokemon,
                    ),
                    SizedBox(
                      height: 130,
                      child: PaginatedListView(
                        itemsPerPage: pageSize,
                        scrollDirection: Axis.horizontal,
                        fetchPage: (_, currentItemsCount) {
                          return viewModel.fetchPokemonsWithAbility(
                            ability.pokemon
                                .skip(currentItemsCount)
                                .take(pageSize),
                          );
                        },
                        itemLoadingIndicator: PokeballProgressIndicator(
                          size: 30,
                          color: typeTheme.primary,
                        ),
                        loadingIndicator: const PokeballProgressIndicator(
                          size: 30,
                        ),
                        itemBuilder: (context, pokemon, index) {
                          return Card(
                            margin: const EdgeInsets.only(right: 12, bottom: 4),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                // Navigate to this pokemon's page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => PokemonDetails(pokemon),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: typeTheme.secondary.withValues(
                                          alpha: 0.3,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            pokemon.sprites.frontDefault ?? '',
                                        progressIndicatorBuilder: (_, _, _) {
                                          return PokeballProgressIndicator(
                                            size: 24,
                                          );
                                        },
                                        errorWidget:
                                            (_, _, _) => const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                size: 36,
                                                color: Colors.red,
                                              ),
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      pokemon.name.capitalize(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            );
          } else if (snapshot.hasError) {
            logger.e(
              "Error fetching ability information!",
              error: snapshot.error,
              stackTrace: snapshot.stackTrace,
            );
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Couldn't load ability details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: PokeballProgressIndicator(color: typeTheme.primary),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(PokemonAbility pokemonAbility) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: typeTheme.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Pull indicator
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  pokemonAbility.isHidden
                      ? Icons.visibility_off
                      : Icons.flash_on,
                  color: typeTheme.text,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pokemonAbility.ability.name.capitalize(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: typeTheme.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: typeTheme.text.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        pokemonAbility.isHidden
                            ? 'Hidden Ability'
                            : 'Normal Ability',
                        style: TextStyle(
                          fontSize: 12,
                          color: typeTheme.text,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: typeTheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: typeTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}
