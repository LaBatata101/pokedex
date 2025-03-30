import 'package:flutter/material.dart';

class PokemonInfo extends StatelessWidget {
  final int index;
  const PokemonInfo({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Details")),
      body: Center(child: Text("Details from Pokemon $index")),
    );
  }
}
