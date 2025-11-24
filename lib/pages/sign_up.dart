import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sakkeny_app/pages/Saved_List.dart';
import 'package:sakkeny_app/pages/sign_in.dart';

const Color primaryDarkGreen = Color(0xFF386B5D);
const Color secondaryLightGreen = Color(0xFF5D9D8E);
const Color linkColor = Color(0xFF386B5D);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignUpPage(),
    );
  }
}

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
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Processing Sign Up Data')));
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => Saved()));
    }
  }

  @override
  Widget build(BuildContext context) {
    // 2. تعريف الـ Theme الخاص بالصفحة دي هنا
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
                              keyboardType: TextInputType.name,
                            ),
                            _buildLabel(context, 'Last Name'),
                            _buildTextFormField(
                              context,
                              'Enter Your Last Name',
                              keyboardType: TextInputType.name,
                            ),
                            _buildLabel(context, 'Phone Number'),
                            _buildTextFormField(
                              context,
                              'Enter Phone Number',
                              keyboardType: TextInputType.phone,
                            ),

                            _buildLabel(context, 'Email'),
                            _buildTextFormField(
                              context,
                              'Enter Your Email',
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
                                  return "Incorrect password";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 30),

                            ElevatedButton(
                              onPressed: _submitForm,
                              child: const Text('Sign Up'),
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
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
