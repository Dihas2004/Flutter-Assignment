import 'dart:convert';

import 'package:movie_app/constants.dart';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class API{
  //isolate some parts of URL
  static const _trendingURL = 'https://api.themoviedb.org/3/trending/movie/day?api_key=${Constants.api_key}';

  Future<List<Movies>> getTrendingMovies() async{
    final response = await http.get(Uri.parse(_trendingURL));
    if (response.statusCode == 200){
      final decodedData = json.decode(response.body)['results'] as List;
      return decodedData.map((movie)=>Movies.fromJson(movie)).toList();
    }else{
      throw Exception('Something happened');
    }

  }


}