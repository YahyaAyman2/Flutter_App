import 'package:flutter/material.dart';
import 'package:sakkeny_app/models/cards.dart';
import 'package:sakkeny_app/pages/AddApartmentPage.dart';
import 'package:sakkeny_app/pages/FilterPage.dart';
import 'package:sakkeny_app/pages/My%20Profile/profile.dart';
import 'package:sakkeny_app/pages/SearchPage.dart';
import 'package:sakkeny_app/pages/property.dart';

class HomePage extends StatelessWidget {
  final List<PropertyModel> _properties = [
    PropertyModel(
      price: "7,000",
      title: "Apartment for Sale",
      location: "Madinaty, Cairo, Egypt",
      image: "assets/images/p1.jpg",
      description:
          "Modern apartment surrounded by green spaces, great investment opportunity.",
      isWifi: true,
      Livingroom: 2,
      bedroom: 3,
      bathroom: 2,
      balcony: 1,
      kitchen: 1,
      rating: 4.6,
      reviews: 315,
    ),
    PropertyModel(
      price: "8,000",
      title: "Fully Furnished Apartment",
      location: "Zamalek, Cairo, Egypt",
      image: "assets/images/p2.jpg",
      description:
          "Luxury apartment with modern furniture near the Nile and all services.",
      isWifi: true,
      Livingroom: 1,
      bedroom: 2,
      bathroom: 1,
      balcony: 2,
      kitchen: 1,
      rating: 4.8,
      reviews: 427,
    ),
    PropertyModel(
      price: "6,500",
      title: "Apartment for Rent",
      location: "Feryal Street, Assiut, Egypt",
      image: "assets/images/p3.jpg",
      description:
          "Quiet location, suitable for families or university students.",
      isWifi: false,
      Livingroom: 1,
      bedroom: 3,
      bathroom: 1,
      balcony: 1,
      kitchen: 1,
      rating: 4.2,
      reviews: 142,
    ),
    PropertyModel(
      price: "5,900",
      title: "Finished Apartment",
      location: "Gomhorya, Assiut, Egypt",
      image: "assets/images/p4.jpg",
      description: "Fully finished and ready to move in, near transportation.",
      isWifi: false,
      Livingroom: 2,
      bedroom: 2,
      bathroom: 1,
      balcony: 0,
      kitchen: 1,
      rating: 4.0,
      reviews: 88,
    ),
    PropertyModel(
      price: "4,000",
      title: "Panoramic Sea View Chalet",
      location: "Ras Soma, Red Sea, Egypt",
      image: "assets/images/p5.jpg",
      description: "Chalet with direct sea view, great for vacation rentals.",
      isWifi: true,
      Livingroom: 1,
      bedroom: 2,
      bathroom: 2,
      balcony: 3,
      kitchen: 1,
      rating: 4.9,
      reviews: 765,
    ),
    PropertyModel(
      price: "9,000",
      title: "Luxury Villa",
      location: "Mountain View, New Cairo, Egypt",
      image: "assets/images/p6.jpg",
      description:
          "Premium compound villa with landscape view and private parking.",
      isWifi: true,
      Livingroom: 3,
      bedroom: 4,
      bathroom: 3,
      balcony: 2,
      kitchen: 2,
      rating: 4.7,
      reviews: 540,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF276152),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddApartmentPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: const [
                              Icon(Icons.location_on, color: Color(0xFF276152)),
                              SizedBox(width: 4),
                              Text(
                                'Feryal Street , Assuit',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.keyboard_arrow_down, size: 20),
                                onPressed: List.empty,
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_none, size: 28),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationsPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ✅ FIXED Search Bar - Now navigates to PropertySearchPage
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Navigate to search page
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    PropertySearchPage(properties: _properties),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: Colors.grey[600]),
                                const SizedBox(width: 12),
                                Text(
                                  'Search by city, street...',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF2F2F2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.filter_list,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const FilterPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Recommended Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Recommended Property',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: List.empty,
                        child: Text(
                          'See All',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF276152),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ✅ FIXED Property Grid - Added missing PropertyCard widget
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: _properties.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PropertyDetailsPage(
                            price: _properties[index].price,
                            title: _properties[index].title,
                            location: _properties[index].location,
                            image: _properties[index].image,
                            description: _properties[index].description,
                            isWifi: _properties[index].isWifi,
                            Livingroom: _properties[index].Livingroom,
                            bedroom: _properties[index].bedroom,
                            bathroom: _properties[index].bathroom,
                            balcony: _properties[index].balcony,
                            kitchen: _properties[index].kitchen,
                            rating: _properties[index].rating,
                            reviews: _properties[index].reviews,
                          ),
                        ),
                      );
                    },
                    // ✅ ADDED: The missing child widget!
                    child: PropertyCard(
                      price: _properties[index].price,
                      title: _properties[index].title,
                      location: _properties[index].location,
                      imagePath: _properties[index].image,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------
// PROPERTY CARD WIDGET
// --------------------------------------

class PropertyCard extends StatelessWidget {
  final String price;
  final String title;
  final String location;
  final String imagePath;

  const PropertyCard({
    Key? key,
    required this.price,
    required this.title,
    required this.location,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'EGP$price /Month',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  location,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
