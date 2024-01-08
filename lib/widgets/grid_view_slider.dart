import 'package:flutter/material.dart';
import 'package:movie_app/constants.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/details_screen.dart';


class grid_slider extends StatelessWidget {
  const grid_slider({
    super.key,
    required this.scrollController,
    required this.displayedMovies,
  });

  final ScrollController scrollController;
  final List<Movies> displayedMovies;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 2/3,
      ),
      controller: scrollController,
      padding: EdgeInsets.all(30.0),
      itemCount: displayedMovies.length,
      itemBuilder: (context, index) {
        return GestureDetector(
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              '${Constants.imageBaseUrl}${displayedMovies[index].posterPath}',
              filterQuality: FilterQuality.high,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}