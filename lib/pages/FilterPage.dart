import 'package:flutter/material.dart';
import 'package:sakkeny_app/pages/HomePage.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const FilterPage(),
    );
  }
}

class FilterPage extends StatefulWidget {
  const FilterPage({Key? key}) : super(key: key);

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  RangeValues _priceRange = const RangeValues(100000, 6000000);
  String selectedPropertyType = 'Apartment';
  int selectedBedroom = 3;
  int selectedBathroom = 2;

  Map<String, bool> amenities = {
    'Air Conditioning': true,
    'In-unit Laundry': true,
    'Gym': false,
    'Elevator': false,
    'Doorman': false,
    'Garage': true,
    'Dishwasher': true,
    'Hardwood Floors': false,
  };

  static const Color primaryColor = Color(0xFF276152);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200.withOpacity(0.4),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 5,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // PRICE RANGE
                const Text(
                  'Price Range',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                RangeSlider(
                  min: 100000,
                  max: 10000000,
                  values: _priceRange,
                  activeColor: primaryColor,
                  onChanged: (value) {
                    setState(() => _priceRange = value);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('#${_priceRange.start.toInt()}'),
                    Text('#${_priceRange.end.toInt()}'),
                  ],
                ),

                const SizedBox(height: 20),

                // PROPERTY TYPE
                const Text(
                  'Property Type',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: [
                    _typeChip('Apartment'),
                    _typeChip('Bungalow'),
                    _typeChip('Duplex'),
                    _typeChip('Villa'),
                  ],
                ),

                const SizedBox(height: 20),

                // BEDROOM
                const Text('Bedroom',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: List.generate(
                    5,
                    (i) => _numberChip(
                      i + 1,
                      selectedBedroom,
                      (v) => setState(() => selectedBedroom = v),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // BATHROOM
                const Text('Bathroom',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: List.generate(
                    5,
                    (i) => _numberChip(
                      i + 1,
                      selectedBathroom,
                      (v) => setState(() => selectedBathroom = v),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // AMENITIES
                const Text('Amenities',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Column(
                  children: amenities.keys.map((key) {
                    return CheckboxListTile(
                      activeColor: primaryColor,
                      checkColor: Colors.white,
                      value: amenities[key],
                      onChanged: (v) => setState(() => amenities[key] = v!),
                      title: Text(key),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // CLEAR FILTERS
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() {
                          _priceRange = const RangeValues(100000, 6000000);
                          selectedPropertyType = 'Apartment';
                          selectedBedroom = 3;
                          selectedBathroom = 2;
                          amenities.updateAll((key, value) => false);
                        });
                      },
                      child: const Text('Clear Filters'),
                    ),

                    // SHOW RESULTS
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>  HomePage(),
                          ),
                        );
                      },
                      child: const Text('Show Results',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _typeChip(String label) {
    final bool selected = selectedPropertyType == label;
    return ChoiceChip(
      showCheckmark: true,
      checkmarkColor: Colors.white,
      label: Text(
        label,
        style: TextStyle(color: selected ? Colors.white : Colors.black),
      ),
      selected: selected,
      selectedColor: primaryColor,
      backgroundColor: Colors.grey.shade200,
      onSelected: (_) => setState(() => selectedPropertyType = label),
    );
  }

  Widget _numberChip(int number, int selected, Function(int) onSelect) {
    final bool isSelected = selected == number;
    return ChoiceChip(
      showCheckmark: true,
      checkmarkColor: Colors.white,
      label: Text(
        number.toString(),
        style: TextStyle(color: isSelected ? Colors.white : Colors.black),
      ),
      selected: isSelected,
      selectedColor: primaryColor,
      backgroundColor: Colors.grey.shade200,
      onSelected: (_) => onSelect(number),
    );
  }
}