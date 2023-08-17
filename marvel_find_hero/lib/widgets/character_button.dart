// widgets/character_button.dart

import 'package:flutter/material.dart';
import '../models/marvel_character.dart';
import '../screens/character_detail_screen.dart';

class CharacterButton extends StatelessWidget {
  final MarvelCharacter character;
  final VoidCallback onPressed;

  CharacterButton({
    required this.character,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
      child: Row(
        children: [
          SizedBox(width: 0),
          Container(
            width: 55,
            height: 55,
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
    );
  }
}
