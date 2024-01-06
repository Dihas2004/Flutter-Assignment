import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:movie_app/constants.dart';
import 'package:movie_app/details_screen.dart';
import 'package:movie_app/models/movie.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Future<List<Movies>> moviesList;
  
  TextEditingController searchController = TextEditingController();
  List<Movies> displayedMovies = [];
  List<Movies> storedMovies = [];
  ScrollController scrollController = ScrollController();
  int currentPage = 1;

  
  Future<List<Movies>> searchMovies(String query) async {
    List<Movies> searchResults = [];

    final response = await http.get(
      Uri.parse(
          'https://api.themoviedb.org/3/search/movie?query=$query&api_key=${Constants.apiKey}'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> movies = data['results'] ?? [];
      searchResults.addAll(movies.map((json) => Movies.fromJson(json)).toList());
    } else {
      throw Exception('Failed to search movies');
    }

    return searchResults;
  }
  

  Future<List<Movies>> fetchAllMovies() async {
    List<Movies> allMovies = [];

    final response = await http.get(
      Uri.parse('https://api.themoviedb.org/3/movie/upcoming?api_key=c70ffdb8f341ef6671fac7cbbc1f09c6&page=1'),
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
   @override
  void initState() {
    super.initState();
    moviesList = fetchAllMovies();
    
    

    // Initialize displayedMovies with data from the first page
    moviesList.then((allMovies) {
      displayedMovies = allMovies;
      storedMovies = displayedMovies;

      for (Movies movie in displayedMovies) {
        movie.fetchCredits(movie.movieID!);
      }

      // Update the state to rebuild the UI with the fetched credits
      setState(() {});
    });

    // Add a listener to the scrollController to detect when the user reaches the end
    
  }
  

  // Method to fetch more movies and append them to displayedMovies
  

  List<Movies> updateList(List<Movies> allMovies, String query) {
  if (query.isEmpty) {
    return allMovies;
  }
  
  query = query.toLowerCase();
  
  return allMovies.where((movie) {
    // Check if the movie title contains the query
    //bool isTitleMatch = movie.title?.toLowerCase().contains(query) ?? false;

    // Check if any cast member name contains the query
    bool isCastMemberMatch = movie.cast.any((cast) =>
        cast.name.toLowerCase().contains(query));

    // Return true if either the movie title or any cast member matches the query
    return isCastMemberMatch;
  }).toList();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 70, bottom: 25),
            child: TextField(
              onChanged: (query) {
                if (query.isEmpty) {
              setState(() {
                // If query is empty, show allMovies
                moviesList = fetchAllMovies();
    // Initialize displayedMovies with data from the first page
              moviesList.then((allMovies) {
              displayedMovies = allMovies;
              });
                
              });
            }else{
            // Update the displayedMovies list based on the search query
                searchMovies(query).then((searchResults) {
                  displayedMovies = searchResults.take(20).toList();
                  setState(() {
                  // Update the state with the search results
                  this.displayedMovies = displayedMovies;
                  });
                });
            }
          },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search Movies',
                hintStyle: TextStyle(color: Colors.grey.shade700),
                filled: true,
                fillColor: Colors.black,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Movies>>(
              future: moviesList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading movies'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No Results Found :(',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                } else {
                  //displayedMovies = snapshot.data!;
                  //displayedMovies = displayedMovies.take(20).toList();
                  //displayedMovies = snapshot.data!;
                  //displayedMovies = displayedMovies.take(20).toList();

                  return displayedMovies.length == 0
                      ? Center(
                          child: Text(
                            'No Results Found :(',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                       
                  :ListView.builder(
                          controller: scrollController,
                          itemCount: displayedMovies.length,
                          itemBuilder: (context, index) => ListTile(
                            contentPadding: EdgeInsets.only(left: 30, right: 30),
                            title: Text(
                              displayedMovies[index].title!,
                              style:
                                  TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              '${displayedMovies[index].movieReleaseYear.toString()}',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            trailing: Text(
                              '${displayedMovies[index].voteAvg}',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 128, 123, 23)
                              ),
                            ),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.network(
                                '${Constants.imageBaseUrl}${displayedMovies[index].posterPath}',
                                width: 75,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            onTap: () async {
                                    final Movies selectedMovie = displayedMovies[index];
                                    await selectedMovie.fetchCredits(selectedMovie.movieID!);

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailsScreen(movie: selectedMovie),
                                      ),
                                    );
                                  },
                            // Other ListTile properties
                          ),
                        );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}