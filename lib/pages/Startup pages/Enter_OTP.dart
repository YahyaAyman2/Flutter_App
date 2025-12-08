import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:sakkeny_app/pages/Startup%20pages/Reset_Pass.dart';


// Complete design and logic for the Enter OTP Screen
class EnterOTPScreen extends StatefulWidget {
  const EnterOTPScreen({super.key});

  @override
  State<EnterOTPScreen> createState() => _EnterOTPScreenState();
}

class _EnterOTPScreenState extends State<EnterOTPScreen> {
  // 1. OTP Controllers and Focus Nodes for the 4 digits
  final int _otpLength = 4;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  // 2. Timer Logic
  // FIX 1: Change 'late Timer' to 'Timer?' (nullable Timer) to safely check for initialization.
  Timer? _timer;
  int _countdownSeconds = 60; // Start countdown from 60 seconds
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers and focus nodes
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
    _startTimer();
  }

  @override
  void dispose() {
    // FIX 2: Cancel the timer only if it is not null
    _timer?.cancel(); 
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  // Starts or resets the countdown timer
  void _startTimer() {
    // FIX 3: Check if _timer is NOT null AND active before cancelling.
    if (mounted && _timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    
    setState(() {
      _countdownSeconds = 60; // Reset timer value
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        if (mounted) {
          setState(() {
            _countdownSeconds--;
          });
        }
      } else {
        // Since _timer is guaranteed not null here, we use !
        _timer!.cancel();
        if (mounted) {
          setState(() {
            _canResend = true;
          });
        }
      }
    });
  }

  // Handles resending the code
  void _resendCode() {
    if (_canResend) {
      print('Resending OTP code...');
      // TODO: Add actual API call to resend code
      _startTimer(); // Restart the timer
    }
  }

  // 3. Validation and Verification Logic
  void _verifyOTP() {
    String otp = _controllers.map((c) => c.text).join();
    
    // Check if the OTP is complete (4 digits)
    if (otp.length != _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete 4-digit code.')),
      );
      return;
    }

    // Validation passed (Digits are full, and input is restricted to numbers)
    print('Verifying OTP: $otp');
    // TODO: Add API call for verification and navigate to Reset Password Screen on success
    
    // NEW LOGIC: Navigate to Reset Password Screen after successful validation
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
    );
  }

  // Widget function to build a single OTP input box
  Widget _buildOTPBox(
    int index,
    TextEditingController controller,
    FocusNode currentFocusNode,
    FocusNode? nextFocusNode,
  ) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: TextFormField(
          controller: controller,
          focusNode: currentFocusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number, // Ensure numeric keyboard
          maxLength: 1,
          // Input Formatter to ensure only digits are entered
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          decoration: const InputDecoration(
            counterText: "", // Hides the character counter
            border: InputBorder.none,
          ),
          onChanged: (value) {
            // Auto-focus shift logic: if a digit is entered, move to the next field
            if (value.length == 1 && nextFocusNode != null) {
              nextFocusNode.requestFocus();
            } else if (value.isEmpty && index > 0) {
              // Optionally move back on backspace
              _focusNodes[index - 1].requestFocus();
            }
          },
        ),
      ),
    );
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Enter Your OTP',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'A 4-digit code has been sent to your email. Please enter it below.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 40),

            // OTP Input Row (Dynamically generated)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_otpLength, (index) {
                return _buildOTPBox(
                  index,
                  _controllers[index],
                  _focusNodes[index],
                  // Pass the next focus node, or null for the last box
                  index < _otpLength - 1 ? _focusNodes[index + 1] : null,
                );
              }),
            ),

            const SizedBox(height: 30),

            // Timer / Resend Logic
            _canResend
                ? TextButton(
                    onPressed: _resendCode,
                    child: const Text(
                      'Resend Code',
                      style: TextStyle(
                        color: Color(0xFF0F7D63), // Teal Green
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  )
                : RichText(
                    text: TextSpan(
                      text: 'Resend Code In ',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      children: [
                        TextSpan(
                          text: '$_countdownSeconds Sec', // Display live countdown
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

            const SizedBox(height: 30),

            // Verify Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _verifyOTP, // Call the validation and verification function
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F7D63), // Teal Green
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Verify',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}