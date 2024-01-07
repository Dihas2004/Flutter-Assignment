import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:movie_app/constants.dart';
import 'package:movie_app/details_screen.dart';
import 'package:movie_app/models/actor.dart';
import 'package:movie_app/models/movie.dart';
import 'package:http/http.dart' as http;

enum SearchMode {
  MovieTitle,
  ActorName,
}

class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Future<List<Movies>> moviesList;
  SearchMode searchMode = SearchMode.MovieTitle;
  
  TextEditingController searchController = TextEditingController();
  List<Movies> displayedMovies = [];
  List<Movies> storedMovies = [];
  ScrollController scrollController = ScrollController();
  int currentPage = 1;

  Future<List<Movies>> getMoviesByActor(String actorName) async {
  List<Movies> searchResults = [];

  final actorDetails = await getActorDetails(actorName);
    final response = await http.get(
      Uri.parse(
          'https://api.themoviedb.org/3/discover/movie?with_cast=${actorDetails?.id}&sort_by=release_date.asc&api_key=${Constants.apiKey}&page=1',
        ),
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

  Future<Actor?> getActorDetails(String actorName) async {
    final response = await http.get(
      Uri.parse(
        'https://api.themoviedb.org/3/search/person?api_key=${Constants.apiKey}&query=$actorName&page=1',
      ),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> results = data['results'] ?? [];

      if (results.isNotEmpty) {
        return Actor.fromJson({
          'name': results[0]['name'],
          'known_for_department': results[0]['known_for_department'],
          'id': results[0]['id'],
        
        // Add other properties as needed
        });
      } else {
        return null;
      }
    } else {
      throw Exception('Failed to get actor details. Status code: ${response.statusCode}');
    }

  }

  void updateSearchMode(SearchMode mode) {
    setState(() {
      searchMode = mode;
      // Clear the search results when changing the mode
      displayedMovies = storedMovies;
      searchController.clear();
      if (searchMode == SearchMode.MovieTitle) {
        // Fetch and display the initial movies when searching by movie title
        moviesList.then((allMovies) {
          displayedMovies = allMovies.take(20).toList();
          setState(() {});
        });
      } else {
        // Fetch and display the initial movies when searching by actor name
        fetchAllMovies().then((allMovies) {
          displayedMovies = allMovies.take(20).toList();
          setState(() {});
        });
      }
    });
  }

  
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
            padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => updateSearchMode(SearchMode.MovieTitle),
                  style: ElevatedButton.styleFrom(
                    primary: searchMode == SearchMode.MovieTitle
                      ? Colors.blue // Highlighted color for selected mode
                      : Colors.grey.shade800,
                  ),
                  child: Text('Search by Movie Title'),
                ),
                ElevatedButton(
                
                  onPressed: () => updateSearchMode(SearchMode.ActorName),
                  style: ElevatedButton.styleFrom(
                    primary: searchMode == SearchMode.ActorName
                      ? Colors.blue // Highlighted color for selected mode
                      : Colors.grey.shade800,
                  ),
                  child: Text('Search by Actor Name'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 25),
            child: TextField(
              onChanged: (query) {
                if (query.isEmpty) {
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
                  // ... existing code ...
                } else {
                // Update the displayedMovies list based on the search query or actor name
                  if (searchMode == SearchMode.MovieTitle) {
                    // Search by movie title
                    searchMovies(query).then((searchResults) {
                      displayedMovies = searchResults.take(20).toList();
                      setState(() {
                        // Update the state with the search results
                        displayedMovies = displayedMovies;
                      });
                    });
                  } else {
                  // Search by actor name
                    if (query.length > 1) {
                      getMoviesByActor(query).then((searchResults) {
                        if (searchResults.isNotEmpty) {
                          // Update displayedMovies only if searchResults is not empty
                          displayedMovies = searchResults.take(20).toList();
                          setState(() {
                            // Update the state with the search results
                            displayedMovies = displayedMovies;
                          });
                        }
                      });
                    }
                  }
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
                          itemBuilder: (context, index) => CustomListTile(
                            height:200,
                            //contentPadding: EdgeInsets.only(left: 20, right: 20,top:0),
                            title: Text(
                              displayedMovies[index].title!,
                              style:
                              TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              '${displayedMovies[index].movieReleaseYear.toString()}',
                              style: TextStyle(
                                  color: Colors.grey.shade600
                              ),
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
                                width: 150,
                                height: double.infinity,
                                filterQuality: FilterQuality.high,
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


class CustomListTile extends StatelessWidget {
  final Widget? leading; // Optional leading widget
  final Text? title; // Required title text
  final Text? subtitle; // Optional subtitle text
  final Function? onTap; // Optional tap event handler
  // Optional double tap event handler
  final Widget? trailing; // Optional trailing widget
   // Optional tile background color
  final double? height; // Required height for the custom list tile

  // Constructor for the custom list tile
  const CustomListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.onTap,
    
    this.trailing,
    
    required this.height, // Make height required for clarity
  });

  @override
  Widget build(BuildContext context) {
    return Material( // Material design container for the list tile
      // Set background color if provided
      child: InkWell( // Tappable area with event handlers
        onTap: () => onTap!(), // Tap event handler
        
        child: SizedBox( // Constrain the size of the list tile
          height: height, // Set custom height from constructor
          child: Row( // Row layout for list item content
            children: [
              Padding( // Padding for the leading widget
                padding: const EdgeInsets.only(left: 12.0, right: 12.0,top:12,bottom: 12),
                child: leading, // Display leading widget
              ),
              Expanded( // Expanded section for title and subtitle
                child: Column( // Column layout for title and subtitle
                  crossAxisAlignment: CrossAxisAlignment.start, // Align text left
                  children: [
                    Padding(
                    padding: const EdgeInsets.only(left: 2.0, right: 12.0,top:50,bottom: 12),
                    child:title ?? const SizedBox(),
                    ), // Display title or empty space
                    const SizedBox(height: 10), // Spacing between title and subtitle
                    subtitle ?? const SizedBox(), // Display subtitle or empty space
                  ],
                ),
              ),
              Padding( // Padding for the trailing widget
                padding: const EdgeInsets.all(12.0),
                child: trailing, // Display trailing widget
              )
            ],
          ),
        ),
      ),
    );
  }
}