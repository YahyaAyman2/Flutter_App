import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sakkeny_app/pages/Startup%20pages/sign_in.dart';
import 'package:sakkeny_app/pages/bottom_nav.dart';

const Color primaryDarkGreen = Color(0xFF386B5D);
const Color secondaryLightGreen = Color(0xFF5D9D8E);
const Color linkColor = Color(0xFF386B5D);

class CustomColors extends ThemeExtension<CustomColors> {
  final Color linkColor;
  const CustomColors({required this.linkColor});

  @override
  CustomColors copyWith({Color? linkColor}) {
    return CustomColors(linkColor: linkColor ?? this.linkColor);
  }

  @override
  CustomColors lerp(CustomColors? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(linkColor: Color.lerp(linkColor, other.linkColor, t)!);
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Add user details to Firestore after successful authentication
  Future<void> addUserDetails(String userId) async {
    await users.doc(userId).set({
      'first name': _firstNameController.text.trim(),
      'last name': _lastNameController.text.trim(),
      'phone number': _phoneNumberController.text.trim(),
      'email': _emailController.text.trim(),
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'userId': userId,
      'isVerified': false, // Set to false initially, can be updated after email verification
    });
  }

  // Integrated sign up function
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Step 1: Create user with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Step 2: Add user details to Firestore using the UID from Authentication
      await addUserDetails(userCredential.user!.uid);

      // Optional: Send email verification
      // await userCredential.user!.sendEmailVerification();

      // Step 3: Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Step 4: Navigate to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Navigation()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Something went wrong';

      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email format';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // Handle Firestore errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving user data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData localTheme = ThemeData(
      primaryColor: primaryDarkGreen,
      hintColor: primaryDarkGreen,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDarkGreen,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: primaryDarkGreen,
        ),
        bodyMedium: TextStyle(color: Colors.black87),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: secondaryLightGreen, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDarkGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      extensions: const <ThemeExtension<dynamic>>[
        CustomColors(linkColor: linkColor),
      ],
    );

    return Theme(
      data: localTheme,
      child: Builder(
        builder: (context) {
          final customColors = Theme.of(context).extension<CustomColors>();
          final currentLinkColor =
              customColors?.linkColor ?? const Color(0xFF386B5D);

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                        top: 40,
                        left: 30,
                        right: 30,
                        bottom: 40,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sign up',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Your journey starts here',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel(context, 'First Name'),
                            _buildTextFormField(
                              context,
                              'Enter Your First Name',
                              controller: _firstNameController,
                              keyboardType: TextInputType.name,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "First name is required";
                                }
                                return null;
                              },
                            ),
                            
                            _buildLabel(context, 'Last Name'),
                            _buildTextFormField(
                              context,
                              'Enter Your Last Name',
                              controller: _lastNameController,
                              keyboardType: TextInputType.name,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Last name is required";
                                }
                                return null;
                              },
                            ),
                            
                            _buildLabel(context, 'Phone Number'),
                            _buildTextFormField(
                              context,
                              'Enter Phone Number',
                              controller: _phoneNumberController,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Phone number is required";
                                }
                                if (value.length != 11) {
                                  return "Phone number must be 11 digits";
                                }
                                return null;
                              },
                              maxlength: 11,
                            ),

                            _buildLabel(context, 'Email'),
                            _buildTextFormField(
                              context,
                              'Enter Your Email',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Email is required";
                                }
                                if (!value.contains('@')) {
                                  return "Enter a valid email";
                                }
                                return null;
                              },
                            ),

                            _buildLabel(context, 'Password'),
                            _buildTextFormField(
                              context,
                              'Enter Your Password',
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Password is required";
                                }
                                if (value.length < 6) {
                                  return "Password must be at least 6 characters";
                                }
                                return null;
                              },
                            ),

                            _buildLabel(context, 'Confirm Password'),
                            _buildTextFormField(
                              context,
                              'Enter Confirm Password',
                              controller: _confirmPasswordController,
                              obscureText: !_isConfirmPasswordVisible,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Confirm Password is required";
                                }
                                if (value != _passwordController.text) {
                                  return "Passwords do not match";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 30),

                            ElevatedButton(
                              onPressed: _isLoading ? null : _submitForm,
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text('Sign Up'),
                            ),

                            const SizedBox(height: 20),
                            const Center(
                              child: Text(
                                'Or Register with',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            const SizedBox(height: 15),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const FaIcon(
                                    FontAwesomeIcons.apple,
                                    size: 40,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    print("Apple login tapped");
                                  },
                                ),
                                const SizedBox(width: 25),
                                IconButton(
                                  icon: const FaIcon(
                                    FontAwesomeIcons.google,
                                    size: 40,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    print("Google login tapped");
                                  },
                                ),
                                const SizedBox(width: 25),
                                IconButton(
                                  icon: const FaIcon(
                                    FontAwesomeIcons.facebookF,
                                    size: 40,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    print("Facebook login tapped");
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 25),

                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Already have an account? ',
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const SignIn(),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Log in',
                                      style: TextStyle(
                                        color: currentLinkColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 15.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildTextFormField(
    BuildContext context,
    String hintText, {
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    int? maxlength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxlength,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        counter: const Offstage(),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        suffixIcon: suffixIcon,
        border: Theme.of(context).inputDecorationTheme.enabledBorder,
        enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
        focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
      ),
    );
  }
}