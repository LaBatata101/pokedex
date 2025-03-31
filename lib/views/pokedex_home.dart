import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/utils/logging.dart';
import 'package:pokedex/viewmodels/home_view_model.dart';
import 'package:pokedex/views/pokemon_info.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/utils/string.dart';

class PokedexHome extends StatefulWidget {
  const PokedexHome({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _PokedexHomeState();
}

class _PokedexHomeState extends State<PokedexHome> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        context.read<HomeViewModel>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Consumer<HomeViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.allPokemonResources.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              spacing: 10,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
                  child: TextField(
                    textInputAction: TextInputAction.search,
                    onChanged: viewModel.onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(
                          width: 2,
                          color: Colors.green,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          width: 2,
                          color: Colors.green,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 150,
                              childAspectRatio: 0.8,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                            ),
                        itemCount: viewModel.displayedPokemon.length,
                        itemBuilder: (context, index) {
                          final resource = viewModel.displayedPokemon[index];
                          return FutureBuilder(
                            future: viewModel.api.pokemon.getByUrl(
                              resource.url,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final pokemon = snapshot.data!;
                                return Card(
                                  elevation: 2,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder:
                                              (context) => PokemonInfo(
                                                index: pokemon.id,
                                              ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                pokemon.sprites.frontDefault ??
                                                '',
                                            progressIndicatorBuilder:
                                                (_, _, progressDownload) =>
                                                    CircularProgressIndicator(
                                                      value:
                                                          progressDownload
                                                              .progress,
                                                    ),
                                            errorWidget:
                                                (_, _, _) =>
                                                    const Icon(Icons.error),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            pokemon.name.capitalize(),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                logger.e(
                                  "Error while loading pokemon info ${resource.url}",
                                  error: snapshot.error,
                                  stackTrace: snapshot.stackTrace,
                                );
                                return const Center(child: Icon(Icons.error));
                              }
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );
                        },
                      ),
                      if (viewModel.isLoading)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
