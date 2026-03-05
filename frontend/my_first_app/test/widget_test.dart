import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_app/main.dart';

void main() {
  testWidgets('KidCloud UI loads test', (WidgetTester tester) async {

    // Build the KidCloud app
    await tester.pumpWidget(const KidCloudApp());

    // Check if title text appears
    expect(find.text('KIDCLOUD'), findsOneWidget);

  });
}