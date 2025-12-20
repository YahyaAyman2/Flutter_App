import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  final Color primary = Color(0xFF276152);
  final Color accent = Color(0xFF276152);

  // Launch email
  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'saknniapp@gmail.com',
      query: 'subject=Support Request&body=Hello Saknni Support Team,',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch email';
    }
  }

  // Launch website
  Future<void> _launchWebsite() async {
    final Uri url = Uri.parse('https://www.saknniapp.com');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch website';
    }
  }

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
            "Didn't find the answer you were looking for?",
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 10),

          _buildSupportItem(
            Icons.language,
            "Go to our Website",
            onTap: _launchWebsite,
          ),
          _buildSupportItem(
            Icons.email_outlined,
            "Email Us",
            onTap: _launchEmail,
          ),
          _buildSupportItem(
            Icons.description_outlined,
            "Terms of Service",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TermsOfServicePage(),
                ),
              );
            },
          ),

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

  Widget _buildSupportItem(IconData icon, String text, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: accent),
      title: Text(text),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
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

class TermsOfServicePage extends StatelessWidget {
  final Color primary = Color(0xFF276152);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primary,
        title: Text("Terms of Service"),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Terms of Service",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Last Updated: December 20, 2025",
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 20),

            _buildSection(
              "1. Acceptance of Terms",
              "By accessing and using Saknni App, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.",
            ),

            _buildSection(
              "2. Use License",
              "Permission is granted to temporarily download one copy of Saknni App for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:\n\n• Modify or copy the materials\n• Use the materials for any commercial purpose\n• Attempt to decompile or reverse engineer any software contained in Saknni App\n• Remove any copyright or other proprietary notations from the materials\n• Transfer the materials to another person or mirror the materials on any other server",
            ),

            _buildSection(
              "3. User Accounts",
              "When you create an account with us, you must provide information that is accurate, complete, and current at all times. Failure to do so constitutes a breach of the Terms, which may result in immediate termination of your account on our Service.\n\nYou are responsible for safeguarding the password that you use to access the Service and for any activities or actions under your password.",
            ),

            _buildSection(
              "4. Property Listings",
              "Users who post property listings must ensure that:\n\n• All information provided is accurate and up-to-date\n• They have the legal right to list the property\n• Images and descriptions are truthful representations\n• Pricing information is correct\n\nSaknni reserves the right to remove any listing that violates these terms or is deemed inappropriate.",
            ),

            _buildSection(
              "5. Privacy Policy",
              "Your use of Saknni App is also governed by our Privacy Policy. Please review our Privacy Policy, which also governs the Site and informs users of our data collection practices.",
            ),

            _buildSection(
              "6. Prohibited Activities",
              "You may not access or use the Site for any purpose other than that for which we make the Site available. The Site may not be used in connection with any commercial endeavors except those that are specifically endorsed or approved by us.\n\nProhibited activities include but are not limited to:\n\n• Systematic retrieval of data to create a collection\n• Unauthorized framing or linking to the Site\n• Deceptive or fraudulent conduct\n• Harassment or abuse of other users\n• Uploading viruses or malicious code",
            ),

            _buildSection(
              "7. Intellectual Property",
              "The Service and its original content (excluding Content provided by users), features and functionality are and will remain the exclusive property of Saknni and its licensors. The Service is protected by copyright, trademark, and other laws of both the country and foreign countries.",
            ),

            _buildSection(
              "8. Termination",
              "We may terminate or suspend your account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.\n\nUpon termination, your right to use the Service will immediately cease. If you wish to terminate your account, you may simply discontinue using the Service.",
            ),

            _buildSection(
              "9. Limitation of Liability",
              "In no event shall Saknni, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from your access to or use of or inability to access or use the Service.",
            ),

            _buildSection(
              "10. Disclaimer",
              "Your use of the Service is at your sole risk. The Service is provided on an AS IS and AS AVAILABLE basis. The Service is provided without warranties of any kind, whether express or implied, including, but not limited to, implied warranties of merchantability, fitness for a particular purpose, non-infringement or course of performance.",
            ),

            _buildSection(
              "11. Governing Law",
              "These Terms shall be governed and construed in accordance with the laws of your country, without regard to its conflict of law provisions.\n\nOur failure to enforce any right or provision of these Terms will not be considered a waiver of those rights.",
            ),

            _buildSection(
              "12. Changes to Terms",
              "We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material we will try to provide at least 30 days notice prior to any new terms taking effect.\n\nWhat constitutes a material change will be determined at our sole discretion.",
            ),

            _buildSection(
              "13. Contact Us",
              "If you have any questions about these Terms, please contact us at:\n\nEmail: saknniapp@gmail.com",
            ),

            SizedBox(height: 30),
            Center(
              child: Text(
                "© 2025 Saknni App. All rights reserved.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}