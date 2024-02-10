import 'package:flutter/material.dart';
import 'package:movie_app/constants.dart';
import 'package:movie_app/models/movie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:movie_app/widgets/grid_view_slider.dart';

class MoviesGridScreen extends StatefulWidget {
  final String movieType; // Add this parameter

  MoviesGridScreen({required this.movieType});
  @override
  _MoviesGridScreenState createState() => _MoviesGridScreenState();
}

class _MoviesGridScreenState extends State<MoviesGridScreen> {
  late ScrollController scrollController;
  late List<Movies> displayedMovies;
  late List<Movies> storedMovies;
  late int currentPage;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    displayedMovies = [];
    storedMovies = [];
    currentPage = 1;
    searchController = TextEditingController();

    // Fetch initial movies
    fetchMovies();
    
    // Add a listener to the scrollController to detect when the user reaches the end
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        // User has reached the end of the list
        // Fetch more movies and append them to displayedMovies
        fetchMovies();
      }
    });
  }

  Future<void> fetchMovies() async {
    try {
      List<Movies> moreMovies = await fetchAllMoviesWithPage(currentPage);
      displayedMovies.addAll(moreMovies);
      storedMovies = displayedMovies;
      currentPage++;

      setState(() {});
    } catch (e) {
      // Handle error fetching more movies
    }
  }

  Future<List<Movies>> fetchAllMoviesWithPage(int page) async {
    List<Movies> allMovies = [];
    String url = '';

    // Customize the API endpoint based on the movie type
    
    if (widget.movieType == 'Top Rated') {
      
      url = 'https://api.themoviedb.org/3/movie/top_rated?api_key=${Constants.apiKey}&page=$page';
    } else if (widget.movieType == 'Grossing') {
      
      url = 'https://api.themoviedb.org/3/discover/movie?api_key=${Constants.apiKey}&sort_by=revenue.desc&page=$page';
    }

    final response = await http.get(
      Uri.parse(url),
    );
    

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> movies = data['results'] ?? [];
      allMovies.addAll(movies.map((json) => Movies.fromJson(json)).toList());
    } else {
      throw Exception('Failed to load movies');
    }

    return allMovies;
  }

  void searchMovies(String query) {
    List<Movies> results = storedMovies
        .where((movie) => movie.title!.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      displayedMovies = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movies Grid'),
        
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: searchMovies,
              decoration: InputDecoration(
                labelText: 'Search Movies',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(child: grid_slider(scrollController: scrollController, displayedMovies: displayedMovies)),
        ],
      ),
    );
  }
}
