import 'package:flutter/material.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const PokedexHome(title: 'Flutter Demo Home Page'),
    );
  }
}

class PokedexHome extends StatefulWidget {
  const PokedexHome({super.key, required this.title});

  final String title;

  @override
  State<PokedexHome> createState() => _PokedexHomeState();
}

class _PokedexHomeState extends State<PokedexHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          spacing: 10,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(width: 2, color: Colors.green),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: 40,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  List<Widget> items = List.generate(3, (i) {
                    return Text(
                      'Item ${i + index}',
                      style: TextStyle(fontSize: 20),
                    );
                  });
                  List<Widget> rowChildren = [];
                  for (final item in items) {
                    rowChildren.add(
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PokemonInfo(index: index),
                            ),
                          );
                        },
                        child: item,
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: rowChildren,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
