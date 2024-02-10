import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/constants.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/screens/details_screen.dart';

class TrendingSlider extends StatelessWidget {
  const TrendingSlider({
    super.key, required this.snapshot,
  });

  final AsyncSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CarouselSlider.builder(
        itemCount: snapshot.data!.length,
        options: CarouselOptions(
          height:300,
          autoPlay: true,
          viewportFraction: 0.55,
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: true,
          pageSnapping: true,
          autoPlayAnimationDuration: const Duration(seconds:1 ),
              
        ),
        itemBuilder:(context,itemIndex,pageViewIndex){
          return GestureDetector(
            onTap: () async {
                    final Movies selectedMovie = snapshot.data[itemIndex];
                    //print('Selected Movie ID: ${selectedMovie.movieID}');
                    try {
                      await selectedMovie.fetchCredits(selectedMovie.movieID!);
                      //print('Fetched credits successfully');
                    } catch (e) {
                    //print('Error fetching credits: $e');
                    }
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsScreen(movie: selectedMovie),
                      ),
                    );
                  },

            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height:300,
                width:200,
                child: Image.network(
                  filterQuality: FilterQuality.high,
                  fit: BoxFit.cover,
                  '${Constants.imageBaseUrl}${snapshot.data[itemIndex].posterPath}',
            
                ),
              ),
            ),
          );
        },
      ),
        
    );
  }
}

