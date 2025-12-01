import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/views/widgets/search_bar.dart';

void main() {
  final String testHintText = 'Search for your favorite Pokémon';

  testWidgets('search bar ...', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PokemonSearchBar(hintText: testHintText, onSearch: (query) {}),
        ),
      ),
    );
  });

  testWidgets('displays hint text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PokemonSearchBar(hintText: testHintText, onSearch: (query) {}),
        ),
      ),
    );

    expect(find.text(testHintText), findsOneWidget);
  });

  testWidgets('calls onSearch callback on text input', (tester) async {
    String? searchedText;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PokemonSearchBar(
            hintText: testHintText,
            onSearch: (query) {
              searchedText = query;
            },
          ),
        ),
      ),
    );

    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    await tester.enterText(textField, 'Pikachu');
    await tester.pump();

    expect(searchedText, 'Pikachu');
  });

  testWidgets('clears text input when clear button is pressed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PokemonSearchBar(hintText: testHintText, onSearch: (query) {}),
        ),
      ),
    );

    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    await tester.enterText(textField, 'Charmander');
    await tester.pump();

    expect(find.text('Charmander'), findsOneWidget);

    final clearButton = find.byIcon(Icons.clear);
    expect(clearButton, findsOneWidget);

    await tester.tap(clearButton);
    await tester.pump();

    expect(find.text('Charmander'), findsNothing);
  });
}
