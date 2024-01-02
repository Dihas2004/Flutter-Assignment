

class Movies{
  String title;
  String backdropPath;
  String oriTitle;
  String description;
  String posterPath;
  String releaseDate;
  double voteAvg;

  Movies({
    required this.title,
    required this.backdropPath,
    required this.oriTitle,
    required this.description,
    required this.posterPath,
    required this.releaseDate,
    required this.voteAvg,

  });

  factory Movies.fromJson(Map<String, dynamic> json){
    return Movies(
      title: json["title"],
      backdropPath: json["poster_path"],
      oriTitle: json["original_title"],
      description: json["overview"],
      posterPath: json["poster_path"], 
      releaseDate: json["release_date"], 
      voteAvg: json["vote_average"]
      );
  }

  // Map<String,dynamic> toJson()=>{
  //   "title":title,
  //   "overview":description,
    
  // };

}