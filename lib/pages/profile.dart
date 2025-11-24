import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfileScreen(),
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
// Initial selected index for BottomNavigationBar



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 18.0),
          child: Column(
            children: [
              // Profile picture
              CircleAvatar(
                radius: 44,
                backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=3'), // Replace with your image URL
              ),
              SizedBox(height: 14),
              // Name Text
              Text(
                "Arlene McCoy",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87),
              ),
              SizedBox(height: 6),
              // HomeFinder Chip
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "HomeFinder",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Menu items
              Expanded(
                child: ListView(
                  children: [
                    buildMenuItem(
                      icon: Icons.person_outline,
                      text: "My Account",
                      iconColor: Colors.deepPurple[100]!,
                      onTap: () {},
                    ),
                    buildMenuItem(
                      icon: Icons.settings_outlined,
                      text: "Settings",
                      iconColor: Colors.deepPurple[100]!,
                      onTap: () {},
                    ),
                    buildMenuItem(
                      icon: Icons.apartment_outlined,
                      text: "Apartment",
                      iconColor: Colors.deepPurple[100]!,
                      onTap: () {},
                    ),
                    buildMenuItem(
                      icon: Icons.credit_card_outlined,
                      text: "My Payments",
                      iconColor: Colors.deepPurple[100]!,
                      onTap: () {},
                    ),
                    buildMenuItem(
                      icon: Icons.headset_mic_outlined,
                      text: "Support",
                      iconColor: Colors.deepPurple[100]!,
                      onTap: () {},
                    ),
                    buildMenuItem(
                      icon: Icons.logout,
                      text: "Logout",
                      iconColor: Colors.red,
                      textColor: Colors.red,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenuItem({
    required IconData icon,
    required String text,
    Color? iconColor,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor ?? Colors.black87,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}