import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/api/api.dart';
import 'package:movie_app/colors.dart';
import 'package:movie_app/constants.dart';
import 'package:movie_app/models/actor.dart';
import 'package:movie_app/models/movie.dart';
//import 'package:movie_app/screens/login.dart';
import 'package:movie_app/widgets/back_button.dart';
import 'package:movie_app/widgets/cast_widget.dart';
import 'package:movie_app/widgets/play_button.dart';
import 'package:movie_app/widgets/rating_year_scroll.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({
    Key? key,
    required this.movie,
  }) : super(key: key);

  final Movies movie;

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late bool isMovieWatched = false;
  late bool isMovieWatchList = false;
  String? trailerKey;

  @override
  void initState() {
    super.initState();
    checkIfMovieIsWatched();
    checkIfMovieListIsWatched();
    API().getMovieTrailerKey(widget.movie.movieID!).then((key) {
    setState(() {
      trailerKey = key;
    });
  });
  }

  Future<void> checkIfMovieIsWatched() async {
    String userId = await getUserIDFromSharedPreferences();
    bool watched = await isMovieIdAlreadyExists(userId, widget.movie.movieID.toString());
    setState(() {
      isMovieWatched = watched;
      //print(isMovieWatched);
    });
  }

  Future<void> checkIfMovieListIsWatched() async {
    String userId = await getUserIDFromSharedPreferences();
    bool watched = await isMovieIdAlreadyExistsWatchList(userId, widget.movie.movieID.toString());
    setState(() {
      isMovieWatchList = watched;
      //print(isMovieWatched);
    });
  }

  

  Future<String> getUserIDFromSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_id') ?? 'h9cF4PP4oHKqwfLqgaaV';
}

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
            flexibleSpace: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Image.network(
                    '${Constants.imageBaseUrl}${widget.movie.backdropPath}',
                    filterQuality: FilterQuality.high,
                    fit: BoxFit.cover,
                  ),
                ),
                // Title at the Bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black.withOpacity(0.7), // Adjust opacity and color
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      widget.movie.title ?? 'Unnamed Movie',
                      style: GoogleFonts.belleza(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
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
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.movie.description,
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  




                  const SizedBox(height: 16),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          buildInfoContainer('Release Year: ', widget.movie.movieReleaseYear.toString()),
                          SizedBox(width: 16), // Add spacing between Release Year and Rating
                          buildInfoContainer('Rating: ', '${widget.movie.voteAvg?.toStringAsFixed(1)}/10'),
                        ],
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Watched Icon (Eye icon)
                      Column(
                        children: [
                          InkWell(
                            onTap: () async {
                              String userId = await getUserIDFromSharedPreferences();
                              //print(isMovieWatched);
                              if (isMovieWatched==true) {
                                // If the movie is already watched, remove it from Firestore
                                await removeFromWatchedMovies(userId, widget.movie.movieID.toString());
                              } else {
                                // If the movie is not watched, mark it as watched and add to Firestore
                                widget.movie.markAsWatched(widget.movie.movieID!);
                                addWatchedMovie(userId, widget.movie.movieID.toString(), widget.movie.title!, widget.movie.posterPath!,widget.movie.movieReleaseYear!,widget.movie.voteAvg!);
                              }

                              // Update the watched state

                              //checkIfMovieIsWatched();
                              setState(() {
                                isMovieWatched = !isMovieWatched;
                              });
                            },
                            child: Ink(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: isMovieWatched ? Colors.white.withOpacity(0.5) : Colors.transparent,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.check, 
                                  color: isMovieWatched ? Colors.white : Colors.grey,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            isMovieWatched ? 'Remove from My List' : 'My List',
                            style: TextStyle(
                              color: isMovieWatched ? Colors.white : Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      
                      Column(
                        children: [
                          PlayButton(trailerUrl: 'https://www.youtube.com/watch?v=$trailerKey'),
                          Text(
                            'Play',
                            style: TextStyle(
                              color: isMovieWatched ? Colors.white : Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      
                      Column(
                        children: [
                          InkWell(
                            onTap: () async {
                              String userId = await getUserIDFromSharedPreferences();
                              //print(isMovieWatched);
                              if (isMovieWatchList==true) {
                                // If the movie is already watched, remove it from Firestore
                                await removeFromWatchListMovies(userId, widget.movie.movieID.toString());
                              } else {
                                // If the movie is not watched, mark it as watched and add to Firestore
                                widget.movie.markAsWatchList(widget.movie.movieID!);
                                addWatchListMovie(userId, widget.movie.movieID.toString(), widget.movie.title!, widget.movie.posterPath!,widget.movie.movieReleaseYear!,widget.movie.voteAvg!);
                              }

                              // Update the watched state

                              //checkIfMovieIsWatched();
                              setState(() {
                                isMovieWatchList = !isMovieWatchList;
                              });
                            },
                            child: Ink(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: isMovieWatchList ? Colors.white.withOpacity(0.5) : Colors.transparent,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.bookmark, 
                                  color: isMovieWatchList ? Colors.white : Colors.grey,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            isMovieWatchList ? 'Remove from Watch List' : 'Watch List',
                            style: TextStyle(
                              color: isMovieWatchList ? Colors.white : Colors.grey,
                            ),
                          ),
                        ],
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
                      itemCount: widget.movie.cast.length,
                      itemBuilder: (context, index) {
                        return buildCastItem(widget.movie.cast[index]);
                      },
                    ),
                  ),
                  _buildCommonMovieText(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  // void addWatchedMovie(String userId, String movieId,String movieTitle,String moviePoster) {
  // // Reference to the user's document
  // DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

  // // Reference to the subcollection 'watchedMovies' within the user's document
  // CollectionReference watchedMoviesRef = userDocRef.collection('watchedMovies');

  // // Add a new document for the watched movie
  // watchedMoviesRef.add({
  //   'movieId': movieId,
  //   'watchedAt': FieldValue.serverTimestamp(),
  //   'movieTitle':movieTitle,
  //   'moviePoster':moviePoster,
  //    // Optional: Store the timestamp
  // });
  // }
  Future<bool> isMovieIdAlreadyExists(String userId, String movieId) async {
  // Reference to the user's document
  DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

  // Reference to the subcollection 'watchedMovies' within the user's document
  CollectionReference watchedMoviesRef = userDocRef.collection('watchedMovies');

  // Check if a document with the specified movieId exists
  QuerySnapshot existingMovies = await watchedMoviesRef.where('movieId', isEqualTo: movieId).get();

  // Return true if there are existing documents with the same movieId, otherwise false
  return existingMovies.docs.isNotEmpty;
}

Future<void> addWatchedMovie(String userId, String movieId, String movieTitle, String moviePoster , String releaseDate , double voteAvg) async {
  bool isMovieIdExists = await isMovieIdAlreadyExists(userId, movieId);

  // Reference to the user's document
  DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

  // Reference to the subcollection 'watchedMovies' within the user's document
  CollectionReference watchedMoviesRef = userDocRef.collection('watchedMovies');

  if (!isMovieIdExists) {
    // Add a new document for the watched movie only if the movieId doesn't exist
    watchedMoviesRef.add({
      'movieId': movieId,
      'watchedAt': FieldValue.serverTimestamp(),
      'movieTitle': movieTitle,
      'moviePoster': moviePoster,
      'voteAvg' : voteAvg,
      'releaseDate':releaseDate
    });
  } else {
    // Handle the case where the movieId already exists (optional)
    print('Movie with ID $movieId already exists in the watched movies collection.');
  }
}

Future<void> removeFromWatchedMovies(String userId, String movieId) async {
  // Reference to the user's document
  DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

  // Reference to the subcollection 'watchedMovies' within the user's document
  CollectionReference watchedMoviesRef = userDocRef.collection('watchedMovies');

  // Find the document with the specified movieId
  QuerySnapshot movieQuery = await watchedMoviesRef.where('movieId', isEqualTo: movieId).get();

  // Delete the document if it exists
  movieQuery.docs.forEach((doc) {
    doc.reference.delete();
  });
}


  Future<bool> isMovieIdAlreadyExistsWatchList(String userId, String movieId) async {
  // Reference to the user's document
  DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

  // Reference to the subcollection 'watchedMovies' within the user's document
  CollectionReference watchedMoviesRef = userDocRef.collection('watchListMovies');

  // Check if a document with the specified movieId exists
  QuerySnapshot existingMovies = await watchedMoviesRef.where('movieId', isEqualTo: movieId).get();

  // Return true if there are existing documents with the same movieId, otherwise false
  return existingMovies.docs.isNotEmpty;
}

Future<void> addWatchListMovie(String userId, String movieId, String movieTitle, String moviePoster, String releaseDate , double voteAvg) async {
  bool isMovieIdExists = await isMovieIdAlreadyExists(userId, movieId);

  // Reference to the user's document
  DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

  // Reference to the subcollection 'watchedMovies' within the user's document
  CollectionReference watchedMoviesRef = userDocRef.collection('watchListMovies');

  if (!isMovieIdExists) {
    // Add a new document for the watched movie only if the movieId doesn't exist
    watchedMoviesRef.add({
      'movieId': movieId,
      'watchedAt': FieldValue.serverTimestamp(),
      'movieTitle': movieTitle,
      'moviePoster': moviePoster,
      'voteAvg' : voteAvg,
      'releaseDate':releaseDate
    });
  } else {
    // Handle the case where the movieId already exists (optional)
    print('Movie with ID $movieId already exists in the watched movies collection.');
  }
}

Future<void> removeFromWatchListMovies(String userId, String movieId) async {
  // Reference to the user's document
  DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

  // Reference to the subcollection 'watchedMovies' within the user's document
  CollectionReference watchedMoviesRef = userDocRef.collection('watchListMovies');

  // Find the document with the specified movieId
  QuerySnapshot movieQuery = await watchedMoviesRef.where('movieId', isEqualTo: movieId).get();

  // Delete the document if it exists
  movieQuery.docs.forEach((doc) {
    doc.reference.delete();
  });
}

Future<int> _generateRandomActorIdInRange(int start, int end) async {
  final response = await http.get(
    Uri.parse('https://api.themoviedb.org/3/person/popular?api_key=${Constants.apiKey}&page=1'),
  );

  if (response.statusCode == 200) {
    final decodedData = json.decode(response.body);
    final List<dynamic> actors = decodedData['results'];
    if (actors.isNotEmpty) {
      int randomIndex = Random().nextInt(actors.length);
      return actors[randomIndex]['id'];
    } else {
      throw Exception('No actors found');
    }
  } else {
    throw Exception('Failed to generate random actor ID. Status code: ${response.statusCode}');
  }
}

Future<List<dynamic>> _fetchMoviesWithCommonCast() async {
  int randomActorId;
  List<dynamic> result;

  while (true) {
    randomActorId = await _generateRandomActorIdInRange(0, 100000);
    final url =
        'https://api.themoviedb.org/3/discover/movie?with_cast=${widget.movie.cast.first.id},$randomActorId&sort_by=release_date.desc&api_key=${Constants.apiKey}&page=1';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      final List<Movies> movies = (decodedData['results'] as List)
          .map((movieData) => Movies.fromJson(movieData))
          .toList();

      // Check if the fetched movies list is not empty and return it
      if (movies.isNotEmpty) {
        print(movies);
        result = [movies, randomActorId];
        break;
      }
    } else {
      print('Failed to fetch movies for actor ID $randomActorId');
    }
  }

  return result;
}







Widget _buildCommonMovieText() {
  return FutureBuilder<List<dynamic>>(
    future: _fetchMoviesWithCommonCast(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Container(); // Display an empty container while loading
      } else if (snapshot.hasError) {
        return Text('Error fetching common movies'); // Display error message
      } else if (snapshot.hasData) {
        List<Movies> movies = snapshot.data![0];

        // Display the common movie names
        return Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Did you know?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildNamesAndMoviesLine(snapshot.data![1], widget.movie.cast.first.name, movies),
          ],
        );
      } else {
        return Container(); // Display an empty container if there are no common movies
      }
    },
  );
}

Widget _buildNamesAndMoviesLine(int randomActorId, String firstActorName, List<Movies> movies) {
  return Container(
    // Your design implementation goes here
    child: FutureBuilder<Actor?>(
      future: API().getActorDetailsById(randomActorId),
      builder: (context, actorSnapshot) {
        if (actorSnapshot.connectionState == ConnectionState.waiting) {
          return Container(); // Display an empty container while loading actor details
        } else if (actorSnapshot.hasError) {
          return Text('Error fetching random actor details'); // Display error message
        } else if (actorSnapshot.hasData) {
          Actor? randomActor = actorSnapshot.data;
          return Text(
            '$firstActorName and ${randomActor?.name ?? 'Unknown Actor'} have starred in the movies ${movies.map((movie) => movie.title ?? '').join(', ')} together.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          );
        } else {
          return Container(); // Display an empty container if there are no actor details
        }
      },
    ),
  );
}




}
