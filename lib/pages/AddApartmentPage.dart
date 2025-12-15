import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddApartmentPage extends StatefulWidget {
  const AddApartmentPage({super.key});

  @override
  State<AddApartmentPage> createState() => _AddApartmentPageState();
}

class _AddApartmentPageState extends State<AddApartmentPage> {
  final supabase = Supabase.instance.client;

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController rentController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  List<File> selectedImages = [];

  bool _isUploading = false;
  int bedrooms = 1;
  int bathrooms = 1;

  final List<String> amenities = [
    'Air Conditioning',
    'Wifi',
    'Closet',
    'Iron',
    'TV',
    'Dedicated Workspace',
  ];

  Map<String, bool> selectedAmenities = {};

  @override
  void initState() {
    super.initState();
    for (var a in amenities) {
      selectedAmenities[a] = false;
    }
  }

  // ================= IMAGE PICK =================
  Future<void> pickImages() async {
    final images = await _picker.pickMultiImage(imageQuality: 75);
    if (images.isEmpty) return;

    setState(() {
      selectedImages.addAll(images.map((e) => File(e.path)));
    });
  }

  // ================= IMAGE UPLOAD (LIKE PROFILE) =================
  Future<List<String>> uploadPropertyImages(String propertyId) async {
    List<String> urls = [];

    for (int i = 0; i < selectedImages.length; i++) {
      final file = selectedImages[i];
      final bytes = await file.readAsBytes();
      final ext = file.path.split('.').last;

      final fileName = '$propertyId/img_${i + 1}.$ext';

      await supabase.storage.from('property-images').uploadBinary(
        fileName,
        bytes,
        fileOptions: FileOptions(
          upsert: true,
          contentType: 'image/$ext',
        ),
      );

      final publicUrl =
          supabase.storage.from('property-images').getPublicUrl(fileName);

      urls.add('$publicUrl?v=${DateTime.now().millisecondsSinceEpoch}');
    }

    return urls;
  }

  // ================= PUBLISH PROPERTY =================
  Future<void> publishProperty() async {
    if (selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add property images")),
      );
      return;
    }

    if (addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an address')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final propertyRef =
          FirebaseFirestore.instance.collection('property').doc();

      final imageUrls = await uploadPropertyImages(propertyRef.id);

      await propertyRef.set({
        'description': descriptionController.text.trim(),
        'rent': int.tryParse(rentController.text) ?? 0,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'amenities': selectedAmenities.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList(),
        'address': addressController.text.trim(),
        'images': imageUrls,
        'created_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() => _isUploading = false);
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Add Apartment"),
      ),
      body: _isUploading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                  _buildImagePickerSection(),
                  const SizedBox(height: 20),
                  _buildTextField("Description", descriptionController, 4),
                  const SizedBox(height: 20),
                  _buildTextField("Monthly Rent", rentController, 1,
                      isNumber: true),
                  const SizedBox(height: 20),
                  _buildLocationSection(),
                  const SizedBox(height: 20),
                  _buildDropdowns(),
                  const SizedBox(height: 20),
                  _buildAmenities(),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF276152),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: publishProperty,
                      child: const Text(
                        "Publish Apartment",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ================= WIDGETS =================
  Widget _buildImagePickerSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        height: 120,
        child: selectedImages.isEmpty
            ? Center(
                child: ElevatedButton(
                  onPressed: pickImages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF276152),
                  ),
                  child: const Text("+ Add Photos",
                      style: TextStyle(color: Colors.white)),
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
                          border:
                              Border.all(color: const Color(0xFF276152)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add,
                            color: Color(0xFF276152)),
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
                        top: 6,
                        right: 6,
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
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      int maxLines,
      {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdowns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bedrooms
        const Text("Bedrooms",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: List.generate(
            5,
            (i) => _numberChip(
              i + 1,
              bedrooms,
              (v) => setState(() => bedrooms = v),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Bathrooms
        const Text("Bathrooms",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: List.generate(
            3,
            (i) => _numberChip(
              i + 1,
              bathrooms,
              (v) => setState(() => bathrooms = v),
            ),
          ),
        ),
      ],
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
      selectedColor: const Color(0xFF276152),
      backgroundColor: Colors.grey.shade200,
      onSelected: (_) => onSelect(number),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Address",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: addressController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.location_on),
            hintText: "Feryal street, Building 123, Apartment 4B",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  Widget _buildAmenities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: amenities.map((a) {
        return CheckboxListTile(
          value: selectedAmenities[a],
          activeColor: const Color(0xFF276152),
          checkColor: Colors.white,
          title: Text(a),
          onChanged: (v) {
            setState(() {
              selectedAmenities[a] = v!;
            });
          },
        );
      }).toList(),
    );
  }
}
