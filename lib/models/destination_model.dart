class Destination {
  final String id;
  final String name;
  final String category;
  final String description;
  final String imageUrl;
  final List<String> galleryUrls;
  final double rating;
  final double latitude;
  final double longitude;
  final String address;
  final String openingHours;
  final String ticketPrice;
  final List<String> facilities;
  final bool isFeatured;
  final String contact;
  final String? videoUrl;

  const Destination({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.galleryUrls,
    required this.rating,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.openingHours,
    required this.ticketPrice,
    required this.facilities,
    required this.isFeatured,
    required this.contact,
    this.videoUrl,
  });

  Destination copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    String? imageUrl,
    List<String>? galleryUrls,
    double? rating,
    double? latitude,
    double? longitude,
    String? address,
    String? openingHours,
    String? ticketPrice,
    List<String>? facilities,
    bool? isFeatured,
    String? contact,
    String? videoUrl,
  }) {
    return Destination(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      galleryUrls: galleryUrls ?? this.galleryUrls,
      rating: rating ?? this.rating,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      openingHours: openingHours ?? this.openingHours,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      facilities: facilities ?? this.facilities,
      isFeatured: isFeatured ?? this.isFeatured,
      contact: contact ?? this.contact,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'galleryUrls': galleryUrls,
      'rating': rating,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'openingHours': openingHours,
      'ticketPrice': ticketPrice,
      'facilities': facilities,
      'isFeatured': isFeatured,
      'contact': contact,
      'videoUrl': videoUrl,
    };
  }

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      galleryUrls: List<String>.from(json['galleryUrls'] as List),
      rating: (json['rating'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      openingHours: json['openingHours'] as String,
      ticketPrice: json['ticketPrice'] as String,
      facilities: List<String>.from(json['facilities'] as List),
      isFeatured: json['isFeatured'] as bool? ?? false,
      contact: json['contact'] as String? ?? 'Tidak Tersedia',
      videoUrl: json['videoUrl'] as String?,
    );
  }
}