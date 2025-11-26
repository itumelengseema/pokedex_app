class Pokemon {
  final String name;
  final String url;
  final String? imageUrl;

  Pokemon({required this.name, required this.url, this.imageUrl});

  String get id => url.split('/').where((e) => e.isNotEmpty).last;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pokemon && runtimeType == other.runtimeType && url == other.url;

  @override
  int get hashCode => url.hashCode;
}

