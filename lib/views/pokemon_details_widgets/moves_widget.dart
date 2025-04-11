import 'package:flutter/material.dart';
import 'package:pokedex/custom/expansion_tile.dart';
import 'package:pokedex/custom/progress_indicator.dart';
import 'package:pokedex/pokeapi/entities/moves.dart';
import 'package:pokedex/pokeapi/entities/pokemon.dart';
import 'package:pokedex/utils/logging.dart';
import 'package:pokedex/utils/string.dart';
import 'package:pokedex/viewmodels/pokemon_details_viewmodel.dart';
import 'package:pokedex/views/pokemon_details.dart';

final pokemonMoveDamageTheme = {
  'physical': PokemonTypeTheme(
    primary: Color(0xFFE74C3C),
    secondary: Color(0xFFF1948A),
    text: Colors.white,
  ),
  'special': PokemonTypeTheme(
    primary: Color(0xFFF39C12),
    secondary: Color(0xFFFAD7A0),
    text: Colors.black,
  ),
  'status': PokemonTypeTheme(
    primary: Color(0xFF9B59B6),
    secondary: Color(0xFFD2B4DE),
    text: Colors.white,
  ),
};

class MovesWidget extends StatelessWidget {
  final List<PokemonMove> moves;
  final PokemonDetailsViewModel viewModel;

  const MovesWidget(this.moves, this.viewModel, {super.key});

  // Organize moves by their learning method
  Map<String, List<PokemonMove>> _organizeMovesByMethod() {
    final Map<String, List<PokemonMove>> movesByMethod = {};

    for (final move in moves) {
      for (final detail in move.versionGroupDetails) {
        final method = detail.moveLearnMethod.name;
        if (movesByMethod[method] != null &&
            movesByMethod[method]!.any((m) => m.move.name == move.move.name)) {
          continue;
        }
        movesByMethod.putIfAbsent(method, () => []).add(move);
      }
    }

    // Sort moves within each category by level (for level-up moves)
    for (final method in movesByMethod.keys) {
      if (method == 'level-up') {
        movesByMethod[method]!.sort((a, b) {
          final aLevel =
              a.versionGroupDetails
                  .firstWhere((d) => d.moveLearnMethod.name == method)
                  .levelLearnedAt;
          final bLevel =
              b.versionGroupDetails
                  .firstWhere((d) => d.moveLearnMethod.name == method)
                  .levelLearnedAt;
          return aLevel.compareTo(bLevel);
        });
      } else {
        // For other methods, sort alphabetically
        movesByMethod[method]!.sort(
          (a, b) => a.move.name.compareTo(b.move.name),
        );
      }
    }

    return movesByMethod;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final movesByMethod = _organizeMovesByMethod();

    // Show appropriate icon for each learning method
    final methodIcons = {
      'level-up': Icons.arrow_upward,
      'machine': Icons.settings,
      'egg': Icons.egg_alt,
      'tutor': Icons.school,
      'stadium-surfing-pikachu': Icons.surfing,
      'light-ball-egg': Icons.egg,
      'colosseum-purification': Icons.auto_fix_high,
      'xd-shadow': Icons.dark_mode,
      'xd-purification': Icons.light_mode,
      'form-change': Icons.transform,
      'zygarde-cube': Icons.change_history,
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon
            Row(
              children: [
                Icon(Icons.flash_on, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Moves',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${moves.length} total',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            if (moves.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.not_interested,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No moves information available',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Move categories as expansion tiles
            ...movesByMethod.keys.map((method) {
              final methodMoves = movesByMethod[method]!;
              final methodIcon = methodIcons[method] ?? Icons.gesture;

              return MoveMethodExpansionTile(
                method: method,
                moves: methodMoves,
                icon: methodIcon,
                theme: theme,
                viewModel: viewModel,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class MoveMethodExpansionTile extends StatefulWidget {
  final String method;
  final List<PokemonMove> moves;
  final IconData icon;
  final ThemeData theme;
  final PokemonDetailsViewModel viewModel;

  const MoveMethodExpansionTile({
    super.key,
    required this.method,
    required this.moves,
    required this.icon,
    required this.theme,
    required this.viewModel,
  });

  @override
  State<StatefulWidget> createState() => _MoveMethodExpansionTileState();
}

class _MoveMethodExpansionTileState extends State<MoveMethodExpansionTile> {
  final ScrollController _scrollController = ScrollController();
  final List<Move> _movesToBeDisplayed = [];
  final int _pageSize = 10;
  bool _isLoading = false;
  bool _initialLoad = false;
  int _currentPage = 1;
  int _displayCount = 0;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        _fetchMovesData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchMovesData() async {
    if (_isLoading) return;

    final currentItemCount = _movesToBeDisplayed.length;

    logger.i(
      "Loading more items (Page ${_currentPage + 1})..."
      " Current count: $currentItemCount, Total available: ${widget.moves.length}",
    );

    final nextPage = widget.moves.skip(currentItemCount).take(_pageSize);
    if (nextPage.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      widget.viewModel
          .fetchMovesDetails(nextPage)
          .then(
            (moves) {
              setState(() {
                _movesToBeDisplayed.addAll(moves);
                _displayCount = _movesToBeDisplayed.length;
                _isLoading = false;
                _currentPage++;
              });
            },
            onError: (error, stackTrace) {
              setState(() {
                // Need to set the display count to 1, otherwise the error message
                // won't be shown in the `ListExpansionTile`.
                _displayCount = 1;
                _errorMsg = "Error loading pokémon moves data!";
              });
              logger.e(
                "Error loading pokémon moves data",
                error: error,
                stackTrace: stackTrace,
              );
            },
          );
    }
  }

  String getFormattedMethodName() {
    switch (widget.method) {
      case 'level-up':
        return 'Level Up';
      case 'machine':
        return 'TM/HM';
      default:
        return widget.method
            .split('-')
            .map((word) => word.capitalize())
            .join(' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.theme.colorScheme.primary;
    final methodName = getFormattedMethodName();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      color: primaryColor.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: primaryColor.withValues(alpha: 0.1)),
      ),
      child: ListExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, color: primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              methodName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.moves.length}',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        maxListHeight: 200,
        scrollController: _scrollController,
        physics: ClampingScrollPhysics(),
        childCount: _displayCount,
        onExpansionChanged: (isExpanded) {
          if (isExpanded && !_initialLoad) {
            _fetchMovesData().whenComplete(() {
              setState(() {
                _initialLoad = true;
              });
            });
          }
        },
        builder: (context, index) {
          if (_errorMsg != null) {
            return Center(
              child: Text(
                _errorMsg!,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          if (widget.method == 'level-up' && index == 0) {
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 20, bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          'Lvl',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Move',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: 105,
                        child: Text(
                          'Type',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                MoveListItem(
                  move: _movesToBeDisplayed[index],
                  versionGroupDetails: widget.moves[index].versionGroupDetails,
                  method: widget.method,
                  theme: widget.theme,
                ),
              ],
            );
          }

          if (_isLoading) {
            return PokeballProgressIndicator(size: 35);
          }

          return MoveListItem(
            move: _movesToBeDisplayed[index],
            versionGroupDetails: widget.moves[index].versionGroupDetails,
            method: widget.method,
            theme: widget.theme,
          );
        },
      ),
    );
  }
}

class MoveListItem extends StatelessWidget {
  final Move move;
  final List<PokemonMoveVersion> versionGroupDetails;
  final String method;
  final ThemeData theme;

  const MoveListItem({
    super.key,
    required this.move,
    required this.versionGroupDetails,
    required this.method,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = theme.colorScheme.primary;

    // Get move type (assuming we have access to this info)
    final typeTheme =
        pokemonTypeThemes[move.type.name] ?? pokemonTypeThemes['normal']!;
    final damageClassTheme =
        pokemonMoveDamageTheme[move.damageClass.name] ??
        pokemonTypeThemes['normal']!;

    // For level-up moves, get the level
    int? levelLearned;
    if (method == 'level-up') {
      levelLearned =
          versionGroupDetails
              .firstWhere((d) => d.moveLearnMethod.name == method)
              .levelLearnedAt;
    }

    return InkWell(
      onTap: () => _showMoveDetails(context, move),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            // Level indicator for level-up moves
            if (method == 'level-up')
              SizedBox(
                width: 40,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    levelLearned.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),

            // Move name
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: method == 'level-up' ? 8.0 : 0),
                child: Text(
                  move.name.split('-').map((w) => w.capitalize()).join(' '),
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),

            // Move type badge
            SizedBox(
              width: 70,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: typeTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  move.type.name.capitalize(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: typeTheme.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            SizedBox(width: 10),

            // Damage class badge
            SizedBox(
              width: 70,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: damageClassTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  move.damageClass.name.capitalize(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: damageClassTheme.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoveDetails(BuildContext context, Move move) {
    final typeTheme =
        pokemonTypeThemes[move.type.name] ?? pokemonTypeThemes['normal']!;
    final damageClassTheme =
        pokemonMoveDamageTheme[move.damageClass.name] ??
        pokemonTypeThemes['normal']!;

    final String description =
        (move.flavorTextEntries
                .where((flavor) => flavor.language.name == 'en')
                .toList()
              ..shuffle())
            .first
            .flavorText
            .sanitize();

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
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
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
                      Text(
                        move.name.capitalize(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: typeTheme.text,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Move type badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              move.type.name.capitalize(),
                              style: TextStyle(
                                color: damageClassTheme.text,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          SizedBox(width: 10),

                          // Damage class badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: damageClassTheme.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              move.damageClass.name.capitalize(),
                              style: TextStyle(
                                color: damageClassTheme.text,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Move details
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: typeTheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                          const SizedBox(height: 24),

                          // Stats row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatCard(
                                'Power',
                                move.power?.toString() ?? 'N/A',
                                Icons.flash_on,
                              ),
                              _buildStatCard(
                                'Accuracy',
                                move.accuracy == null
                                    ? 'N/A'
                                    : '${move.accuracy!}%',
                                Icons.gps_fixed,
                              ),
                              _buildStatCard(
                                'PP',
                                move.pp?.toString() ?? 'N/A',
                                Icons.tag,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // How to learn
                          Text(
                            'How to Learn',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: typeTheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...versionGroupDetails.map((detail) {
                            final methodName = detail.moveLearnMethod.name
                                .split('-')
                                .map((w) => w.capitalize())
                                .join(' ');

                            String learnDetails;
                            if (detail.moveLearnMethod.name == 'level-up') {
                              learnDetails =
                                  'At level ${detail.levelLearnedAt}';
                            } else if (detail.moveLearnMethod.name ==
                                'machine') {
                              learnDetails =
                                  'Via TM/HM | ${detail.versionGroup.name.split('-').map((w) => w.capitalize()).join(' ')}';
                            } else {
                              learnDetails = detail.versionGroup.name
                                  .split('-')
                                  .map((w) => w.capitalize())
                                  .join(' ');
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    detail.moveLearnMethod.name == 'level-up'
                                        ? Icons.arrow_upward
                                        : detail.moveLearnMethod.name ==
                                            'machine'
                                        ? Icons.settings
                                        : Icons.school,
                                    color: typeTheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '$methodName: $learnDetails',
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),

                // Close button
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: typeTheme.primary,
                        foregroundColor: typeTheme.text,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
