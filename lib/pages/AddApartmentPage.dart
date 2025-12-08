import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddApartmentPage extends StatefulWidget {
  const AddApartmentPage({super.key});

  @override
  State<AddApartmentPage> createState() => _AddApartmentPageState();
}

class _AddApartmentPageState extends State<AddApartmentPage> {
  final List<String> amenities = [
    "Air Conditioner",
    "In-unit Laundry",
    "Nearby Gym",
    "Elevator",
    "Doorman",
    "Nearby Garage",
    "Dishwasher",
    "Hardwood Floors",
    "Clothing Storage",
    "Wifi",
    "Kitchen",
    "Refrigerator",
    "Microwave",
    "Stove",
  ];

  Map<String, bool> selectedAmenities = {};
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController rentController = TextEditingController();

  int bedrooms = 1;
  int bathrooms = 1;

  // ===== Image Picker =====
  final ImagePicker _picker = ImagePicker();
  List<File> selectedImages = [];

  @override
  void initState() {
    super.initState();
    for (var item in amenities) {
      selectedAmenities[item] = false;
    }
  }

  // ===== Pick Images Function =====
  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 70);

      if (images.isEmpty) return;

      setState(() {
        selectedImages.addAll(images.map((e) => File(e.path)));
      });
    } catch (e) {
      print("ERROR picking images: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Add Your Apartment",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Image Picker Section =====
            _buildImagePickerSection(),

            const SizedBox(height: 20),

            // Description
            const Text("Description",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            _buildTextBox(descriptionController, "Describe your apartment..."),

            const SizedBox(height: 20),

            // Location Section
            const Text("Location",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            _buildLocationSection(),

            const SizedBox(height: 20),

            // Rent + Rooms
            Row(
              children: [
                Expanded(
                  child: _buildInputWithLabel(
                    "Monthly Rent (EGP)",
                    TextField(
                      controller: rentController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "e.g. 3500"),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown("Bedrooms", bedrooms, (v) {
                    setState(() => bedrooms = v!);
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown("Bathrooms", bathrooms, (v) {
                    setState(() => bathrooms = v!);
                  }),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Amenities
            const Text("Amenities",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),

            _buildAmenitiesGrid(),

            const SizedBox(height: 30),

            // Publish Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF276152),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "Publish Apartment", 
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Image Picker Section =====
  Widget _buildImagePickerSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Apartment Images",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: selectedImages.isEmpty
                ? Center(
                    child: ElevatedButton(
  onPressed: pickImages,
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF276152), // Button background color
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    textStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
  child: const Text(
    "+ Add Photos",
    style: TextStyle(
      color: Colors.white, // Text color
    ),
  ),
),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedImages.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      if (index == selectedImages.length) {
                        return GestureDetector(
                          onTap: pickImages,
                          child: Container(
                            width: 120,
                            decoration: BoxDecoration(
                              border: Border.all(color: Color(0xFF276152),),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.add, color: Color(0xFF276152),),
                          ),
                        );
                      }
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              selectedImages[index],
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedImages.removeAt(index);
                                });
                              },
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.black54,
                                child: Icon(Icons.close,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextBox(controller, hint) {
    return TextField(
      controller: controller,
      maxLines: 5,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.search),
            hintText: "Search for your address",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(child: Text("Map Preview")),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF276152),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {},
          child: const Text(
  "Use Current Location",
  style: TextStyle(
    color: Colors.white,
  ),
),
        ),
      ],
    );
  }

  Widget _buildInputWithLabel(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _buildDropdown(String label, int value, Function(int?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButton<int>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: List.generate(
              5,
              (index) => DropdownMenuItem(
                value: index + 1,
                child: Text("${index + 1}"),
              ),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: amenities.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 4,
      ),
      itemBuilder: (context, i) {
        return CheckboxListTile(
          value: selectedAmenities[amenities[i]],
          onChanged: (v) {
            setState(() {
              selectedAmenities[amenities[i]] = v ?? false;
            });
          },
          title: Text(amenities[i]),
          controlAffinity: ListTileControlAffinity.leading,
        );
      },
    );
  }
}
