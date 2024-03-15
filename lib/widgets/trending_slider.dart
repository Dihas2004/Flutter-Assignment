import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/constants.dart';
import 'package:movie_app/models/movie.dart';
import 'package:movie_app/screens/details_screen.dart';
import 'package:http/http.dart' as http;

class TrendingSlider extends StatelessWidget {
  const TrendingSlider({
    Key? key,
    required this.snapshot,
  }) : super(key: key);

  final AsyncSnapshot snapshot;

  Future<void> _fetchAdditionalDetails(int movieId) async {
    final response = await http.get(
      Uri.parse('https://api.themoviedb.org/3/movie/$movieId?api_key=${Constants.apiKey}'),
    );

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      // Use the decodedData to populate additional details
      // For example:
      // final int voteCount = decodedData['vote_count'];
      // final int revenue = decodedData['revenue'];
      // ...
    } else {
      throw Exception('Failed to fetch additional details. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CarouselSlider.builder(
        itemCount: snapshot.data!.length,
        options: CarouselOptions(
          height: 300,
          autoPlay: true,
          viewportFraction: 0.55,
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: true,
          pageSnapping: true,
          autoPlayAnimationDuration: const Duration(seconds: 1),
        ),
        itemBuilder: (context, itemIndex, pageViewIndex) {
          return GestureDetector(
            onTap: () async {
              final Movies selectedMovie = snapshot.data[itemIndex];
              try {
                await selectedMovie.fetchCredits(selectedMovie.movieID!);
                await _fetchAdditionalDetails(selectedMovie.movieID!);
              } catch (e) {
                print('Error fetching details: $e');
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsScreen(movie: selectedMovie),
                ),
              );
            },
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    '${Constants.imageBaseUrl}${snapshot.data[itemIndex].backdropPath}',
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.fitHeight,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text(
                      snapshot.data[itemIndex].title,
                      style: GoogleFonts.mulish(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
