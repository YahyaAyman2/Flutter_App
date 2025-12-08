import 'package:flutter/material.dart';
import 'package:sakkeny_app/pages/Startup%20pages/Enter_OTP.dart';
// Minimal placeholder for the target screen to ensure the code runs

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // GlobalKey for FormState to manage form validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controller to access and manage the email field value
  final TextEditingController _emailController = TextEditingController();

  // Function to handle the "Send" button press: validation and navigation
  void _submitForm() {
    // 1. Validate the entire form
    if (_formKey.currentState!.validate()) {
      // If validation is successful:
      final email = _emailController.text;
      print('Sending reset link to: $email');

      // 2. Navigate to EnterOTPScreen after successful validation
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) =>  EnterOTPScreen()));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: Form(
        key: _formKey, // Link the key to the form
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Forgot Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Enter your email address associated with your account to receive a reset code.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Email Input (Using TextFormField for validation)
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required'; // 1. Check for empty field
                  }
                  if (!value.contains('@')) {
                    return 'Enter a valid email'; // 2. Check for @ symbol
                  }
                  return null; // Input is valid
                },
                decoration: InputDecoration(
                  hintText: 'owenlevi056@gmail.com',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Colors.grey,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none, // Remove default border
                  ),
                  errorBorder: OutlineInputBorder(
                    // Custom style for error border
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 10,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Send Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed:
                      _submitForm, // Call the validation and navigation function
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F7D63), // Teal Green
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Send',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Footer
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  // Using Row and TextButton
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Go Back To ',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Navigate back to sign-in
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero, // Remove default padding
                          minimumSize: Size.zero, // Minimal size
                          tapTargetSize: MaterialTapTargetSize
                              .shrinkWrap, // Shrink tap target area
                          alignment: Alignment.centerLeft,
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Color(0xFF0F7D63), // Teal Green
                            fontWeight: FontWeight.bold,
                            fontSize: 14, // Match surrounding text size
                          ),
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
  }
}