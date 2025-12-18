import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sakkeny_app/pages/My%20Profile/MyListingsPage%20.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:sakkeny_app/pages/My Profile/MyAccount.dart';
import 'package:sakkeny_app/pages/My Profile/Settings.dart';
import 'package:sakkeny_app/pages/Startup pages/sign_in.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final fb_auth.User? user = fb_auth.FirebaseAuth.instance.currentUser;
  final supabase = Supabase.instance.client;

  String? _imageUrl;
  String? _name = "";
  String? _status = "HomeFinder"; // ثابتة زى كودك
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _imageUrl = user?.photoURL;
    _name = user?.email ?? "User"; // أو لو عندك اسم فى Firestore ممكن تجيبيه
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
      // We catch this silently because if it fails (e.g. permission issue),
      // we still want the Upload to proceed.
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

      await FirebaseFirestore.instance.collection('images').doc(user!.uid).set({
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
                _name ?? "User",
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
                      text: "My Listings", // ✅ NEW
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
                        await fb_auth.FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => SignIn()),
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
        trailing: Icon(
          Icons.keyboard_arrow_right,
          size: 22,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  final Color primary = Color(0xFF1B3C2E);
  final Color accent = Color(0xFF1B3C2E);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primary,
        title: Text("Notifications"),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildNotification(
            "Tour Booked Successfully",
            "Your house tour has been confirmed!",
            "1h ago",
            primary,
          ),
          _buildNotification(
            "Exclusive Offers Inside",
            "Check out new rental offers near you.",
            "1h ago",
            primary,
          ),
          _buildNotification(
            "Property Review Request",
            "Please leave a review for your recent visit.",
            "2h ago",
            primary,
          ),
          SizedBox(height: 10),
          Text("Yesterday", style: TextStyle(color: Colors.grey)),
          _buildNotification(
            "Tour Request Accepted",
            "The owner approved your tour request.",
            "1d ago",
            accent,
          ),
          _buildNotification(
            "New Payment Added",
            "Your new payment method is saved.",
            "1d ago",
            accent,
          ),
        ],
      ),
    );
  }

  Widget _buildNotification(
    String title,
    String subtitle,
    String time,
    Color iconColor,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: iconColor.withOpacity(0.2),
            child: Icon(Icons.notifications, color: iconColor),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          Text(time, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class SupportPage extends StatelessWidget {
  final Color primary = Color(0xFF1B3C2E);
  final Color accent = Color(0xFF1B3C2E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primary,
        title: Text("FAQ & Support"),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Text(
            "Didn’t find the answer you were looking for?",
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 10),

          _buildSupportItem(Icons.language, "Go to our Website"),
          _buildSupportItem(Icons.email_outlined, "Email Us"),
          _buildSupportItem(Icons.description_outlined, "Terms of Service"),

          SizedBox(height: 20),

          TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: primary),
              hintText: "Find question...",
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          SizedBox(height: 20),
          _buildFAQ(
            "How do I change my password?",
            "Go to menu → Profile → Change Password.",
          ),
          _buildFAQ(
            "How to change my profile status?",
            "Open Profile → Edit Status → Save.",
          ),
          _buildFAQ(
            "How to export contacts?",
            "Open Settings → Export → Choose format.",
          ),
        ],
      ),
    );
  }

  Widget _buildSupportItem(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon, color: accent),
      title: Text(text),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }

  Widget _buildFAQ(String q, String a) {
    return ExpansionTile(
      title: Text(q, style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: EdgeInsets.all(12),
          child: Text(a, style: TextStyle(color: Colors.black54)),
        ),
      ],
    );
  }
}
