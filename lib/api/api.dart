import 'dart:convert';

import 'package:movie_app/constants.dart';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class API{
  //isolate some parts of URL
  static const _trendingURL = 'https://api.themoviedb.org/3/trending/movie/day?api_key=${Constants.apiKey}';
  static const _trendingWeekURL = 'https://api.themoviedb.org/3/trending/movie/week?api_key=${Constants.apiKey}';
  static const _topRatedURL = 'https://api.themoviedb.org/3/movie/top_rated?api_key=${Constants.apiKey}';
  static const _grossingMoviesURL = 'https://api.themoviedb.org/3/discover/movie?api_key=${Constants.apiKey}&sort_by=revenue.desc';
  static const _childFriendlyURL = 'https://api.themoviedb.org/3/discover/movie?api_key=${Constants.apiKey}&sort_by=revenue.desc&adult=false&with_genres=16' ;
  static const _actionChildFriendlyURL = 'https://api.themoviedb.org/3/discover/movie?api_key=${Constants.apiKey}&adult=false&with_genres=16,28';
  static const _romanticChildFriendlyURL = 'https://api.themoviedb.org/3/discover/movie?api_key=${Constants.apiKey}&adult=false&with_genres=16,10749';
  static const _childFriendlyVoteURL = 'https://api.themoviedb.org/3/discover/movie?api_key=${Constants.apiKey}&with_genres=16,28&sort_by=vote_average.desc' ;


  Future<List<Movies>> getTrendingMovies() async{
    final response = await http.get(Uri.parse(_trendingURL));
    if (response.statusCode == 200){
      final decodedData = json.decode(response.body)['results'] as List;
      return decodedData.map((movie)=>Movies.fromJson(movie)).toList();
    }else{
      throw Exception('Something happened');
    }

  }

  Future<List<Movies>> getTrendingWeekMovies() async{
    final response = await http.get(Uri.parse(_trendingWeekURL));
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

  Future<List<Movies>> getChildMovies() async{
    final response = await http.get(Uri.parse(_childFriendlyURL));
    if (response.statusCode == 200){
      final decodedData = json.decode(response.body)['results'] as List;
      return decodedData.map((movie)=>Movies.fromJson(movie)).toList();
    }else{
      throw Exception('Something happened');
    }

  }

  Future<List<Movies>> getChildVoteMovies() async{
    final response = await http.get(Uri.parse(_childFriendlyVoteURL));
    if (response.statusCode == 200){
      final decodedData = json.decode(response.body)['results'] as List;
      return decodedData.map((movie)=>Movies.fromJson(movie)).toList();
    }else{
      throw Exception('Something happened');
    }

  }

  Future<List<Movies>> getActionChildMovies() async{
    final response = await http.get(Uri.parse(_actionChildFriendlyURL));
    if (response.statusCode == 200){
      final decodedData = json.decode(response.body)['results'] as List;
      return decodedData.map((movie)=>Movies.fromJson(movie)).toList();
    }else{
      throw Exception('Something happened');
    }

  }

  Future<List<Movies>> getRomanticChildMovies() async{
    final response = await http.get(Uri.parse(_romanticChildFriendlyURL));
    if (response.statusCode == 200){
      final decodedData = json.decode(response.body)['results'] as List;
      return decodedData.map((movie)=>Movies.fromJson(movie)).toList();
    }else{
      throw Exception('Something happened');
    }

  }


}