import 'package:flutter/material.dart';
import 'package:sakkeny_app/pages/HomePage.dart';
import 'package:sakkeny_app/pages/MessagesPage.dart';
import 'package:sakkeny_app/pages/My%20Profile/profile.dart';
import 'package:sakkeny_app/pages/property.dart';

const Color primaryDarkGreen = Color(0xFF386B5D);
const Color linkColor = Color(0xFF386B5D);

// --- CUSTOM COLORS AND THEME EXTENSION ---
class _CustomColors extends ThemeExtension<_CustomColors> {
  final Color linkColor;
  const _CustomColors({required this.linkColor});

  @override
  _CustomColors copyWith({Color? linkColor}) {
    return _CustomColors(linkColor: linkColor ?? this.linkColor);
  }

  @override
  _CustomColors lerp(_CustomColors? other, double t) {
    if (other is! _CustomColors) return this;
    return _CustomColors(linkColor: Color.lerp(linkColor, other.linkColor, t)!);
  }
}

// --- MAIN APPLICATION SETUP  ---
void main() {
  runApp(const Saved());
}

class Saved extends StatelessWidget {
  const Saved({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saved UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryDarkGreen,
        hintColor: primaryDarkGreen,
        fontFamily: 'Roboto',
        extensions: const <ThemeExtension<dynamic>>[
          _CustomColors(linkColor: linkColor),
        ],
      ),
      home: const MainScreenSaved(),
    );
  }
}

// --- SCREEN CONTAINER with Bottom Navigation Bar ---
class MainScreenSaved extends StatefulWidget {
  const MainScreenSaved({super.key});

  @override
  State<MainScreenSaved> createState() => _MainScreenSavedState();
}

class _MainScreenSavedState extends State<MainScreenSaved> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    HomePage(),
    HomePage(),
    const SavedPage(),
    const MessagesPage(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Saved',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryDarkGreen,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
      ),
    );
  }
}


// --- SAVED PAGE IMPLEMENTATION  ---

final List<Map<String, dynamic>> staticSavedProperties = [
  {
    'id': 's1',
    'title': 'Modern Apartment',
    'location': 'Cairo, Nasr City',
    'price': '15,000',
    'image': 'assets/images/p1.jpg', 
    'description': 'A beautiful, fully furnished apartment ready for rent.',
    'isWifi': true,
    'Livingroom': 1,
    'bedroom': 2,
    'bathroom': 1,
    'balcony': 1,
    'kitchen': 1,
    'rating': 4.5,
    'reviews': 50,
  },
  {
    'id': 's2',
    'title': 'Luxury Penthouse',
    'location': 'New Cairo, 5th Sett.',
    'price': '50,000',
    'image': 'assets/images/p2.jpg', 
    'description': 'Luxury unit with panoramic city view and private terrace.',
    'isWifi': true,
    'Livingroom': 2,
    'bedroom': 3,
    'bathroom': 3,
    'balcony': 1,
    'kitchen': 1,
    'rating': 4.9,
    'reviews': 120,
  },
  {
    'id': 's3',
    'title': 'Cozy Studio',
    'location': 'Maadi, Degla',
    'price': '8,000',
    'image': 'assets/images/p3.jpg', 
    'description': 'Small but cozy studio apartment perfect for students.',
    'isWifi': false,
    'Livingroom': 1,
    'bedroom': 1,
    'bathroom': 1,
    'balcony': 0,
    'kitchen': 1,
    'rating': 3.8,
    'reviews': 30,
  },
  {
    'id': 's4',
    'title': 'Family Home',
    'location': '6th of October',
    'price': '22,000',
    'image': 'assets/images/p4.jpg', 
    'description': 'A large family home with a garden in a secure compound.',
    'isWifi': true,
    'Livingroom': 1,
    'bedroom': 4,
    'bathroom': 2,
    'balcony': 2,
    'kitchen': 1,
    'rating': 4.7,
    'reviews': 88,
  },
];


class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mySavedList = staticSavedProperties;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Saved',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: mySavedList.isEmpty
                    ? Center(
                        child: Text(
                          "No saved properties yet.",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                        ),
                      )
                    : GridView.builder(
                        itemCount: mySavedList.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, 
                          childAspectRatio: 0.75, 
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                        ),
                        itemBuilder: (context, index) {
                          final propertyData = mySavedList[index];
                          
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PropertyDetailsPage(
                                    price: propertyData['price']!,
                                    title: propertyData['title']!,
                                    location: propertyData['location']!,
                                    image: propertyData['image']!, 
                                    description: propertyData['description']!,
                                    isWifi: propertyData['isWifi']!,
                                    Livingroom: propertyData['Livingroom']!,
                                    bedroom: propertyData['bedroom']!,
                                    bathroom: propertyData['bathroom']!,
                                    balcony: propertyData['balcony']!,
                                    kitchen: propertyData['kitchen']!,
                                    rating: propertyData['rating']!.toDouble(),
                                    reviews: propertyData['reviews']!,
                                  ),
                                ),
                              );
                            },
                            child: _buildSavedItemCard(propertyData),
                          );
                        },
                      ),
              ),
              
              const SizedBox(height: 15),

              // Recently viewed details (Remain as is)
              const Text(
                'Recently viewed',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                '3 days ago',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for a single saved grid item
  Widget _buildSavedItemCard(Map<String, dynamic> propertyData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.asset(
                propertyData['image']!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade300,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image, size: 40),
                ),
              ),
            ),
          ),
          
          // المعلومات تحت الصورة
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  propertyData['title']!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${propertyData['price']!} EGP',
                  style: const TextStyle(
                    color: Color(0xFF386B5D),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Colors.grey),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        propertyData['location']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}