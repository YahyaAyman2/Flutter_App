import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart'; // Added for SHA256 hashing

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rental App',
      theme: ThemeData(
        primaryColor: const Color(0xFF276152),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF276152),
          secondary: Color(0xFF276152),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF276152),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const MyAccountPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class UserData {
  String username;
  String email;
  String phoneNumber;
  String password;

  UserData({
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });
}

class MyAccountPage extends StatefulWidget {
  final UserData? userData;

  const MyAccountPage({Key? key, this.userData}) : super(key: key);

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  late String username;
  late String email;
  late String phoneNumber;
  late String hashedPassword;
  bool showPassword = false;
  
  

  @override
  void initState() {
    super.initState();
    username = widget.userData?.username ?? 'Gracia Tya';
    email = widget.userData?.email ?? 'gracia.tya@email.com';
    phoneNumber = widget.userData?.phoneNumber ?? '+1 234 567 8900';
    hashedPassword = _hashPassword(widget.userData?.password ?? 'password123');
  }

  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  void _editField(String fieldName, String currentValue, Function(String) onSave) {
    final TextEditingController controller = TextEditingController(text: currentValue);
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Edit $fieldName'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: fieldName,
            border: const OutlineInputBorder(),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF276152), width: 2),
            ),
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF276152),
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF276152),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _navigateToChangePassword() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ChangePasswordPage(
          currentHashedPassword: hashedPassword,
          onPasswordChanged: (String newPassword) {
            setState(() {
              hashedPassword = _hashPassword(newPassword);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF276152),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: const Text(
                'My Account',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: <Widget>[
                    const SizedBox(height: 20),
                    _buildAccountItem(
                      icon: Icons.person_outline,
                      title: 'Username',
                      value: username,
                      onTap: () => _editField('Username', username, (String value) {
                        setState(() => username = value);
                      }),
                    ),
                    const SizedBox(height: 15),
                    _buildAccountItem(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      value: email,
                      onTap: () => _editField('Email', email, (String value) {
                        setState(() => email = value);
                      }),
                    ),
                    const SizedBox(height: 15),
                    _buildAccountItem(
                      icon: Icons.phone_outlined,
                      title: 'Phone Number',
                      value: phoneNumber,
                      onTap: () => _editField('Phone Number', phoneNumber, (String value) {
                        setState(() => phoneNumber = value);
                      }),
                    ),
                    const SizedBox(height: 15),
                    _buildPasswordItem(),
                    const SizedBox(height: 15),
                    _buildAccountItem(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      value: '',
                      showArrow: true,
                      onTap: _navigateToChangePassword,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountItem({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
    bool showArrow = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF276152).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF276152),
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.isEmpty ? 'Tap to change' : value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              showArrow ? Icons.arrow_forward_ios : Icons.edit,
              color: Colors.grey[400],
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordItem() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF276152).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.lock_outline,
              color: Color(0xFF276152),
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  showPassword ? hashedPassword : '••••••••',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              showPassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[400],
            ),
            onPressed: () {
              setState(() {
                showPassword = !showPassword;
              });
            },
          ),
        ],
      ),
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  final String currentHashedPassword;
  final ValueChanged<String> onPasswordChanged;

  const ChangePasswordPage({
    super.key,
    required this.currentHashedPassword,
    required this.onPasswordChanged,
  });

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmNewPassword = true;

  String? _currentPasswordError;
  String? _newPasswordError;
  String? _confirmNewPasswordError;
  


  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  void _validateAndChangePassword() {
    setState(() {
      _currentPasswordError = null;
      _newPasswordError = null;
      _confirmNewPasswordError = null;
    });

    bool isValid = true;

    // Validate current password
    if (_currentPasswordController.text.isEmpty) {
      setState(() => _currentPasswordError = 'Current password cannot be empty');
      isValid = false;
    } else if (_hashPassword(_currentPasswordController.text) != widget.currentHashedPassword) {
      setState(() => _currentPasswordError = 'Incorrect current password');
      isValid = false;
    }

    // Validate new password
    if (_newPasswordController.text.isEmpty) {
      setState(() => _newPasswordError = 'New password cannot be empty');
      isValid = false;
    } else if (_newPasswordController.text.length < 6) {
      setState(() => _newPasswordError = 'Password must be at least 6 characters');
      isValid = false;
    }

    // Validate confirm new password
    if (_confirmNewPasswordController.text.isEmpty) {
      setState(() => _confirmNewPasswordError = 'Confirm password cannot be empty');
      isValid = false;
    } else if (_newPasswordController.text != _confirmNewPasswordController.text) {
      setState(() => _confirmNewPasswordError = 'Passwords do not match');
      isValid = false;
    }

    if (isValid) {
      widget.onPasswordChanged(_newPasswordController.text);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF276152),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Change Password'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    children: <Widget>[
                      const SizedBox(height: 20),
                      _buildPasswordField(
                        controller: _currentPasswordController,
                        labelText: 'Current Password',
                        obscureText: _obscureCurrentPassword,
                        errorText: _currentPasswordError,
                        toggleVisibility: () {
                          setState(() {
                            _obscureCurrentPassword = !_obscureCurrentPassword;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildPasswordField(
                        controller: _newPasswordController,
                        labelText: 'New Password',
                        obscureText: _obscureNewPassword,
                        errorText: _newPasswordError,
                        toggleVisibility: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildPasswordField(
                        controller: _confirmNewPasswordController,
                        labelText: 'Confirm New Password',
                        obscureText: _obscureConfirmNewPassword,
                        errorText: _confirmNewPasswordError,
                        toggleVisibility: () {
                          setState(() {
                            _obscureConfirmNewPassword = !_obscureConfirmNewPassword;
                          });
                        },
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _validateAndChangePassword,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: const Color(0xFF276152),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Change Password',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required bool obscureText,
    required VoidCallback toggleVisibility,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        errorText: errorText,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Color(0xFF276152), width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: toggleVisibility,
        ),
      ),
    );
  }
}

