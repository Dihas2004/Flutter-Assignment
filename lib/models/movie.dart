

import 'package:movie_app/constants.dart';




class Movies {
  String? title;
  int? movieReleaseYear;
  String? posterPath;
  double? voteAvg;
  String description;
  String? backdropPath;

  Movies({
    this.title,
    this.movieReleaseYear,
    this.voteAvg,
    this.posterPath,
    required this.description,
    this.backdropPath,
  });

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
      
    );
  }
}

