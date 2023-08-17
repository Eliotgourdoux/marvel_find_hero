import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:crypto/crypto.dart';
import '../models/marvel_character.dart';
import 'character_detail_screen.dart';
import '../widgets/character_button.dart';

class IronManScreen extends StatefulWidget {
  @override
  _IronManScreenState createState() => _IronManScreenState();
}

class _IronManScreenState extends State<IronManScreen> {
  final String publicKey = 'edf49139ed29963bfdc8030395b6d1c0';
  final String privateKey = '4cc05534f46e517331402b515afce124b97504e3';

  List<MarvelCharacter> characters = [];
  bool isLoading = false;

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

  Future<void> _fetchMarvelCharacters({int offset = 0}) async {
    if (isLoading) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = md5.convert(utf8.encode('$timestamp$privateKey$publicKey')).toString();

    final response = await http.get(
      Uri.parse('https://gateway.marvel.com/v1/public/characters?ts=$timestamp&apikey=$publicKey&hash=$hash&offset=$offset'),
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
        isLoading = false;
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
    });

    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = md5.convert(utf8.encode('$timestamp$privateKey$publicKey')).toString();

    final response = await http.get(
      Uri.parse('https://gateway.marvel.com/v1/public/characters?ts=$timestamp&apikey=$publicKey&hash=$hash&nameStartsWith=$query'),
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
        isLoading = false;
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
                      _fetchMarvelCharacters(offset: characters.length);
                    }
                    return true;
                  },
                  child: Column(
                    children: [
                      if (isLoading) CircularProgressIndicator(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: characters.length,
                          itemBuilder: (context, index) {
                            final character = characters[index];
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: CharacterButton(
                                character: character,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => CharacterDetailScreen(character: character, publicKey: publicKey, privateKey: privateKey)),
                                  );
                                },
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
