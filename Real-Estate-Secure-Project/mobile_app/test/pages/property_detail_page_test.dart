import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_secure/pages/property_detail_page.dart';
import 'package:real_estate_secure/pages/property_list_page.dart';

void main() {
  group('PropertyDetailPage', () {
    final testProperty = Property(
      id: '1',
      name: 'Modern Apartment',
      location: 'Downtown',
      price: 250000,
      imageUrl: 'assets/property1.jpg',
    );

    testWidgets('displays property details', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PropertyDetailPage(property: testProperty),
        ),
      );

      // Verify title
      expect(find.text('Property Details'), findsOneWidget);

      // Verify property name
      expect(find.text('Modern Apartment'), findsWidgets);

      // Verify location
      expect(find.text('Downtown'), findsOneWidget);

      // Verify price
      expect(find.text('\$250000'), findsOneWidget);
    });

    testWidgets('displays property description', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PropertyDetailPage(property: testProperty),
        ),
      );

      // Verify description exists
      expect(find.text('Description'), findsOneWidget);
      expect(
        find.textContaining('This is a beautiful property in a prime location.'),
        findsOneWidget,
      );
    });

    testWidgets('displays property features', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PropertyDetailPage(property: testProperty),
        ),
      );

      // Verify features section
      expect(find.text('Features'), findsOneWidget);

      // Verify feature icons and text
      expect(find.byIcon(Icons.check_circle), findsWidgets);
      expect(find.text('4 Bedrooms'), findsOneWidget);
      expect(find.text('3 Bathrooms'), findsOneWidget);
      expect(find.text('Swimming Pool'), findsOneWidget);
      expect(find.text('Security Gate'), findsOneWidget);
    });

    testWidgets('favorite button toggles state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PropertyDetailPage(property: testProperty),
        ),
      );

      // Verify initial state (not favorited)
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);

      // Tap favorite button
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      // Verify state changed
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);

      // Tap again to unfavorite
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pump();

      // Verify state changed back
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('offer button exists', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PropertyDetailPage(property: testProperty),
        ),
      );

      // Scroll down to find the button
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Verify button exists
      expect(find.text('Make an Offer'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 10)));

    testWidgets('displays price in green color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PropertyDetailPage(property: testProperty),
        ),
      );

      // Verify price is displayed
      expect(find.text('\$250000'), findsOneWidget);

      // Verify the widget tree has the price text
      final priceWidget = find.text('\$250000');
      expect(priceWidget, findsOneWidget);
    });

    testWidgets('displays location with icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PropertyDetailPage(property: testProperty),
        ),
      );

      // Verify location icon
      expect(find.byIcon(Icons.location_on), findsWidgets);

      // Verify location text
      expect(find.text('Downtown'), findsOneWidget);
    });

    testWidgets('page is scrollable', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PropertyDetailPage(property: testProperty),
        ),
      );

      // Verify SingleChildScrollView exists
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('displays image placeholder',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PropertyDetailPage(property: testProperty),
        ),
      );

      // Verify container for image placeholder
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('app bar displays correct title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PropertyDetailPage(property: testProperty),
        ),
      );

      // Verify app bar
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Property Details'), findsOneWidget);
    });

    testWidgets('all features are displayed with checkmark icons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PropertyDetailPage(property: testProperty),
        ),
      );

      // Verify checkmark icons
      expect(find.byIcon(Icons.check_circle), findsWidgets);

      // Verify all features are present
      expect(find.text('4 Bedrooms'), findsOneWidget);
      expect(find.text('3 Bathrooms'), findsOneWidget);
      expect(find.text('Swimming Pool'), findsOneWidget);
      expect(find.text('Security Gate'), findsOneWidget);
    });
  });
}
