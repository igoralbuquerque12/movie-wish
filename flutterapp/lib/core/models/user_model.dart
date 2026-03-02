class UserModel {
  final String id;
  final String name;
  final String email;
  final List<int> favoriteGenres;
  final List<int> wishMovies;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.favoriteGenres,
    this.wishMovies = const [],
  });

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // Converte int (2) para String ("2")
      id: json['id'].toString(),

      // Pega o nome vindo da API
      name: json['name'] as String? ?? '',

      email: json['email'] as String,

      // CORREÇÃO: A API retorna 'favoriteGenrers' (typo), não 'favoriteGenres'
      // Adicionei uma verificação dupla (??) para funcionar caso corrijam a API no futuro
      favoriteGenres: (json['favoriteGenrers'] ?? json['favoriteGenres']) != null
          ? ((json['favoriteGenrers'] ?? json['favoriteGenres']) as List<dynamic>)
          .map((e) => int.parse(e.toString()))
          .toList()
          : [],

      // WishMovies (lista de IDs de filmes salvos)
      wishMovies: (json['wishMovies'] as List<dynamic>?)
              ?.map((e) => int.parse(e.toString()))
              .toList() ??
          [],
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'favoriteGenres': favoriteGenres,
      'wishMovies': wishMovies,
    };
  }

  /// Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    List<int>? favoriteGenres,
    List<int>? wishMovies,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      wishMovies: wishMovies ?? this.wishMovies,
    );
  }
}