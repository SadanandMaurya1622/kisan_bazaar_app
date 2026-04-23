import 'package:cloud_firestore/cloud_firestore.dart';

class CropListing {
  const CropListing({
    required this.id,
    required this.sellerId,
    required this.cropName,
    required this.quantity,
    required this.pricePerKg,
    required this.location,
    required this.imageUrl,
    required this.mandiRate,
    required this.createdAt,
  });

  final String id;
  final String sellerId;
  final String cropName;
  final double quantity;
  final double pricePerKg;
  final String location;
  final String imageUrl;
  final double mandiRate;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sellerId': sellerId,
      'cropName': cropName,
      'quantity': quantity,
      'pricePerKg': pricePerKg,
      'location': location,
      'imageUrl': imageUrl,
      'mandiRate': mandiRate,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CropListing.fromMap(Map<String, dynamic> map) {
    return CropListing(
      id: map['id'] as String? ?? '',
      sellerId: map['sellerId'] as String? ?? '',
      cropName: map['cropName'] as String? ?? '',
      quantity: (map['quantity'] as num? ?? 0).toDouble(),
      pricePerKg: (map['pricePerKg'] as num? ?? 0).toDouble(),
      location: map['location'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      mandiRate: (map['mandiRate'] as num? ?? 0).toDouble(),
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
