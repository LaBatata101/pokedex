import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/custom/progress_indicator.dart';
import 'package:pokedex/pokeapi/entities/items.dart';
import 'package:pokedex/pokeapi/entities/pokemon.dart';
import 'package:pokedex/utils/string.dart';
import 'package:pokedex/viewmodels/pokemon_details_viewmodel.dart';
import 'package:pokedex/views/pokemon_details.dart';

class HeldItemsWidget extends StatelessWidget {
  final List<PokemonHeldItem> heldItems;
  final PokemonDetailsViewModel viewModel;
  final PokemonTypeTheme typeTheme;

  const HeldItemsWidget(
    this.heldItems,
    this.viewModel,
    this.typeTheme, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // If no held items, don't show the section
    if (heldItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.shopping_bag_outlined, color: typeTheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Held Items',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: typeTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildHeldItemsList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeldItemsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          heldItems.map((heldItem) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item name
                  FutureBuilder<Item>(
                    future: viewModel.fetchPokemonItem(heldItem),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: PokeballProgressIndicator(),
                          ),
                        );
                      }

                      if (snapshot.hasData) {
                        final item = snapshot.data!;
                        return Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: typeTheme.secondary.withValues(
                                  alpha: 0.3,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: item.sprites.value ?? '',
                                width: 28,
                                height: 28,
                                errorWidget: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.broken_image,
                                    size: 20,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                heldItem.item.name
                                    .split('-')
                                    .map((word) => word.capitalize())
                                    .join(' '),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.info_outline,
                                color: typeTheme.primary,
                                size: 20,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: Text(
                                          heldItem.item.name
                                              .split('-')
                                              .map((word) => word.capitalize())
                                              .join(' '),
                                          style: TextStyle(
                                            color: typeTheme.primary,
                                          ),
                                        ),
                                        content: Text(
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
                                        ),
                                        actions: [
                                          TextButton(
                                            child: Text(
                                              'Close',
                                              style: TextStyle(
                                                color: typeTheme.primary,
                                              ),
                                            ),
                                            onPressed:
                                                () =>
                                                    Navigator.of(context).pop(),
                                          ),
                                        ],
                                      ),
                                );
                              },
                            ),
                          ],
                        );
                      }

                      return const Icon(Icons.inventory_2_outlined, size: 20);
                    },
                  ),

                  // Version Details
                  if (heldItem.versionDetails.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 46.0, top: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            heldItem.versionDetails.map((versionDetail) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: typeTheme.secondary.withValues(
                                          alpha: 0.5,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Pokémon ${versionDetail.version.name.capitalize()}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: typeTheme.primary,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${versionDetail.rarity}% chance',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),

                  // Divider between items
                  if (heldItem != heldItems.last)
                    Divider(color: typeTheme.secondary.withValues(alpha: 0.3)),
                ],
              ),
            );
          }).toList(),
    );
  }
}
