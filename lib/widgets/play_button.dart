import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PlayButton extends StatelessWidget {
  final String trailerUrl;

  const PlayButton({required this.trailerUrl});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.play_circle_fill),
      onPressed: () {
        _launchURL(trailerUrl);
      },
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
