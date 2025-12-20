import 'package:flutter/material.dart';
import 'package:sakkeny_app/models/cards.dart';
import 'package:sakkeny_app/pages/HomePage.dart';
import 'package:sakkeny_app/pages/MessagesPage.dart';
import 'package:sakkeny_app/pages/My%20Profile/profile.dart';
import 'package:sakkeny_app/pages/Saved_List.dart';
import 'package:sakkeny_app/pages/SearchPage.dart';

class Navigation extends StatefulWidget {
  @override
  State<Navigation> createState() => _navigation();
}

class _navigation extends State<Navigation> {
  int _selectedIndex = 0;
  List<PropertyModel> _allProperties = [];
  void _onItemTapped(int index) {

    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> get _pages => [
    HomePage(),
    PropertySearchPage(properties: _allProperties),
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
        selectedItemColor: Color(0xFF276152), // Changed to #276152
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Necessary for 5 items
        backgroundColor: Colors.white,
      ),
    );
  }
}