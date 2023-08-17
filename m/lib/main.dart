import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Premiere',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red,
        ),
      ),
      home: IronManScreen(),
    );
  }
}

class MarvelCharacter {
  final String id;
  final String name;
  final String imageUrl;
  final String description;

  MarvelCharacter({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
  });
}

class IronManScreen extends StatefulWidget {
  @override
  _IronManScreenState createState() => _IronManScreenState();
}

class _IronManScreenState extends State<IronManScreen> {
  final String publicKey = 'edf49139ed29963bfdc8030395b6d1c0';
  final String privateKey = '4cc05534f46e517331402b515afce124b97504e3';

  List<MarvelCharacter> characters = [];
  int loadedCharacterCount = 0;
  bool isLoading = false;
  bool isLoadingCharacters = false;

  late TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    _fetchMarvelCharacters();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        _searchCharacters(_searchController.text);
      } else {
        _fetchMarvelCharacters();
      }
    });
  }

  Future<void> _fetchMarvelCharacters() async {
    if (isLoading) {
      return;
    }

    setState(() {
      isLoading = true;
      isLoadingCharacters = true;
    });

    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = md5.convert(utf8.encode('$timestamp$privateKey$publicKey')).toString();

    final response = await http.get(
      Uri.parse('https://gateway.marvel.com/v1/public/characters?ts=$timestamp&apikey=$publicKey&hash=$hash&offset=$loadedCharacterCount'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final characterData = data['data']['results'];

      setState(() {
        characters.addAll(characterData.map<MarvelCharacter>((charData) {
          return MarvelCharacter(
            id: charData['id'].toString(),
            name: charData['name'],
            imageUrl: charData['thumbnail']['path'] + '.' + charData['thumbnail']['extension'],
            description: charData['description'],
          );
        }).toList());
        loadedCharacterCount += 10;
        isLoading = false;
        isLoadingCharacters = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _searchCharacters(String query) async {
    if (isLoading) {
      return;
    }

    setState(() {
      isLoading = true;
      characters.clear();
      loadedCharacterCount = 0;
      isLoadingCharacters = true;
    });

    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = md5.convert(utf8.encode('$timestamp$privateKey$publicKey')).toString();

    final response = await http.get(
      Uri.parse('https://gateway.marvel.com/v1/public/characters?ts=$timestamp&apikey=$publicKey&hash=$hash&nameStartsWith=$query&offset=$loadedCharacterCount'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final characterData = data['data']['results'];

      setState(() {
        characters.addAll(characterData.map<MarvelCharacter>((charData) {
          return MarvelCharacter(
            id: charData['id'].toString(),
            name: charData['name'],
            imageUrl: charData['thumbnail']['path'] + '.' + charData['thumbnail']['extension'],
            description: charData['description'],
          );
        }).toList());
        loadedCharacterCount += 10;
        isLoading = false;
        isLoadingCharacters = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Marvel Characters',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        color: Colors.blue,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search characters',
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (!isLoading && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                      _fetchMarvelCharacters();
                    }
                    return true;
                  },
                  child: Column(
                    children: [
                      if (isLoadingCharacters) CircularProgressIndicator(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: characters.length,
                          itemBuilder: (context, index) {
                            final character = characters[index];
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => CharacterDetailScreen(character: character, publicKey: publicKey, privateKey: privateKey)),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(width: 0),
                                    Container(
                                      width: 65,
                                      height: 65,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: NetworkImage(character.imageUrl),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Text(
                                      character.name,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CharacterDetailScreen extends StatelessWidget {
  final MarvelCharacter character;
  final String publicKey;
  final String privateKey;

  CharacterDetailScreen({required this.character, required this.publicKey, required this.privateKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          character.name,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.width,
              color: Colors.grey,
              child: Image.network(
                character.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10),
            Text(
              character.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                character.description.isNotEmpty ? character.description : 'No description available.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
