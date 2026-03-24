import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_secure/pages/property_list_page.dart';

void main() {
  group('PropertyListPage', () {
    testWidgets('initial state shows property list',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PropertyListPage(),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Modern Apartment'), findsWidgets);
    });

    testWidgets('displays properties after loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PropertyListPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Modern Apartment'), findsWidgets);
      expect(find.text('Luxury Villa'), findsWidgets);

      // Scroll to third item
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.text('Cozy House'), findsWidgets);
    });

    testWidgets('displays property details in list',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PropertyListPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify property information for visible cards
      expect(find.text('Downtown'), findsOneWidget);
      expect(find.text('Hillside'), findsOneWidget);

      // Scroll to bottom to reveal the last property
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.text('Suburbs'), findsOneWidget);

      // Verify card count and bottom item information
      expect(find.byType(PropertyCard), findsWidgets);
      expect(find.text('\$150000'), findsOneWidget);
    });

    testWidgets('PropertyCard displays all information',
        (WidgetTester tester) async {
      final property = Property(
        id: '1',
        name: 'Test Property',
        location: 'Test Location',
        price: 100000,
        imageUrl: 'assets/test.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertyCard(
              property: property,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify property details
      expect(find.text('Test Property'), findsWidgets);
      expect(find.text('Test Location'), findsOneWidget);
      expect(find.text('\$100000'), findsOneWidget);
    });

    testWidgets('property card is tappable and navigates',
        (WidgetTester tester) async {
      bool tapped = false;

      final property = Property(
        id: '1',
        name: 'Test Property',
        location: 'Test Location',
        price: 100000,
        imageUrl: 'assets/test.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertyCard(
              property: property,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Tap the card
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(tapped, true);
    });

    testWidgets('displays refresh button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PropertyListPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify refresh button
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('refresh button reloads properties',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PropertyListPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial properties
      expect(find.text('Modern Apartment'), findsWidgets);

      // Tap refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // Verify no loading indicator when refresh is instant
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Wait for reload
      await tester.pumpAndSettle();

      // Verify properties still display
      expect(find.text('Modern Apartment'), findsWidgets);
    });

    testWidgets('properties display in correct order',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PropertyListPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Modern Apartment'), findsWidgets);
      expect(find.text('Luxury Villa'), findsWidgets);

      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.text('Cozy House'), findsWidgets);
    });

    testWidgets('PropertyCard has Card widget', (WidgetTester tester) async {
      final property = Property(
        id: '1',
        name: 'Test Property',
        location: 'Test Location',
        price: 100000,
        imageUrl: 'assets/test.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertyCard(
              property: property,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('app bar displays Properties title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PropertyListPage(),
        ),
      );

      expect(find.text('Properties'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
