import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cards.dart';

class PropertyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===== 1. FETCH ALL PROPERTIES (for HomePage) =====
  Stream<List<PropertyModel>> getAllProperties() {
    return _firestore
        .collection('properties')
        .where('isPublished', isEqualTo: true)
        .where('status', isEqualTo: 'available')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return PropertyModel.fromFirestore(doc.data());
          }).toList();
        });
  }

  // ===== 2. FETCH SINGLE PROPERTY (for Property Details Page) =====
  Future<PropertyModel?> getPropertyById(String propertyId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('properties')
          .doc(propertyId)
          .get();

      if (doc.exists) {
        return PropertyModel.fromFirestore(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching property: $e');
      return null;
    }
  }

  // ===== 3. ADD NEW PROPERTY (for AddApartmentPage) - FIXED =====
  Future<bool> addProperty({
    required String title,
    required String description,
    required double price,
    required PropertyLocation location,
    required String propertyType,
    required int bedrooms,
    required int bathrooms,
    required int livingrooms,
    required int kitchens,
    required int balconies,
    required List<String> amenities,
    required List<String> imageUrls,
  }) async {
    try {
      print('📤 Starting property upload...');

      // Get current user
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('❌ User not logged in');
        return false;
      }
      print('✅ User authenticated: ${currentUser.uid}');

      // Get user details from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      String ownerName = 'Unknown';
      String? ownerImage;

      if (userDoc.exists) {
        try {
          ownerName = userDoc.get('first name') ?? 'Unknown';
          // ownerImage = userDoc.get('profileImage');
        } catch (e) {
          print('⚠️ Error getting user fields: $e');
        }
      }
      print('✅ Owner name: $ownerName');

      // Generate property ID
      String propertyId = _firestore.collection('properties').doc().id;
      print('✅ Property ID generated: $propertyId');

      // Upload images (assuming imageUrls are already uploaded and are URLs)

      // Create property object
      PropertyModel newProperty = PropertyModel(
        propertyId: propertyId,
        userId: currentUser.uid,
        userName: ownerName,
        userImage: ownerImage,
        title: title,
        description: description,
        price: price,
        priceDisplay: 'EGP ${price.toStringAsFixed(0)}/Month',
        location: location,
        propertyType: propertyType,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        livingrooms: livingrooms,
        kitchens: kitchens,
        balconies: balconies,
        amenities: amenities,
        isWifi: amenities.contains('Wifi'),
        images: imageUrls, // ✅
        mainImage: imageUrls.first, // ✅
        rating: 0.0,
        reviews: 0,
        status: 'available',
        isPublished: true,
      );

      print('📝 Saving property to Firestore...');

      // Save to Firestore
      await _firestore
          .collection('properties')
          .doc(propertyId)
          .set(newProperty.toFirestore());

      print('✅ Property added successfully!');
      return true;
    } catch (e, stackTrace) {
      print('❌ Error adding property: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  // ===== 4. UPDATE PROPERTY =====
  Future<bool> updateProperty(PropertyModel property) async {
    try {
      await _firestore
          .collection('properties')
          .doc(property.propertyId)
          .update(property.toFirestore());
      return true;
    } catch (e) {
      print('Error updating property: $e');
      return false;
    }
  }

  // ===== 5. DELETE PROPERTY =====
  Future<bool> deleteProperty(String propertyId) async {
    try {
      await _firestore.collection('properties').doc(propertyId).delete();
      return true;
    } catch (e) {
      print('Error deleting property: $e');
      return false;
    }
  }

  // ===== 6. SEARCH PROPERTIES =====
  Future<List<PropertyModel>> searchProperties(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('properties')
          .where('isPublished', isEqualTo: true)
          .get();

      List<PropertyModel> results = [];
      for (var doc in snapshot.docs) {
        PropertyModel property = PropertyModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
        );

        if (property.title.toLowerCase().contains(query.toLowerCase()) ||
            property.location.fullAddress.toLowerCase().contains(
              query.toLowerCase(),
            )) {
          results.add(property);
        }
      }

      return results;
    } catch (e) {
      print('Error searching properties: $e');
      return [];
    }
  }

  // ===== 7. FILTER PROPERTIES =====
  Future<List<PropertyModel>> filterProperties({
    double? minPrice,
    double? maxPrice,
    String? propertyType,
    int? bedrooms,
    int? bathrooms,
    List<String>? amenities,
  }) async {
    try {
      Query query = _firestore
          .collection('properties')
          .where('isPublished', isEqualTo: true)
          .where('status', isEqualTo: 'available');

      if (minPrice != null) {
        query = query.where('price', isGreaterThanOrEqualTo: minPrice);
      }
      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }
      if (propertyType != null && propertyType != 'All') {
        query = query.where('propertyType', isEqualTo: propertyType);
      }
      if (bedrooms != null) {
        query = query.where('bedrooms', isEqualTo: bedrooms);
      }
      if (bathrooms != null) {
        query = query.where('bathrooms', isEqualTo: bathrooms);
      }

      QuerySnapshot snapshot = await query.get();

      List<PropertyModel> results = snapshot.docs.map((doc) {
        return PropertyModel.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();

      if (amenities != null && amenities.isNotEmpty) {
        results = results.where((property) {
          return amenities.every(
            (amenity) => property.amenities.contains(amenity),
          );
        }).toList();
      }

      return results;
    } catch (e) {
      print('Error filtering properties: $e');
      return [];
    }
  }

  // ===== 8. SAVE/UNSAVE PROPERTY (Toggle Favorite) =====
  Future<bool> toggleSavedProperty(String propertyId) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('User not logged in');
        return false;
      }

      DocumentReference savedRef = _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('saved_properties')
          .doc(propertyId);

      DocumentSnapshot doc = await savedRef.get();

      if (doc.exists) {
        await savedRef.delete();
        print('✅ Property removed from saved');
      } else {
        await savedRef.set({
          'propertyId': propertyId,
          'savedAt': FieldValue.serverTimestamp(),
        });
        print('✅ Property saved');
      }

      return true;
    } catch (e) {
      print('❌ Error toggling saved property: $e');
      return false;
    }
  }

  // ===== 9. CHECK IF PROPERTY IS SAVED =====
  Future<bool> isPropertySaved(String propertyId) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('saved_properties')
          .doc(propertyId)
          .get();

      return doc.exists;
    } catch (e) {
      print('Error checking saved property: $e');
      return false;
    }
  }

  // ===== 10. GET ALL SAVED PROPERTIES =====
  Stream<List<PropertyModel>> getAllSavedProperties() {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('saved_properties')
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.docs.isEmpty) return [];

          List<String> propertyIds = snapshot.docs
              .map((doc) => doc.get('propertyId') as String)
              .toList();

          List<PropertyModel> properties = [];
          for (String propertyId in propertyIds) {
            PropertyModel? property = await getPropertyById(propertyId);
            if (property != null) {
              properties.add(property);
            }
          }

          return properties;
        });
  }

  // ===== 11. GET USER'S OWN PROPERTIES =====
  Stream<List<PropertyModel>> getUserProperties() {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('properties')
        .where('userId', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return PropertyModel.fromFirestore(doc.data());
          }).toList();
        });
  }
}
