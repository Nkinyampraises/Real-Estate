import 'package:flutter/material.dart';

class Property {
  final String id;
  final String name;
  final String location;
  final double price;
  final String imageUrl;

  Property({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.imageUrl,
  });
}

class PropertyListPage extends StatefulWidget {
  const PropertyListPage({super.key});

  @override
  State<PropertyListPage> createState() => _PropertyListPageState();
}

class _PropertyListPageState extends State<PropertyListPage> {
  late List<Property> properties;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    properties = _defaultProperties();
    _isLoading = false;
  }

  void _loadProperties() {
    setState(() {
      _isLoading = false;
      properties = _defaultProperties();
    });
  }

  List<Property> _defaultProperties() {
    return [
      Property(
        id: '1',
        name: 'Modern Apartment',
        location: 'Downtown',
        price: 250000,
        imageUrl: 'assets/property1.jpg',
      ),
      Property(
        id: '2',
        name: 'Luxury Villa',
        location: 'Hillside',
        price: 500000,
        imageUrl: 'assets/property2.jpg',
      ),
      Property(
        id: '3',
        name: 'Cozy House',
        location: 'Suburbs',
        price: 150000,
        imageUrl: 'assets/property3.jpg',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final property = properties[index];
                return PropertyCard(
                  property: property,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/property-detail',
                      arguments: property,
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadProperties,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              color: Colors.grey[300],
              child: Center(
                child: Text(
                  property.name,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.location,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${property.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
