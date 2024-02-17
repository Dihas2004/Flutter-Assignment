// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:movie_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';



void main() {
  testWidgets('Mock Data', (WidgetTester tester) async {
    // Create a test widget with mock data
    await tester.pumpWidget(
      MaterialApp(
        home: MyApp(
          // Provide mock data for testing
          trendingMovies: Future.value([]),
          topRatedMovies: Future.value([]),
          grossingMovies: Future.value([]),
          childrenMovies: Future.value([]),
          actionChildrenMovies: Future.value([]),
          romanticChildrenMovies: Future.value([]),
        ),
      ),
    );

    
    // ...

    // Example: Verify that a widget with text '0' is present
    expect(find.text('0'), findsOneWidget);

    // Example: Trigger a tap and pump to verify changes
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that your expected changes have occurred
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}

