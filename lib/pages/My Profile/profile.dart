import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sakkeny_app/pages/My%20Profile/MyListingsPage%20.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:sakkeny_app/pages/My Profile/MyAccount.dart';
import 'package:sakkeny_app/pages/My Profile/Settings.dart';
import 'package:sakkeny_app/pages/My Profile/NotificationsPage.dart';
import 'package:sakkeny_app/pages/My Profile/SupportPage.dart';
import 'package:sakkeny_app/pages/Startup pages/sign_in.dart';
import 'package:sakkeny_app/pages/Saved_List.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final fb_auth.User? user = fb_auth.FirebaseAuth.instance.currentUser;
  final supabase = Supabase.instance.client;

  String? _imageUrl;
  String? _name = "";
  String? _lastname = "";
  String? _status = "HomeFinder";
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _imageUrl = user?.photoURL;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _name = data?['first name'] ?? "User";
          _lastname = data?['last name'] ?? "";
          _imageUrl = data?['profile_image'] ?? user!.photoURL;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _deleteOldProfileImage() async {
    try {
      if (user?.uid == null) return;

      final possibleFiles = [
        '${user!.uid}.jpg',
        '${user!.uid}.jpeg',
        '${user!.uid}.png',
        '${user!.uid}.webp',
      ];

      await supabase.storage.from('profile-images').remove(possibleFiles);
      debugPrint('Old profile images cleanup attempt finished.');
    } catch (e) {
      debugPrint('Note: Cleanup warning: $e');
    }
  }

  Future<void> _uploadProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (image == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      await _deleteOldProfileImage();

      final bytes = await image.readAsBytes();
      final ext = image.name.split('.').last;
      final fileName = '${user!.uid}.$ext';

      await supabase.storage
          .from('profile-images')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(upsert: true, contentType: 'image/$ext'),
          );

      final url = supabase.storage
          .from('profile-images')
          .getPublicUrl(fileName);

      final finalUrl = '$url?v=${DateTime.now().millisecondsSinceEpoch}';

      if (user != null) {
        await user!.updatePhotoURL(finalUrl);
      }

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'profile_image': finalUrl,
        'email': user!.email,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        setState(() {
          _imageUrl = finalUrl;
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Profile picture updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        debugPrint('Upload Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 18),
          child: Column(
            children: [
              GestureDetector(
                onTap: _isUploading ? null : _uploadProfileImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundImage: _imageUrl != null
                          ? NetworkImage(_imageUrl!)
                          : null,
                      child: _imageUrl == null
                          ? Icon(Icons.person, size: 50, color: Colors.grey)
                          : null,
                    ),
                    if (_isUploading)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 14),
              Text(
                '$_name $_lastname',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 6),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _status!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: 30),

              // MENU SECTION
              Expanded(
                child: ListView(
                  children: [
                    buildMenuItem(
                      icon: Icons.home_work_outlined,
                      text: "My Listings",
                      iconColor: Colors.grey,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyListingsPage(),
                          ),
                        );
                      },
                    ),
                    buildMenuItem(
                      icon: Icons.apartment_outlined,
                      text: "Booked Apartments",
                      iconColor: Colors.grey,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SavedPage(),
                          ),
                        );
                      },
                    ),
                    buildMenuItem(
                      icon: Icons.person_outline,
                      text: "My Account",
                      iconColor: Colors.grey,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => MyAccountPage()),
                        );
                      },
                    ),
                    buildMenuItem(
                      icon: Icons.notifications_outlined,
                      text: "Notifications",
                      iconColor: Colors.grey,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NotificationsPage(),
                          ),
                        );
                      },
                    ),
                    buildMenuItem(
                      icon: Icons.headset_mic_outlined,
                      text: "Support",
                      iconColor: Colors.grey,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SupportPage()),
                        );
                      },
                    ),
                    buildMenuItem(
                      icon: Icons.settings_outlined,
                      text: "Settings",
                      iconColor: Colors.grey,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SettingsPage()),
                        );
                      },
                    ),
                    buildMenuItem(
                      icon: Icons.logout,
                      text: "Logout",
                      iconColor: Colors.red,
                      textColor: Colors.red,
                      onTap: () async {
                        // Sign out from Firebase
                        await fb_auth.FirebaseAuth.instance.signOut();
                        
                        // Navigate to sign in page
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => SignIn()),
                          (route) => false, // Remove all previous routes
                        );
                      },
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
      color: Colors.white,
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
        trailing: const Icon(
          Icons.keyboard_arrow_right,
          size: 22,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}