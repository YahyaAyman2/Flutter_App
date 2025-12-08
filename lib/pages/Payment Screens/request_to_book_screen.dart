import 'package:flutter/material.dart';
import 'booking_status_screen.dart';

class RequestToBookScreen extends StatelessWidget {
  final String cardNumber;
  final String expiry;
  final String cvv;
  final String postcode;
  final String country;

  const RequestToBookScreen({
    Key? key,
    required this.cardNumber,
    required this.expiry,
    required this.cvv,
    required this.postcode,
    required this.country,
  }) : super(key: key);

  bool _validateBooking() {
    // Validation logic for booking
    // Card number must start with 4 or 5 (Visa/Mastercard)
    if (!cardNumber.startsWith('4') && !cardNumber.startsWith('5')) {
      return false;
    }

    // Check expiry date is not in the past
    final parts = expiry.split('/');
    if (parts.length == 2) {
      final month = int.tryParse(parts[0]);
      final year = int.tryParse(parts[1]);
      
      if (month != null && year != null) {
        final now = DateTime.now();
        final currentYear = now.year % 100; // Get last 2 digits
        final currentMonth = now.month;
        
        if (year < currentYear || (year == currentYear && month < currentMonth)) {
          return false;
        }
      }
    }

    // CVV must be exactly 3 digits
    if (cvv.length != 3 || int.tryParse(cvv) == null) {
      return false;
    }

    // Postcode must not be empty
    if (postcode.isEmpty) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Request to book',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                    'assets/images/p1.jpg',
                    width: 90,
                      height: 90,
                    fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Apartement for sale',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            const Text('4.92 (101)', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Dates Section
            _buildInfoSection(
              context,
              'Dates',
              '12–14 Dec 2025',
              showBadge: true,
              badgeText: 'Rare find',
            ),
            const SizedBox(height: 16),

            // Guests Section
            _buildInfoSection(context, 'Guests', '2 adult'),
            const SizedBox(height: 16),

            // Total Price Section
            _buildInfoSection(context, 'Total price', 'EGP 7000', showDetails: true),
            const SizedBox(height: 24),

            // Payment Method
            _buildNavigationTile(
              context,
              'Payment method',
              'Credit Card ending in ${cardNumber.substring(cardNumber.length - 4)}',
              Icons.payment,
              () {},
            ),
            const SizedBox(height: 16),

            // Price Details
            const Text(
              'Price details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildPriceRow('2 nights x EGP 3500', 'EGP 7000'),
            const Divider(height: 24),
            _buildPriceRow('Total ', 'EGP 7000', isBold: true),
            const SizedBox(height: 8),
            const Text(
              'Price breakdown',
              style: TextStyle(
                fontSize: 14,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            // Confirmation Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'The host has 24 hours to confirm your booking. You will be charged after the request has been accepted.',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 24),

            // Request to Book Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  // Validate booking with actual conditions
                  final bool isSuccess = _validateBooking();
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingStatusScreen(isSuccess: isSuccess),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF276152),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Request to book',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                  children: [
                    TextSpan(text: 'By selecting the button, I agree to the '),
                    TextSpan(
                      text: 'booking terms',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    String value, {
    bool showBadge = false,
    String badgeText = '',
    bool showDetails = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (showBadge) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.local_fire_department, size: 16, color: Color(0xFF276152)),
                    Text(
                      badgeText,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF276152)),
                    ),
                  ],
                ],
              ),
            ],
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              showDetails ? 'Details' : 'Change',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF276152),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 14)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}