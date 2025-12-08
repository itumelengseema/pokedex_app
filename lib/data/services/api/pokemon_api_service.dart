import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pokedex_app/data/models/pokemon_model.dart';
import 'package:pokedex_app/data/models/pokemon_detail_model.dart';

class PaginatedPokemonResponse {
  final List<Pokemon> results;
  final int? totalCount;
  final bool hasMore;

  PaginatedPokemonResponse({
    required this.results,
    required this.totalCount,
    required this.hasMore,
    });
}


class PokemonApiService {

  static const String baseUrl = 'https://pokeapi.co/api/v2';

  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration totalTimeout = Duration(seconds: 60);

  Future<List<Pokemon>> fetchPokemonList(int offset, int limit) async {
    const int batchSize = 5;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pokemon?offset=$offset&limit=$limit'),
      ).timeout(apiTimeout);

      if (response.statusCode != 200) throw Exception('Failed to load Pokemon');

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;

      final pokemonList = <Pokemon>[];

      
      for (var i = 0; i < results.length; i += batchSize) {
        final batch = results.skip(i).take(batchSize);
        final batchFutures = batch.map((item) async {
          final url = item['url'] as String;
          try {
            final pokemonResponse = await http.get(Uri.parse(url)).timeout(apiTimeout);
            if (pokemonResponse.statusCode == 200) {
              final detailData =
                  jsonDecode(pokemonResponse.body) as Map<String, dynamic>;
              final name = detailData['name'] as String;

              final imageUrl =
                  detailData['sprites']?['other']?['official-artwork']?['front_default']
                      as String?;

              final types = (detailData['types'] as List?)
                  ?.map((typeData) => typeData['type']['name'] as String)
                  .toList();

              return Pokemon(
                name: name,
                url: url,
                imageUrl: imageUrl,
                types: types,
              );
            }
          } catch (e) {
            
            return Pokemon(
              name: item['name'] as String,
              url: url,
              imageUrl: null,
            );
          }
          return null;
        }).toList();

        final batchResults = (await Future.wait(batchFutures)).whereType<Pokemon>().toList();
        pokemonList.addAll(batchResults);

        
        if (i + batchSize < results.length) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      return pokemonList;
    } catch (e) {
      throw Exception('Failed to load Pokemon: $e');
    }
  }

  Future<PokemonDetail> fetchPokemonDetail(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(apiTimeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to load Pokemon details');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final detail = PokemonDetail.fromJson(data);

      return detail;
    } catch (e) {
      throw Exception('Failed to load Pokemon details: $e');
    }
  }

  Future<EvolutionChain> fetchEvolutionChain(String speciesUrl) async {
    try {
      final speciesResponse = await http.get(Uri.parse(speciesUrl)).timeout(apiTimeout);
      if (speciesResponse.statusCode != 200) {
        throw Exception('Failed to load species data');
      }

      final speciesData =
          jsonDecode(speciesResponse.body) as Map<String, dynamic>;
      final evolutionChainUrl = speciesData['evolution_chain']['url'] as String;

      final evolutionResponse = await http.get(Uri.parse(evolutionChainUrl)).timeout(apiTimeout);
      if (evolutionResponse.statusCode != 200) {
        throw Exception('Failed to load evolution chain');
      }

      final evolutionData =
          jsonDecode(evolutionResponse.body) as Map<String, dynamic>;
      final evolutions = _parseEvolutionChain(evolutionData['chain']);

      return EvolutionChain(evolutions: evolutions);
    } catch (e) {
      throw Exception('Failed to load evolution chain: $e');
    }
  }

  List<Evolution> _parseEvolutionChain(Map<String, dynamic> chain) {
    final evolutions = <Evolution>[];

    void parseChain(Map<String, dynamic> current) {
      final speciesData = current['species'] as Map<String, dynamic>;
      final name = speciesData['name'] as String;
      final url = speciesData['url'] as String;
      final id = int.parse(url.split('/').where((e) => e.isNotEmpty).last);
      final imageUrl =
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

      evolutions.add(Evolution(name: name, id: id, imageUrl: imageUrl));

      final evolvesTo = current['evolves_to'] as List<dynamic>;
      if (evolvesTo.isNotEmpty) {
        parseChain(evolvesTo.first as Map<String, dynamic>);
      }
    }

    parseChain(chain);
    return evolutions;
  }

  Future<List<Pokemon>> searchPokemon(String query, {int limit = 20}) async {
    final lowerQuery = query.toLowerCase().trim();

    if (lowerQuery.isEmpty) {
      return [];
    }

    try {
      final url = Uri.parse('$baseUrl/pokemon/$lowerQuery');
      final response = await http.get(url).timeout(apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final types = (data['types'] as List)
            .map((typeData) => typeData['type']['name'] as String)
            .toList();

        final imageUrl = data['sprites']?['other']?['official-artwork']?['front_default'] as String?;

        return [
          Pokemon(
            name: data['name'],
            url: '$baseUrl/pokemon/${data['id']}/',
            types: types,
            imageUrl: imageUrl,
          )
        ];
      }
    } catch (_) {
    }

    return [];
  }
}
