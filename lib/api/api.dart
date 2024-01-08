import 'dart:convert';

import 'package:movie_app/constants.dart';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class API{
  //isolate some parts of URL
  static const _trendingURL = 'https://api.themoviedb.org/3/trending/movie/day?api_key=${Constants.apiKey}';
  static const _topRatedURL = 'https://api.themoviedb.org/3/movie/top_rated?api_key=${Constants.apiKey}';
  static const _grossingMoviesURL = 'https://api.themoviedb.org/3/discover/movie?api_key=${Constants.apiKey}&sort_by=revenue.desc';


  Future<List<Movies>> getTrendingMovies() async{
    final response = await http.get(Uri.parse(_trendingURL));
    if (response.statusCode == 200){
      final decodedData = json.decode(response.body)['results'] as List;
      return decodedData.map((movie)=>Movies.fromJson(movie)).toList();
    }else{
      throw Exception('Something happened');
    }

  }


  Future<List<Movies>> getTopRatedMovies() async{
    final response = await http.get(Uri.parse(_topRatedURL));
    if (response.statusCode == 200){
      final decodedData = json.decode(response.body)['results'] as List;
      return decodedData.map((movie)=>Movies.fromJson(movie)).toList();
    }else{
      throw Exception('Something happened');
    }

  }

  Future<List<Movies>> getGrossingMovies() async{
    final response = await http.get(Uri.parse(_grossingMoviesURL));
    if (response.statusCode == 200){
      final decodedData = json.decode(response.body)['results'] as List;
      return decodedData.map((movie)=>Movies.fromJson(movie)).toList();
    }else{
      throw Exception('Something happened');
    }

  }


}