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

// Icons for different learning methods
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

class MovesWidget extends StatelessWidget {
  final List<PokemonMove> moves;
  final PokemonDetailsViewModel viewModel;

  const MovesWidget(this.moves, this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (moves.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
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

            if (moves.isNotEmpty)
              AllMovesExpansionTile(
                moves: moves,
                theme: theme,
                viewModel: viewModel,
              ),
          ],
        ),
      ),
    );
  }
}

class AllMovesExpansionTile extends StatefulWidget {
  final List<PokemonMove> moves;
  final ThemeData theme;
  final PokemonDetailsViewModel viewModel;

  const AllMovesExpansionTile({
    super.key,
    required this.moves,
    required this.theme,
    required this.viewModel,
  });

  @override
  State<StatefulWidget> createState() => _AllMovesExpansionTileState();
}

class _AllMovesExpansionTileState extends State<AllMovesExpansionTile> {
  final ScrollController _scrollController = ScrollController();
  final List<Move> _movesToBeDisplayed = [];
  final int _pageSize = 15;
  bool _isLoading = false;
  bool _initialLoad = false;
  int _currentPage = 1;
  int _displayCount = 0;
  String? _errorMsg;
  String _sortBy = 'name'; // Default sort
  String _filterBy = 'all'; // Default filter

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

  // Get sorted and filtered moves
  List<PokemonMove> _getFilteredMoves() {
    List<PokemonMove> filteredMoves = List.from(widget.moves);

    // Apply filter
    if (_filterBy != 'all') {
      filteredMoves =
          filteredMoves
              .where(
                (move) => move.versionGroupDetails.any(
                  (detail) => detail.moveLearnMethod.name == _filterBy,
                ),
              )
              .toList();
    }

    // Apply sort
    switch (_sortBy) {
      case 'name':
        filteredMoves.sort((a, b) => a.move.name.compareTo(b.move.name));
        break;
      case 'level':
        filteredMoves.sort((a, b) {
          final aLevel =
              a.versionGroupDetails
                  .where((d) => d.moveLearnMethod.name == 'level-up')
                  .map((d) => d.levelLearnedAt)
                  .firstOrNull ??
              100;
          final bLevel =
              b.versionGroupDetails
                  .where((d) => d.moveLearnMethod.name == 'level-up')
                  .map((d) => d.levelLearnedAt)
                  .firstOrNull ??
              100;
          return aLevel.compareTo(bLevel);
        });
        break;
    }

    return filteredMoves;
  }

  Future<void> _fetchMovesData() async {
    if (_isLoading) return;

    final filteredMoves = _getFilteredMoves();
    final currentItemCount = _movesToBeDisplayed.length;

    logger.i(
      "Loading more items (Page ${_currentPage + 1})..."
      " Current count: $currentItemCount, Total available: ${filteredMoves.length}",
    );

    final nextPage = filteredMoves.skip(currentItemCount).take(_pageSize);
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

  void _resetAndReload() {
    setState(() {
      _movesToBeDisplayed.clear();
      _currentPage = 1;
      _displayCount = 0;
      _initialLoad = false;
      _errorMsg = null;
    });
    _fetchMovesData().whenComplete(() {
      setState(() {
        _initialLoad = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.theme.colorScheme.primary;

    return Column(
      children: [
        ListExpansionTile(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.flash_on, color: primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Moves',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
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
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          maxListHeight: 350,
          scrollController: _scrollController,
          physics: const BouncingScrollPhysics(),
          childCount: _displayCount + (_isLoading ? 1 : 0),
          onExpansionChanged: (isExpanded) {
            if (isExpanded && !_initialLoad) {
              _fetchMovesData().whenComplete(() {
                setState(() {
                  _initialLoad = true;
                });
              });
            }
          },
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filter button
              IconButton(
                icon: Icon(Icons.filter_list, color: primaryColor),
                onPressed: () {
                  _showFilterDialog(context);
                },
              ),
              // Sort button
              IconButton(
                icon: Icon(Icons.sort, color: primaryColor),
                onPressed: () {
                  _showSortDialog(context);
                },
              ),
            ],
          ),
          builder: (context, index) {
            if (_errorMsg != null) {
              return Center(
                child: Text(
                  _errorMsg!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            if (index == 0) {
              return Column(
                children: [
                  // Header for moves list
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Move',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          width: 70,
                          child: Text(
                            'Type',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 10),
                        SizedBox(
                          width: 70,
                          child: Text(
                            'Class',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (_movesToBeDisplayed.isNotEmpty)
                    MoveListItem(
                      move: _movesToBeDisplayed[0],
                      versionGroupDetails:
                          _getFilteredMoves()[0].versionGroupDetails,
                      theme: widget.theme,
                    ),
                ],
              );
            }

            if (_isLoading && index >= _movesToBeDisplayed.length) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PokeballProgressIndicator(size: 35),
                ),
              );
            }

            return MoveListItem(
              move: _movesToBeDisplayed[index],
              versionGroupDetails:
                  _getFilteredMoves()[index].versionGroupDetails,
              theme: widget.theme,
            );
          },
        ),
      ],
    );
  }

  void _showSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sort Moves By'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.sort_by_alpha,
                    color:
                        _sortBy == 'name'
                            ? widget.theme.colorScheme.primary
                            : null,
                  ),
                  title: const Text('Name (A-Z)'),
                  selected: _sortBy == 'name',
                  onTap: () {
                    setState(() {
                      _sortBy = 'name';
                    });
                    Navigator.pop(context);
                    _resetAndReload();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.arrow_upward,
                    color:
                        _sortBy == 'level'
                            ? widget.theme.colorScheme.primary
                            : null,
                  ),
                  title: const Text('Level (Low to High)'),
                  selected: _sortBy == 'level',
                  onTap: () {
                    setState(() {
                      _sortBy = 'level';
                    });
                    Navigator.pop(context);
                    _resetAndReload();
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final methods = [
      {'id': 'all', 'name': 'All Methods', 'icon': Icons.all_inclusive},
      {'id': 'level-up', 'name': 'Level Up', 'icon': Icons.arrow_upward},
      {'id': 'machine', 'name': 'TM/HM', 'icon': Icons.settings},
      {'id': 'egg', 'name': 'Egg Moves', 'icon': Icons.egg_alt},
      {'id': 'tutor', 'name': 'Move Tutor', 'icon': Icons.school},
    ];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filter by Learning Method'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children:
                    methods.map((method) {
                      return ListTile(
                        leading: Icon(
                          method['icon'] as IconData,
                          color:
                              _filterBy == method['id']
                                  ? widget.theme.colorScheme.primary
                                  : null,
                        ),
                        title: Text(method['name'] as String),
                        selected: _filterBy == method['id'],
                        onTap: () {
                          setState(() {
                            _filterBy = method['id'] as String;
                          });
                          Navigator.pop(context);
                          _resetAndReload();
                        },
                      );
                    }).toList(),
              ),
            ),
          ),
    );
  }
}

class MoveListItem extends StatelessWidget {
  final Move move;
  final List<PokemonMoveVersion> versionGroupDetails;
  final ThemeData theme;

  const MoveListItem({
    super.key,
    required this.move,
    required this.versionGroupDetails,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // Get move type theme
    final typeTheme =
        pokemonTypeThemes[move.type.name] ?? pokemonTypeThemes['normal']!;
    final damageClassTheme =
        pokemonMoveDamageTheme[move.damageClass.name] ??
        pokemonTypeThemes['normal']!;

    return InkWell(
      onTap: () => _showMoveDetails(context, move),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            // Move name and learning methods indicators
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    move.name.split('-').map((w) => w.capitalize()).join(' '),
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Row(children: _getLearnMethodIndicators()),
                ],
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

            const SizedBox(width: 10),

            // Damage class badge
            SizedBox(
              width: 75,
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

  // Generate small icons showing how this move can be learned
  List<Widget> _getLearnMethodIndicators() {
    final Set<String> methods = {};
    for (var detail in versionGroupDetails) {
      methods.add(detail.moveLearnMethod.name);
    }

    return methods.map((method) {
      final IconData icon = methodIcons[method] ?? Icons.help_outline;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Tooltip(
          message: method.split('-').map((w) => w.capitalize()).join(' '),
          child: Icon(icon, size: 16, color: Colors.grey[600]),
        ),
      );
    }).toList();
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

    // Organize version groups by learn method to avoid duplicates
    final Map<String, Map<String, List<PokemonMoveVersion>>> organizedDetails =
        {};

    for (var detail in versionGroupDetails) {
      final method = detail.moveLearnMethod.name;
      final versionGroup = detail.versionGroup.name;

      organizedDetails.putIfAbsent(method, () => {});
      organizedDetails[method]!.putIfAbsent(versionGroup, () => []);
      organizedDetails[method]![versionGroup]!.add(detail);
    }

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
                        move.name
                            .split('-')
                            .map((w) => w.capitalize())
                            .join(' '),
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
                                color: typeTheme.text,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

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
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              description,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Stats row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatCard(
                                'Power',
                                move.power?.toString() ?? '—',
                                Icons.flash_on,
                                typeTheme.primary,
                              ),
                              _buildStatCard(
                                'Accuracy',
                                move.accuracy == null
                                    ? '—'
                                    : '${move.accuracy!}%',
                                Icons.gps_fixed,
                                typeTheme.primary,
                              ),
                              _buildStatCard(
                                'PP',
                                move.pp?.toString() ?? '—',
                                Icons.tag,
                                typeTheme.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // How to learn section
                          Text(
                            'How to Learn',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: typeTheme.primary,
                            ),
                          ),
                          const SizedBox(height: 12),

                          ...organizedDetails.entries.map((entry) {
                            final method = entry.key;
                            final versions = entry.value;
                            final methodName = method
                                .split('-')
                                .map((w) => w.capitalize())
                                .join(' ');
                            final icon =
                                methodIcons[method] ?? Icons.help_outline;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ExpansionTile(
                                title: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: typeTheme.primary.withValues(
                                          alpha: 0.2,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        icon,
                                        color: typeTheme.primary,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      methodName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: typeTheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                children:
                                    versions.entries.map((versionEntry) {
                                      final versionGroup = versionEntry.key
                                          .split('-')
                                          .map((w) => w.capitalize())
                                          .join(' ');
                                      final details = versionEntry.value;

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            const SizedBox(width: 32),
                                            if (method == 'level-up')
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: typeTheme.primary
                                                      .withValues(alpha: 0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'Lv${details.first.levelLearnedAt}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: typeTheme.primary,
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Pokémon $versionGroup',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
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

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
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
          Icon(icon, color: color),
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
