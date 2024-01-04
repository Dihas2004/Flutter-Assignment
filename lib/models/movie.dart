

import 'package:movie_app/constants.dart';

// class Movies{
//   String? title;
//   String backdropPath;
//   String oriTitle;
//   String description;
//   String? posterPath;
//   String releaseDate;
//   double? voteAvg;

//   Movies({
//     required this.title,
//     required this.backdropPath,
//     required this.oriTitle,
//     required this.description,
//     required this.posterPath,
//     required this.releaseDate,
//     required this.voteAvg,

//   });

//   factory Movies.fromJson(Map<String, dynamic> json){
//     return Movies(
//       title: json["title"],
//       backdropPath: json["poster_path"],
//       oriTitle: json["original_title"],
//       description: json["overview"],
//       posterPath: json["poster_path"], 
//       releaseDate: json["release_date"].toString(), 
//       voteAvg: json["vote_average"].toDouble(),
//       );
//   }


class Movies {
  String? title;
  int? movieReleaseYear;
  String? posterPath;
  double? voteAvg;
  String description;

  Movies({
    this.title,
    this.movieReleaseYear,
    this.voteAvg,
    this.posterPath,
    required this.description,
  });

  factory Movies.fromJson(Map<String, dynamic> json) {
    return Movies(
      title: json['original_title'] as String?,
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

  // factory Movies.fromJson(Map<String, dynamic> json) {
  //   return Movies(
  //     title: json['original_title'] as String?,
      
  //     voteAvg: json['vote_average'] != null
  //         ? (json['vote_average'] as num).toDouble()
  //         : null,
  //     posterPath: json['poster_path'] != null
  //         ? '${Constants.imageBaseUrl}${json['poster_path']}'
  //         : null,
  //   );
  // }

  // Map<String,dynamic> toJson()=>{
  //   "title":title,
  //   "overview":description,
    
  // };

