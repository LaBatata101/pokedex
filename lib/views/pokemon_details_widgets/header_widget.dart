import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/custom/progress_indicator.dart';
import 'package:pokedex/custom/sparkling_widget.dart';
import 'package:pokedex/pokeapi/entities/pokemon.dart';
import 'package:pokedex/utils/string.dart';
import 'package:pokedex/views/pokemon_details.dart';

class HeaderWidget extends StatefulWidget {
  final Pokemon pokemon;
  final PokemonTypeTheme theme;

  const HeaderWidget(this.pokemon, this.theme, {super.key});

  @override
  State<StatefulWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget>
    with SingleTickerProviderStateMixin {
  late List<String> spriteUrls;
  int currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  bool _isShinySprite(String url) {
    return url.contains("shiny");
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    spriteUrls = [
      if (widget.pokemon.sprites.frontDefault != null)
        widget.pokemon.sprites.frontDefault!,
      if (widget.pokemon.sprites.backDefault != null)
        widget.pokemon.sprites.backDefault!,
      if (widget.pokemon.sprites.frontShiny != null)
        widget.pokemon.sprites.frontShiny!,
      if (widget.pokemon.sprites.backShiny != null)
        widget.pokemon.sprites.backShiny!,
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        color: widget.theme.primary.withValues(alpha: 0.2),
      ),
      child: Column(
        children: [
          // Animated image gallery
          SizedBox(
            height: 280,
            child: PageView.builder(
              itemCount: spriteUrls.length,
              itemBuilder: (context, index) {
                Widget imageWidget = CachedNetworkImage(
                  width: 220,
                  height: 220,
                  imageUrl: spriteUrls[index],
                  fit: BoxFit.contain,
                  progressIndicatorBuilder:
                      (_, __, progressDownload) => Center(
                        child: PokeballProgressIndicator(
                          color: widget.theme.primary,
                        ),
                      ),
                  errorWidget:
                      (_, __, ___) => const Center(
                        child: Icon(Icons.error, size: 64, color: Colors.red),
                      ),
                );

                if (index == 0) {
                  imageWidget = Hero(
                    tag: 'pokemon-${widget.pokemon.id}',
                    transitionOnUserGestures: true,
                    child: imageWidget,
                  );
                }

                return Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    // Subtle background shape for the image
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Container(
                          width: 220 + (_animation.value * 20),
                          height: 220 + (_animation.value * 20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.theme.secondary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        );
                      },
                    ),

                    // Apply shiny effect or regular image
                    _isShinySprite(spriteUrls[index])
                        ? ShinySparkleEffect(child: imageWidget)
                        : imageWidget,

                    // Shiny indicator badge
                    if (_isShinySprite(spriteUrls[index]))
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.white, size: 18),
                              SizedBox(width: 4),
                              Text(
                                'Shiny',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
            ),
          ),

          // Image pagination indicators
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(spriteUrls.length, (index) {
                final isActive = currentPage == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  width: isActive ? 12.0 : 8.0,
                  height: isActive ? 12.0 : 8.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? widget.theme.primary : Colors.grey,
                    boxShadow:
                        isActive
                            ? [
                              BoxShadow(
                                color: widget.theme.primary.withValues(
                                  alpha: 0.5,
                                ),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ]
                            : null,
                  ),
                );
              }),
            ),
          ),

          // Sprite type indicator
          if (spriteUrls.isNotEmpty)
            Text(
              _isShinySprite(spriteUrls[currentPage])
                  ? 'Shiny ${currentPage % 2 == 0 ? "Front" : "Back"} View'
                  : '${currentPage % 2 == 0 ? "Front" : "Back"} View',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: widget.theme.primary,
              ),
            ),

          // Pokémon type badges
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12.0,
              children:
                  widget.pokemon.types.map((type) {
                    final typeTheme =
                        pokemonTypeThemes[type.type.name] ??
                        pokemonTypeThemes['normal']!;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: typeTheme.primary,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: typeTheme.primary.withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        type.type.name.capitalize(),
                        style: TextStyle(
                          color: typeTheme.text,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
