import 'dart:convert';

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/constants.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/screens/details_screen.dart';

class WatchedMoviesWidget extends StatelessWidget {
  final String userId;

  WatchedMoviesWidget({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('watchedMovies')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var watchedMovies = snapshot.data!.docs;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: watchedMovies.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:  Text(
                    'Watched Movies',
                    style: GoogleFonts.aBeeZee(
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: watchedMovies.isNotEmpty,
                child: SizedBox(
                  height: 230,
                  width: double.infinity,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: watchedMovies.length,
                    itemBuilder: (context, index) {
                      var movieData =
                          watchedMovies[index].data() as Map<String, dynamic>;
                      int movieId = int.parse(movieData['movieId']);
                      String posterPath = movieData['moviePoster'];

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () async {
                            try {
                              final response = await http.get(
                                Uri.parse(
                                    'https://api.themoviedb.org/3/movie/$movieId?api_key=${Constants.apiKey}'),
                              );

                              if (response.statusCode == 200) {
                                final decodedData = json.decode(response.body);

                                Movies selectedMovie =
                                    Movies.fromJson(decodedData);
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
                                    'Failed to fetch movie details. Status code: ${response.statusCode}, Response body: ${response.body}');
                                throw Exception(
                                    'Failed to fetch movie details');
                              }
                            } catch (e) {
                              print('Error fetching movie details: $e');
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              height: 220,
                              width: 150,
                              child: Image.network(
                                filterQuality: FilterQuality.high,
                                fit: BoxFit.cover,
                                posterPath,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
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
    );
  }
}
