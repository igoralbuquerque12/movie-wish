class GenreModel {
  final int id; // Mudou de String para int
  final String name;

  const GenreModel({
    required this.id,
    required this.name,
  });

  // Lista atualizada com os IDs numéricos oficiais
  static const List<GenreModel> allGenres = [
    GenreModel(id: 28, name: 'Ação'),
    GenreModel(id: 12, name: 'Aventura'),
    GenreModel(id: 16, name: 'Animação'),
    GenreModel(id: 35, name: 'Comédia'),
    GenreModel(id: 80, name: 'Crime'),
    GenreModel(id: 99, name: 'Documentário'),
    GenreModel(id: 18, name: 'Drama'),
    GenreModel(id: 10751, name: 'Família'),
    GenreModel(id: 14, name: 'Fantasia'),
    GenreModel(id: 36, name: 'História'),
    GenreModel(id: 27, name: 'Terror'),
    GenreModel(id: 10402, name: 'Música'),
    GenreModel(id: 9648, name: 'Mistério'),
    GenreModel(id: 10749, name: 'Romance'),
    GenreModel(id: 878, name: 'Ficção científica'),
    GenreModel(id: 10770, name: 'Cinema TV'),
    GenreModel(id: 53, name: 'Thriller'),
    GenreModel(id: 10752, name: 'Guerra'),
    GenreModel(id: 37, name: 'Faroeste'),
  ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GenreModel && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}