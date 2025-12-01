import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pokedex_app/controllers/pokemon_controller.dart';
import 'package:pokedex_app/models/pokemon.dart';
import 'package:pokedex_app/services/api_services.dart';

// ignore: unused_import
import '../views/screens/home_screen_test.mocks.dart' hide MockApiServices;
@GenerateMocks([ApiServices])
import 'pokemon_controller_test.mocks.dart';

void main() {
  group('PokemonController', () {
    late PokemonController controller;
    late MockApiServices mockApiService;

    setUp(() {
      mockApiService = MockApiServices();
      controller = PokemonController(apiService: mockApiService);
    });

    test(
      'should create instance with default ApiServices when none provided',
      () {
        final controller = PokemonController();
        expect(controller, isNotNull);
      },
    );

    test('should create instance with provided ApiServices', () {
      final controller = PokemonController(apiService: mockApiService);
      expect(controller, isNotNull);
    });

    test('should fetch pokemon list successfully', () async {
      final mockPokemonList = [
        Pokemon(name: 'bulbasaur', url: 'url1'),
        Pokemon(name: 'ivysaur', url: 'url2'),
      ];

      when(
        mockApiService.fetchPokemon(0, 20),
      ).thenAnswer((_) async => mockPokemonList);

      final result = await controller.fetchPokemon(0, 20);

      expect(result, mockPokemonList);
      expect(result.length, 2);
      verify(mockApiService.fetchPokemon(0, 20)).called(1);
    });

    test('should pass correct offset and limit to api service', () async {
      when(mockApiService.fetchPokemon(10, 30)).thenAnswer((_) async => []);

      await controller.fetchPokemon(10, 30);

      verify(mockApiService.fetchPokemon(10, 30)).called(1);
    });

    test('should throw exception when api service fails', () async {
      when(
        mockApiService.fetchPokemon(0, 20),
      ).thenThrow(Exception('Failed to fetch pokemon'));

      expect(() => controller.fetchPokemon(0, 20), throwsException);
    });
  });
}
