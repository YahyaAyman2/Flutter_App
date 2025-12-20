import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sakkeny_app/services/property_service.dart';

class PropertyCard extends StatefulWidget {
  final String price;
  final String title;
  final String location;
  final String imagePath;
  final String propertyId;

  const PropertyCard({
    super.key,
    required this.price,
    required this.title,
    required this.location,
    required this.imagePath,
    required this.propertyId,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  final PropertyService _propertyService = PropertyService();
  bool _isSaved = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    bool saved =
        await _propertyService.isPropertySaved(widget.propertyId);
    if (mounted) {
      setState(() {
        _isSaved = saved;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleSave() async {
    setState(() => _isLoading = true);

    bool success = await _propertyService
        .toggleSavedProperty(widget.propertyId);

    if (success && mounted) {
      setState(() {
        _isSaved = !_isSaved;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isSaved
                ? 'Added to favorites'
                : 'Removed from favorites',
          ),
          duration: const Duration(seconds: 1),
          backgroundColor:
              _isSaved ? Colors.green : Colors.red,
        ),
      );
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // ================= BACKGROUND IMAGE (CACHED) =================
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: widget.imagePath,
                fit: BoxFit.cover,

                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF276152),
                    ),
                  ),
                ),

                errorWidget: (context, url, error) =>
                    Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),

            // ================= GRADIENT OVERLAY =================
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),

            // ================= CONTENT =================
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- TOP ROW ----------
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // ❤️ Favorite Button
                      GestureDetector(
                        onTap:
                            _isLoading ? null : _toggleSave,
                        child: Container(
                          padding:
                              const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black
                                .withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  _isSaved
                                      ? Icons.favorite
                                      : Icons
                                          .favorite_border,
                                  color: _isSaved
                                      ? Colors.red
                                      : Colors.white,
                                  size: 18,
                                ),
                        ),
                      ),

                      // 💰 Price Badge
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black
                              .withOpacity(0.6),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.price,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // ---------- BOTTOM INFO ----------
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white70,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.location,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow
                                  .ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
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
