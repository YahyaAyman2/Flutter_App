import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sakkeny_app/models/cards.dart';
import 'package:sakkeny_app/services/payment_service.dart';
import 'package:sakkeny_app/services/property_service.dart';
import 'booking_status_screen.dart';

class RequestToBookScreen extends StatefulWidget {
  final PropertyModel property;
  final DateTime moveInDate;
  final int rentalMonths;
  final int adults;
  final int children;
  final double totalPrice;
  final String cardNumber;
  final String cardHolder;
  final String expiry;
  final String cvv;
  final String postcode;
  final String country;

  const RequestToBookScreen({
    Key? key,
    required this.property,
    required this.moveInDate,
    required this.rentalMonths,
    required this.adults,
    required this.children,
    required this.totalPrice,
    required this.cardNumber,
    required this.cardHolder,
    required this.expiry,
    required this.cvv,
    required this.postcode,
    required this.country,
  }) : super(key: key);

  @override
  State<RequestToBookScreen> createState() => _RequestToBookScreenState();
}

class _RequestToBookScreenState extends State<RequestToBookScreen> {
  bool _isProcessing = false;
  bool _agreedToTerms = false;
  final PaymentService _paymentService = PaymentService();
  final PropertyService _propertyService = PropertyService();

  // ✅ Calculate base monthly rent
  double get baseMonthlyRent => widget.property.price;

  // ✅ Calculate fees (percentage-based)
  double get cleaningFeePercent => 5.0; // 5%
  double get serviceFeePercent => 3.0; // 3%
  
  double get cleaningFee => (baseMonthlyRent * cleaningFeePercent) / 100;
  double get serviceFee => (baseMonthlyRent * serviceFeePercent) / 100;

  // ✅ Calculate base price
  double get basePrice => baseMonthlyRent * widget.rentalMonths;

  // ✅ Format move-in date
  String get moveInDateText {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${widget.moveInDate.day} ${months[widget.moveInDate.month - 1]} ${widget.moveInDate.year}';
  }

  // ✅ Format guests
  String get guestsText {
    if (widget.children == 0) {
      return '${widget.adults} adult${widget.adults > 1 ? 's' : ''}';
    }
    return '${widget.adults} adult${widget.adults > 1 ? 's' : ''}, ${widget.children} child${widget.children > 1 ? 'ren' : ''}';
  }

  // ✅ Get last 4 digits of card
  String get maskedCardNumber {
    String cleanNumber = widget.cardNumber.replaceAll(' ', '');
    if (cleanNumber.length >= 4) {
      return cleanNumber.substring(cleanNumber.length - 4);
    }
    return cleanNumber;
  }

  // ✅ Validate booking
  bool _validateBooking() {
    String cleanNumber = widget.cardNumber.replaceAll(' ', '');
    
    // Card number must start with 4 or 5 (Visa/Mastercard)
    if (!cleanNumber.startsWith('4') && !cleanNumber.startsWith('5')) {
      return false;
    }

    // Check expiry date is not in the past
    final parts = widget.expiry.split('/');
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
    if (widget.cvv.length != 3 || int.tryParse(widget.cvv) == null) {
      return false;
    }

    // Postcode must not be empty
    if (widget.postcode.isEmpty) {
      return false;
    }

    return true;
  }

  // ✅ Create booking in Firestore
  Future<bool> _createBooking() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // First, book the property (update status to rented)
      DateTime endDate = widget.moveInDate.add(Duration(days: widget.rentalMonths * 30)); // Approximate
      bool booked = await _propertyService.bookProperty(
        widget.property.propertyId,
        startDate: widget.moveInDate,
        endDate: endDate,
      );

      if (!booked) {
        throw Exception('Failed to book property - it may no longer be available');
      }

      // Create booking document
      final bookingRef = await FirebaseFirestore.instance.collection('bookings').add({
        // Property info
        'propertyId': widget.property.propertyId,
        'propertyTitle': widget.property.title,
        'propertyImage': widget.property.mainImage,
        'propertyLocation': widget.property.location.fullAddress,
        'ownerId': widget.property.userId,
        'ownerName': widget.property.userName,
        
        // User info
        'userId': user.uid,
        'userEmail': user.email,
        
        // Rental details
        'moveInDate': Timestamp.fromDate(widget.moveInDate),
        'rentalMonths': widget.rentalMonths,
        'adults': widget.adults,
        'children': widget.children,
        
        // Pricing
        'monthlyRent': baseMonthlyRent,
        'basePrice': basePrice,
        'cleaningFee': cleaningFee,
        'cleaningFeePercent': cleaningFeePercent,
        'serviceFee': serviceFee,
        'serviceFeePercent': serviceFeePercent,
        'totalPrice': widget.totalPrice,
        
        // Payment info (last 4 digits only)
        'cardLastFour': maskedCardNumber,
        'cardHolder': widget.cardHolder,
        
        // Status
        'status': 'confirmed', // Changed from pending to confirmed since we booked it
        'paymentStatus': 'paid', // Assuming payment succeeded
        
        // Timestamps
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create payment record
      final paymentDetails = {
        'cardNumber': widget.cardNumber.replaceAll(' ', '').substring(widget.cardNumber.replaceAll(' ', '').length - 4),
        'cardType': widget.cardNumber.startsWith('4') ? 'Visa' : (widget.cardNumber.startsWith('5') ? 'Mastercard' : 'Unknown'),
        'cardHolder': widget.cardHolder,
        'expiry': widget.expiry,
        'cvv': widget.cvv,
        'country': widget.country,
        'postcode': widget.postcode,
      };

      await _paymentService.createPayment(
        propertyId: widget.property.propertyId,
        bookingId: bookingRef.id,
        amount: widget.totalPrice,
        currency: 'EGP',
        paymentMethod: 'card',
        paymentDetails: paymentDetails,
      );

      return true;
    } catch (e) {
      print('Error creating booking: $e');
      return false;
    }
  }

  // ✅ Process booking request
  Future<void> _requestToBook() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please agree to the booking terms'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Validate booking
      final isValid = _validateBooking();
      
      if (!isValid) {
        setState(() => _isProcessing = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BookingStatusScreen(isSuccess: false),
          ),
        );
        return;
      }

      // Create booking in Firestore
      final bookingCreated = await _createBooking();

      setState(() => _isProcessing = false);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingStatusScreen(isSuccess: bookingCreated),
          ),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ DYNAMIC Property Card
                  _buildPropertyCard(),
                  const SizedBox(height: 24),

                  // ✅ DYNAMIC Move-in Date Section
                  _buildInfoSection(
                    context,
                    'Move-in date',
                    moveInDateText,
                    showBadge: false,
                  ),
                  const SizedBox(height: 16),

                  // ✅ DYNAMIC Rental Period
                  _buildInfoSection(
                    context,
                    'Rental period',
                    '${widget.rentalMonths} month${widget.rentalMonths > 1 ? 's' : ''}',
                  ),
                  const SizedBox(height: 16),

                  // ✅ DYNAMIC Guests Section
                  _buildInfoSection(context, 'Guests', guestsText),
                  const SizedBox(height: 16),

                  // ✅ DYNAMIC Total Price Section
                  _buildInfoSection(
                    context,
                    'Total price',
                    'EGP ${widget.totalPrice.toStringAsFixed(0)}',
                    showDetails: true,
                  ),
                  const SizedBox(height: 24),

                  // ✅ DYNAMIC Payment Method
                  _buildNavigationTile(
                    context,
                    'Payment method',
                    'Credit Card ending in $maskedCardNumber',
                    Icons.payment,
                    () {
                      // Navigate back to payment screen
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 24),

                  // ✅ DYNAMIC Price Details
                  _buildPriceDetails(),
                  
                  const SizedBox(height: 24),

                  // ✅ Confirmation Info
                  _buildConfirmationInfo(),
                  
                  const SizedBox(height: 24),

                  // ✅ Terms Checkbox
                  _buildTermsCheckbox(),
                ],
              ),
            ),
          ),

          // ✅ Bottom Bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ✅ Dynamic Property Card
  Widget _buildPropertyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.property.mainImage,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.property.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.property.location.area,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [

                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF276152).withOpacity(0.1),
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
    );
  }

  // ✅ Info Section
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    if (showBadge) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Color(0xFF276152),
                      ),
                      Text(
                        badgeText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF276152),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (!showDetails)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Change',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF276152),
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          else
            TextButton(
              onPressed: () {
                _showPriceBreakdownDialog();
              },
              child: const Text(
                'Details',
                style: TextStyle(
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

  // ✅ Navigation Tile
  Widget _buildNavigationTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: const Color(0xFF276152)),
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
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ✅ Price Details Section
  Widget _buildPriceDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildPriceRow(
          'Monthly rent x ${widget.rentalMonths} month${widget.rentalMonths > 1 ? 's' : ''}',
          'EGP ${basePrice.toStringAsFixed(0)}',
        ),
        _buildPriceRow(
          'Cleaning fee (${cleaningFeePercent.toStringAsFixed(0)}%)',
          'EGP ${cleaningFee.toStringAsFixed(0)}',
        ),
        _buildPriceRow(
          'Service fee (${serviceFeePercent.toStringAsFixed(0)}%)',
          'EGP ${serviceFee.toStringAsFixed(0)}',
        ),
        const Divider(height: 24),
        _buildPriceRow(
          'Total (EGP)',
          'EGP ${widget.totalPrice.toStringAsFixed(0)}',
          isBold: true,
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                color: isBold ? Colors.black : Colors.grey[700],
              ),
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

  // ✅ Confirmation Info
  Widget _buildConfirmationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'The host has 24 hours to confirm your booking. You will be charged after the request has been accepted.',
              style: TextStyle(fontSize: 13, color: Colors.blue[900]),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Terms Checkbox
  Widget _buildTermsCheckbox() {
    return CheckboxListTile(
      value: _agreedToTerms,
      onChanged: (value) {
        setState(() {
          _agreedToTerms = value!;
        });
      },
      title: RichText(
        text: const TextSpan(
          style: TextStyle(fontSize: 13, color: Colors.black87),
          children: [
            TextSpan(text: 'I agree to the '),
            TextSpan(
              text: 'booking terms',
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
                color: Color(0xFF276152),
              ),
            ),
            TextSpan(text: ' and '),
            TextSpan(
              text: 'cancellation policy',
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
                color: Color(0xFF276152),
              ),
            ),
          ],
        ),
      ),
      activeColor: const Color(0xFF276152),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  // ✅ Bottom Bar
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _requestToBook,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF276152),
              disabledBackgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Request to book',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ✅ Price Breakdown Dialog
  void _showPriceBreakdownDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Price Breakdown'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPriceRow(
              'Base rate',
              'EGP ${widget.property.price.toStringAsFixed(0)}/night',
            ),
            _buildPriceRow('Number of months', '${widget.rentalMonths} month${widget.rentalMonths > 1 ? 's' : ''}'),
            const Divider(),
            _buildPriceRow('Subtotal', 'EGP ${basePrice.toStringAsFixed(0)}'),
            _buildPriceRow(
              'Cleaning fee (${cleaningFeePercent.toStringAsFixed(0)}%)',
              'EGP ${cleaningFee.toStringAsFixed(0)}',
            ),
            _buildPriceRow(
              'Service fee (${serviceFeePercent.toStringAsFixed(0)}%)',
              'EGP ${serviceFee.toStringAsFixed(0)}',
            ),
            const Divider(),
            _buildPriceRow(
              'Total',
              'EGP ${widget.totalPrice.toStringAsFixed(0)}',
              isBold: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}