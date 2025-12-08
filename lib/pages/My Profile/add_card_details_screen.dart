import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddCardDetailsScreenn extends StatefulWidget {
  final Function(String)? onCardAdded;

  const AddCardDetailsScreenn({Key? key, this.onCardAdded}) : super(key: key);

  @override
  State<AddCardDetailsScreenn> createState() => _AddCardDetailsScreennState();
}

class _AddCardDetailsScreennState extends State<AddCardDetailsScreenn> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _postcodeController = TextEditingController();
  String _selectedCountry = 'Egypt';
  int _cardNumberLength = 0;

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(() {
      setState(() {
        _cardNumberLength = _cardNumberController.text.replaceAll(' ', '').length;
      });
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _postcodeController.dispose();
    super.dispose();
  }

  void _formatCardNumber(String value) {
    String cleaned = value.replaceAll(' ', '');
    if (cleaned.length <= 16) {
      String formatted = '';
      for (int i = 0; i < cleaned.length; i++) {
        if (i > 0 && i % 4 == 0) {
          formatted += ' ';
        }
        formatted += cleaned[i];
      }
      _cardNumberController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _formatExpiry(String value) {
    String cleaned = value.replaceAll('/', '');
    if (cleaned.length <= 4) {
      String formatted = cleaned;
      if (cleaned.length >= 2) {
        formatted = '${cleaned.substring(0, 2)}/${cleaned.substring(2)}';
      }
      _expiryController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  bool _isExpiryValid(String expiry) {
    if (!RegExp(r'^(0[1-9]|1[0-2])\/[0-9]{2}$').hasMatch(expiry)) {
      return false;
    }

    final parts = expiry.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    
    if (month != null && year != null) {
      final now = DateTime.now();
      final currentYear = now.year % 100; // Get last 2 digits
      final currentMonth = now.month;
      
      // Check if the card is expired
      if (year < currentYear || (year == currentYear && month < currentMonth)) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add card details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Card Number with counter
                    TextFormField(
                      controller: _cardNumberController,
                      decoration: InputDecoration(
                        labelText: 'Card number',
                        suffixIcon: const Icon(Icons.credit_card),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        counterText: '$_cardNumberLength/16',
                        counterStyle: TextStyle(
                          fontSize: 12,
                          color: _cardNumberLength == 16 
                              ? const Color(0xFF276152) 
                              : Colors.grey.shade600,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                      ],
                      onChanged: (value) => _formatCardNumber(value),
                      validator: (value) {
                        String cleaned = value?.replaceAll(' ', '') ?? '';
                        if (cleaned.isEmpty) {
                          return 'Please enter card number';
                        }
                        if (cleaned.length != 16) {
                          return 'Card number must be 16 digits';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(cleaned)) {
                          return 'Invalid card number';
                        }
                        // Card must start with 4 or 5 (Visa/Mastercard)
                        if (!cleaned.startsWith('4') && !cleaned.startsWith('5')) {
                          return 'Only Visa and Mastercard accepted';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Expiry and CVV
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expiryController,
                            decoration: InputDecoration(
                              labelText: 'Expiry',
                              hintText: 'MM/YY',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            onChanged: (value) => _formatExpiry(value),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (!RegExp(r'^(0[1-9]|1[0-2])\/[0-9]{2}$').hasMatch(value)) {
                                return 'Invalid format (MM/YY)';
                              }
                              if (!_isExpiryValid(value)) {
                                return 'Card expired';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _cvvController,
                            decoration: InputDecoration(
                              labelText: 'CVV',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            maxLength: 3,
                            buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (value.length != 3) {
                                return '3 digits';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Invalid CVV';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Postcode
                    TextFormField(
                      controller: _postcodeController,
                      decoration: InputDecoration(
                        labelText: 'Postcode',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter postcode';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Country
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Country/region',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      value: _selectedCountry,
                      items: ['Egypt', 'United States', 'United Kingdom']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCountry = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    offset: const Offset(0, -1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          String cardNumber = _cardNumberController.text.replaceAll(' ', '');
                          if (widget.onCardAdded != null) {
                            widget.onCardAdded!(cardNumber);
                          }
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Card added successfully'),
                              backgroundColor: Color(0xFF276152),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF276152),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}