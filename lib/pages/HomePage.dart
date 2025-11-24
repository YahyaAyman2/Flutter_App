import 'package:flutter/material.dart';
import 'package:sakkeny_app/pages/FilterPage.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  // Data lists
  final List<String> _prices = const [
    '7,000',
    '8,000',
    '6,500',
    '5,900',
    '4,000',
    '9,000'
  ];

  final List<String> _titles = const [
    'Apartment for sale',
    'Fully Furnished',
    'Apartment for Rent',
    'Finished Apartment',
    'Panaromic sea view',
    'Golden Opportunity'
  ];

  final List<String> _locations = const [
    'Madinaty, Cairo',
    'Zamalek, Cairo',
    'Feryal, Assuit',
    'Gomhorya, Assuit',
    'Ras Soma, Red Sea',
    'Mountain View'
  ];

  final List<String> _images = const [
    'assets/images/p1.jpg',
    'assets/images/p2.jpg',
    'assets/images/p3.jpg',
    'assets/images/p4.jpg',
    'assets/images/p5.jpg',
    'assets/images/p6.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Section *****************************
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
                              Icon(Icons.keyboard_arrow_down),
                            ],
                          ),
                        ],
                      ),
                      const Icon(Icons.notifications_outlined, size: 28),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Search Bar (NEW WORKING TEXTFIELD) ***********************************
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              icon: Icon(Icons.search, color: Colors.grey),
                              border: InputBorder.none,
                              hintText: 'Search by city, street...',
                              hintStyle: TextStyle(color: Colors.grey),
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
                          icon: const Icon(Icons.filter_list, color: Colors.black), onPressed:() 
                          {  Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const FilterPage(),
                                        ),
                                      ); },
                          ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Recommended Header ***************************************
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
                      Text(
                        'See all',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF276152),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Property Grid ***************************************
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: _prices.length,
                itemBuilder: (context, index) {
                  return PropertyCard(
                    price: _prices[index],
                    title: _titles[index],
                    location: _locations[index],
                    imagePath: _images[index],
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
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'EGP$price /Month',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
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
                      fontWeight: FontWeight.bold),
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