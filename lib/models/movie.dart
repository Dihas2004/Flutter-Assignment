

import 'package:movie_app/constants.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Cast {
  bool adult;
  int gender;
  int id;
  String knownForDepartment;
  String name;
  String originalName;
  double popularity;
  String? profilePath;
  int castId;
  String character;
  String creditId;

  Cast({
    required this.adult,
    required this.gender,
    required this.id,
    required this.knownForDepartment,
    required this.name,
    required this.originalName,
    required this.popularity,
    this.profilePath,
    required this.castId,
    required this.character,
    required this.creditId,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      adult: json['adult'] as bool,
      gender: json['gender'] as int,
      id: json['id'] as int,
      knownForDepartment: json['known_for_department'] as String,
      name: json['name'] as String,
      originalName: json['original_name'] as String,
      popularity: json['popularity'] as double,
      profilePath: json['profile_path'] as String?,
      castId: json['cast_id'] as int,
      character: json['character'] as String,
      creditId: json['credit_id'] as String,
    );
  }
}


class Movies {
  String? title;
  int? movieReleaseYear;
  String? posterPath;
  double? voteAvg;
  String description;
  String? backdropPath;
  int? movieID;
  List<Cast> cast;

  List<int> watchedMovies = [];

  Movies({
    this.title,
    this.movieReleaseYear,
    this.voteAvg,
    this.posterPath,
    required this.description,
    this.backdropPath,
    this.movieID,
    required this.cast,
  });

  void markAsWatched(int movieId) {
    if (!watchedMovies.contains(movieId)) {
      watchedMovies.add(movieId);
    }
  }

  // Function to check if a movie is watched
  bool isMovieWatched(int movieId) {
    return watchedMovies.contains(movieId);
  }

  

  factory Movies.fromJson(Map<String, dynamic> json) {
    return Movies(
      title: json['original_title'] as String?,
      backdropPath: json["backdrop_path"] as String?,
      description: json["overview"],
      movieReleaseYear: json['release_date'] != null
          ? int.tryParse(json['release_date'].toString().split('-')[0])
          : null,
      voteAvg: json['vote_average'] != null
          ? (json['vote_average'] as num).toDouble()
          : null,
      posterPath: json['poster_path'] != null
          ? '${Constants.imageBaseUrl}${json['poster_path']}'
          : null,
      movieID: json['id'] as int,
      cast: (json['cast'] as List<dynamic>?)
          ?.map((actor) => Cast.fromJson(actor))
          .toList() ?? [],
      
    );
  }
  Future<void> fetchCredits(int movieId) async {
  final url = 'https://api.themoviedb.org/3/movie/$movieId/credits?api_key=${Constants.apiKey}';
  print('Fetching credits from: $url');

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final decodedData = json.decode(response.body);
    
    // Print the response to check if it contains the expected data
    print('Credits response: $decodedData');

    // Extract cast
    cast = (decodedData['cast'] as List)
        .map((actor) => Cast.fromJson(actor))
        .toList();
    
  } else {
    print('Failed to fetch credits. Status code: ${response.statusCode}, Response body: ${response.body}');
    throw Exception('Failed to fetch credits');
  }
}
}

