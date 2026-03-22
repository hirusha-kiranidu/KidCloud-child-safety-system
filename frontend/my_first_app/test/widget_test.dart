import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_app/main.dart';

void main() {

  testWidgets('App loads and shows splash screen', (WidgetTester tester) async {

    // Build the app
    await tester.pumpWidget(const MyApp());

    // Check if SplashScreen UI appears
    expect(find.text('Kid'), findsOneWidget);
    expect(find.text('Cloud'), findsOneWidget);
  });


  testWidgets('Splash screen navigates to onboarding', (WidgetTester tester) async {

    await tester.pumpWidget(const MyApp());

    // wait for splash delay animation
    await tester.pump(const Duration(seconds: 3));

    // Onboarding screen should appear
    expect(find.text('Real-Time GPS Tracking'), findsOneWidget);
  });


  testWidgets('Next button moves onboarding screen', (WidgetTester tester) async {

    await tester.pumpWidget(const MyApp());

    // Wait for splash
    await tester.pump(const Duration(seconds: 3));

    // Tap next
    await tester.tap(find.text('Next →'));
    await tester.pumpAndSettle();

    // Second onboarding screen should appear
    expect(find.text('Safe Zone Alerts'), findsOneWidget);
  });

}



