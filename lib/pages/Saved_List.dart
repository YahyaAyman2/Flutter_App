import 'package:flutter/material.dart';
import 'package:sakkeny_app/pages/HomePage.dart';
import 'package:sakkeny_app/pages/MessagesPage.dart';
import 'package:sakkeny_app/pages/profile.dart';

// --- CUSTOM COLORS AND THEME EXTENSION ---

// Define custom color palette based on the image provided
const Color primaryDarkGreen = Color(0xFF386B5D);
const Color secondaryLightGreen = Color(0xFF5D9D8E);
const Color linkColor = Color(0xFF386B5D);

// A ThemeExtension to hold custom properties (included for completeness)
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

// --- MAIN APPLICATION SETUP for testing the Saved Page ---
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
    const HomePage(),
    const HomePage(),
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
        // Using the defined primary color for the selected item
        selectedItemColor: primaryDarkGreen,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Necessary for 5 items
        backgroundColor: Colors.white,
      ),
    );
  }
}

// --- SAVED PAGE IMPLEMENTATION ---

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
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

              // Content Grid (The 4 squares)
              SizedBox(
                height:
                    250, 
                child: Row(
                  children: [
                    // Column for the two left items
                    Expanded(
                      child: Column(
                        children: [
                          // Top Left Item (Image)
                          Expanded(
                            child: _buildWishlistItem(
                              context,
                              imageUrl:
                                  'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&q=80', // Placeholder URL
                              isImage: true,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Bottom Left Item (Placeholder)
                          Expanded(child: _buildWishlistItem(context)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Column for the two right items
                    Expanded(
                      child: Column(
                        children: [
                          // Top Right Item (Placeholder)
                          Expanded(child: _buildWishlistItem(context)),
                          const SizedBox(height: 10),
                          // Bottom Right Item (Placeholder)
                          Expanded(child: _buildWishlistItem(context)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Recently viewed details
              const Text(
                'Recently viewed',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                '3 days ago',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              // Placeholder for the rest of the content (empty space)
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for a single saved grid item (image or placeholder)
  Widget _buildWishlistItem(
    BuildContext context, {
    String? imageUrl,
    bool isImage = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isImage
            ? Colors.transparent
            : Colors.grey.shade600,
        borderRadius: BorderRadius.circular(10),
      ),
      child: isImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                // Fallback in case the image fails to load
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade400,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image, color: Colors.white),
                ),
              ),
            )
          : null,
    );
  }
}