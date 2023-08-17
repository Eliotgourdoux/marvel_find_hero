import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class IronManScreen extends StatefulWidget {
  @override
  _IronManScreenState createState() => _IronManScreenState();
}

class _IronManScreenState extends State<IronManScreen> {
  String ironManImageUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchIronManImage();
  }

  Future<void> _fetchIronManImage() async {
    final publicKey = 'VOTRE_CLÉ_PUBLIQUE';
    final privateKey = 'VOTRE_CLÉ_PRIVÉE';
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = md5.convert(utf8.encode('$timestamp$privateKey$publicKey')).toString();

    final response = await http.get(
      Uri.parse('https://gateway.marvel.com/v1/public/characters/1009368?ts=$timestamp&apikey=$publicKey&hash=$hash'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        ironManImageUrl = data['data']['results'][0]['thumbnail']['path'] + '.' + data['data']['results'][0]['thumbnail']['extension'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iron Man'),
      ),
      body: Center(
        child: ironManImageUrl.isNotEmpty
            ? Image.network(ironManImageUrl)
            : CircularProgressIndicator(), // Affiche une roue de chargement tant que l'image n'est pas chargée
      ),
    );
  }
}
