import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/colors.dart';
import 'package:movie_app/constants.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/screens/login.dart';
import 'package:movie_app/widgets/back_button.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({
    Key? key,
    required this.movie,
  }) : super(key: key);

  final Movies movie;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: const backButton(),
            backgroundColor: Colours.scaffoldBgColor,
            expandedHeight: 500,
            pinned: true,
            floating: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                movie.title ?? 'Unnamed Movie',
                style: GoogleFonts.belleza(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              background: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: Image.network(
                  '${Constants.imageBaseUrl}${movie.backdropPath}',
                  filterQuality: FilterQuality.high,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overview',
                    style: GoogleFonts.openSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    movie.description,
                    style: GoogleFonts.roboto(
                      fontSize: 25,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Implement logic to mark the movie as watched
                      if (!movie.isMovieWatched(movie.movieID!.toInt())){
                      movie.markAsWatched(movie.movieID!);

                      addWatchedMovie(globalUserId!, movie.movieID.toString(),movie.title!,movie.posterPath!);
                      }
                      
                      // Add additional logic if needed
                    },
                    child: Text('Mark as Watched'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Release Year: ',
                              style: GoogleFonts.roboto(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              movie.movieReleaseYear.toString(),
                              style: GoogleFonts.roboto(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Rating: ',
                              style: GoogleFonts.roboto(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            Text(
                              '${movie.voteAvg?.toStringAsFixed(1)}/10',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Cast',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: movie.cast.length,
                      itemBuilder: (context, index) {
                        return _buildCastItem(movie.cast[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  void addWatchedMovie(String userId, String movieId,String movieTitle,String moviePoster) {
  // Reference to the user's document
  DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

  // Reference to the subcollection 'watchedMovies' within the user's document
  CollectionReference watchedMoviesRef = userDocRef.collection('watchedMovies');

  // Add a new document for the watched movie
  watchedMoviesRef.add({
    'movieId': movieId,
    'watchedAt': FieldValue.serverTimestamp(),
    'movieTitle':movieTitle,
    'moviePoster':moviePoster,
     // Optional: Store the timestamp
  });
  }
}

 Widget _buildCastItem(Cast actor) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(
              '${Constants.imageBaseUrl}${actor.profilePath}',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            actor.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            actor.character,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    
  }
