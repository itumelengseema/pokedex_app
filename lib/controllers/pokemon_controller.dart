import 'package:pokedex_app/models/pokemon.dart';

class PokemonController {
  Future<List<Pokemon>> getDummyPokemon() async {
    await Future.delayed(Duration(seconds: 3));

    return DummyPokemonData.pokemon;
  }
}