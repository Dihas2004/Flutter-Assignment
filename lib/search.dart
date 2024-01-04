import 'package:flutter/material.dart';
import 'package:movie_app/models/movie.dart';

import 'dart:convert';
//import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/widgets/search_slider.dart'; // Add the http package



class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}


class _SearchPageState extends State<SearchPage> {
  late Future<List<Movies>> moviesList;
  TextEditingController searchController = TextEditingController();
  List<Movies> displayedMovies = [];
  

  @override
  void initState() {
    super.initState();
    moviesList = fetchAllMovies();
  }

  Future<List<Movies>> fetchAllMovies() async {
    List<Movies> allMovies = [];

    // Fetch all pages
    for (int page = 1; page <= 37; page++) {
      final response = await http.get(
          Uri.parse('https://api.themoviedb.org/3/movie/upcoming?api_key=c70ffdb8f341ef6671fac7cbbc1f09c6&page=$page'));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> movies = data['results'] ?? [];
        allMovies.addAll(movies.map((json) => Movies.fromJson(json)).toList());
        
      } else {
        throw Exception('Failed to load movies');
      }
    }
    
    
    

    // Set displayedMovies to the movies from the first page
    

    return allMovies;
  }

  List<Movies> updateList(List<Movies> allMovies, String query) {
    if (query.isEmpty) {
      return allMovies;
    }
    return allMovies.where((movie) {
      return movie.title?.toLowerCase().contains(query.toLowerCase()) ?? false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1f1545),
      appBar: AppBar(
        backgroundColor: Color(0xFF1f1545),
        elevation: 0.0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Search for a Movie",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            TextField(
              controller: searchController,
              style: TextStyle(color: Colors.white),
              onChanged: (query) {
                setState(() {
                  // Update the list whenever the text in the search bar changes
                  moviesList = fetchAllMovies();
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xff30260),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                hintText: "eg: The Dark Knight",
                prefixIcon: Icon(Icons.search),
                prefixIconColor: Colors.purple.shade900,
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Expanded(
              child: FutureBuilder<List<Movies>>(
                future: moviesList,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Movies> displayedMovies = updateList(snapshot.data!, searchController.text);
                    displayedMovies = displayedMovies.take(20).toList();
                    return ListView.builder(
                      itemCount: displayedMovies.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SearchSlider(
                            snapshot: AsyncSnapshot<List<Movies>>.withData(
                              ConnectionState.done,
                              [displayedMovies[index]],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.error.toString()),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
