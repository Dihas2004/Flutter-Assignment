import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/constants.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/screens/details_screen.dart';
import 'package:movie_app/screens/search.dart';

class WatchListMovies extends StatelessWidget {
  final String userId;

  WatchListMovies({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Watch List Movies'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('watchListMovies')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var watchedMovies = snapshot.data!.docs;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Visibility(
                    visible: watchedMovies.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Watch List',
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ),
                  if (watchedMovies.isNotEmpty)
                    Column(
                      children: watchedMovies.map((watchedMovie) {
                        var movieData =
                            watchedMovie.data() as Map<String, dynamic>;
                        int movieId = int.parse(movieData['movieId']);
                        String posterPath = movieData['moviePoster'];
                        String title = movieData['movieTitle'];
                        String releaseDate = movieData['releaseDate']; // assuming it's stored as a String
                        double voteAvg = movieData['voteAvg'] ?? 0.0;

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            child: CustomListTile(

                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  posterPath,
                                  filterQuality: FilterQuality.high,
                                  fit: BoxFit.cover,
                                  height: double.infinity,
                                  width: 150,
                                ),
                              ),
                              subtitle: Text(
                              '$releaseDate',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            trailing: Text(
                              '$voteAvg',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 128, 123, 23)
                              ),
                            ),
                              title: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () async {
                                try {
                                  final response = await http.get(
                                    Uri.parse(
                                      'https://api.themoviedb.org/3/movie/$movieId?api_key=${Constants.apiKey}',
                                    ),
                                  );

                                  if (response.statusCode == 200) {
                                    final decodedData = json.decode(response.body);

                                    Movies selectedMovie = Movies.fromJson(decodedData);
                                    await selectedMovie.fetchCredits(movieId);

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailsScreen(
                                          movie: selectedMovie,
                                        ),
                                      ),
                                    );
                                  } else {
                                    print(
                                      'Failed to fetch movie details. Status code: ${response.statusCode}, Response body: ${response.body}',
                                    );
                                    throw Exception('Failed to fetch movie details');
                                  }
                                } catch (e) {
                                  print('Error fetching movie details: $e');
                                }
                              },
                              height: 230,
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Watch list is empty',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}


