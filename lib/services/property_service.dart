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
    required int bedrooms,
    required int bathrooms,
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
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        kitchens: kitchens,
        balconies: balconies,
        amenities: amenities,
        isWifi: amenities.contains('Wifi'),
        images: imageUrls, // ✅
        mainImage: imageUrls.first, // ✅
        rating: 0.0,
        status: 'available',
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

  // ===== 7. FILTER PROPERTIES (IN-MEMORY SOLUTION) =====
  Future<List<PropertyModel>> filterProperties({
    double? minPrice,
    double? maxPrice,
    String? propertyType,
    int? bedrooms,
    int? bathrooms,
    int? kitchens, // ✅
    int? balconies, // ✅
    List<String>? amenities,
  }) async {
    try {
      print('🔍 Starting in-memory filter with parameters:');
      print('  Min Price: $minPrice, Max Price: $maxPrice');
      print('  Type: $propertyType');
      print('  Bedrooms: $bedrooms, Bathrooms: $bathrooms');
      print('  Amenities: $amenities');

      // Fetch ALL published and available properties
      print('📤 Fetching all properties from Firestore...');
      QuerySnapshot snapshot = await _firestore
          .collection('properties')
          .where('isPublished', isEqualTo: true)
          .where('status', isEqualTo: 'available')
          .get();

      print('📥 Retrieved ${snapshot.docs.length} total properties');

      if (snapshot.docs.isEmpty) {
        print('⚠️ No properties found in Firestore');
        return [];
      }

      // Convert to PropertyModel list
      List<PropertyModel> allProperties = [];
      for (var doc in snapshot.docs) {
        try {
          PropertyModel property = PropertyModel.fromFirestore(
            doc.data() as Map<String, dynamic>,
          );
          allProperties.add(property);
        } catch (e) {
          print('⚠️ Error parsing document ${doc.id}: $e');
        }
      }

      print('✅ Successfully parsed ${allProperties.length} properties');

      // Now filter in memory
      int initialCount = allProperties.length;
      List<PropertyModel> filteredProperties = allProperties.where((property) {
        // Price filter - Min Price
        if (minPrice != null && property.price < minPrice) {
          return false;
        }

        // Price filter - Max Price
        if (maxPrice != null && property.price > maxPrice) {
          return false;
        }

        // Bedrooms filter
        if (bedrooms != null && property.bedrooms != bedrooms) {
          return false;
        }

        // Bathrooms filter
        if (bathrooms != null && property.bathrooms != bathrooms) {
          return false;
        }
        // Kitchens filter
        if (kitchens != null && property.kitchens != kitchens) {
          return false;
        }

        // Balconies filter
        if (balconies != null && property.balconies != balconies) {
          return false;
        }

        // Amenities filter - property must have ALL selected amenities
        if (amenities != null && amenities.isNotEmpty) {
          // Check if property.amenities is null or empty
          if (property.amenities == null || property.amenities.isEmpty) {
            return false;
          }

          // Normalize amenity names to handle variations
          List<String> normalizedPropertyAmenities = property.amenities
              .map((a) => a.toLowerCase().trim())
              .toList();

          // Check if property has ALL required amenities (case-insensitive)
          bool hasAllAmenities = amenities.every((amenity) {
            String normalizedAmenity = amenity.toLowerCase().trim();

            // Check for exact match or common variations
            return normalizedPropertyAmenities.any((propAmenity) {
              // Handle "Air Conditioning" vs "Air Conditioner"
              if (normalizedAmenity.contains('air condition') &&
                  propAmenity.contains('air condition')) {
                return true;
              }
              // Handle "TV" vs "Tv"
              if (normalizedAmenity == 'tv' && propAmenity == 'tv') {
                return true;
              }
              // Regular match
              return propAmenity == normalizedAmenity;
            });
          });

          if (!hasAllAmenities) {
            return false;
          }
        }

        // If all filters pass, include this property
        return true;
      }).toList();

      print('');
      print('📊 Filter Results:');
      print('  Started with: $initialCount properties');
      print('  After filtering: ${filteredProperties.length} properties');
      print(
        '  Removed: ${initialCount - filteredProperties.length} properties',
      );
      print('');

      // Debug: Show which properties passed
      if (filteredProperties.isNotEmpty) {
        print('✅ Properties that matched filters:');
        for (var property in filteredProperties) {
          print(
            '  - ${property.title} , ${property.bedrooms} beds, EGP ${property.price})',
          );
        }
      } else {
        print('❌ No properties matched the filter criteria');
        print('');
        print('🔍 Debug Info - Sample properties in database:');
        if (allProperties.isNotEmpty) {
          for (
            var i = 0;
            i < (allProperties.length > 3 ? 3 : allProperties.length);
            i++
          ) {
            var p = allProperties[i];
            print('  Property $i:');
            print('    Title: ${p.title}');
            print('    Price: ${p.price}');
            print('    Bedrooms: ${p.bedrooms}');
            print('    Bathrooms: ${p.bathrooms}');
            print('    Kitchens: ${p.kitchens}');
            print('    Balconies: ${p.balconies}');

            print('    Amenities: ${p.amenities}');
          }
        }
      }

      return filteredProperties;
    } catch (e, stackTrace) {
      print('❌ Error filtering properties: $e');
      print('Stack trace: $stackTrace');
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

  // ===== 12. SAVE RECENT SEARCH =====
  Future<bool> saveRecentSearch(PropertyModel property) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('❌ User not logged in');
        return false;
      }

      // Reference to user's recent searches subcollection
      DocumentReference searchRef = _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('recent_searches')
          .doc(property.propertyId);

      // Save with timestamp
      await searchRef.set({
        'propertyId': property.propertyId,
        'searchedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Search saved to Firestore');
      return true;
    } catch (e) {
      print('❌ Error saving recent search: $e');
      return false;
    }
  }

  // ===== 13. GET RECENT SEARCHES (Stream) =====
  Stream<List<PropertyModel>> getRecentSearches({int limit = 5}) {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('recent_searches')
        .orderBy('searchedAt', descending: true)
        .limit(limit)
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.docs.isEmpty) return [];

          List<PropertyModel> properties = [];
          for (var doc in snapshot.docs) {
            String propertyId = doc.get('propertyId') as String;
            PropertyModel? property = await getPropertyById(propertyId);
            if (property != null) {
              properties.add(property);
            }
          }

          return properties;
        });
  }

  // ===== 14. CLEAR ALL RECENT SEARCHES =====
  Future<bool> clearRecentSearches() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      QuerySnapshot searches = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('recent_searches')
          .get();

      for (var doc in searches.docs) {
        await doc.reference.delete();
      }

      print('✅ Recent searches cleared');
      return true;
    } catch (e) {
      print('❌ Error clearing searches: $e');
      return false;
    }
  }

  // ===== 15. DELETE SINGLE RECENT SEARCH =====
  Future<bool> deleteRecentSearch(String propertyId) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('recent_searches')
          .doc(propertyId)
          .delete();

      print('✅ Recent search deleted');
      return true;
    } catch (e) {
      print('❌ Error deleting recent search: $e');
      return false;
    }
  }

  // ===== 16. BOOK PROPERTY =====
  Future<bool> bookProperty(String propertyId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('User not logged in');
        return false;
      }

      // Check if property exists and is available
      PropertyModel? property = await getPropertyById(propertyId);
      if (property == null) {
        print('Property not found');
        return false;
      }

      if (property.status != 'available') {
        print('Property is not available');
        return false;
      }

      // Update property status to rented
      await _firestore.collection('properties').doc(propertyId).update({
        'status': 'rented',
      });

      // Create booking record
      String bookingId = _firestore.collection('bookings').doc().id;
      await _firestore.collection('bookings').doc(bookingId).set({
        'bookingId': bookingId,
        'propertyId': propertyId,
        'userId': currentUser.uid,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'bookedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Property booked successfully');
      return true;
    } catch (e) {
      print('❌ Error booking property: $e');
      return false;
    }
  }

  // ===== 17. GET BOOKED PROPERTIES =====
  Stream<List<PropertyModel>> getBookedProperties() {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: currentUser.uid)
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

  // ===== 18. CHECK IF PROPERTY IS BOOKED BY CURRENT USER =====
  Future<bool> isPropertyBookedByUser(String propertyId) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      QuerySnapshot bookingSnapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: currentUser.uid)
          .where('propertyId', isEqualTo: propertyId)
          .get();

      return bookingSnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if property is booked: $e');
      return false;
    }
  }
}