import 'package:cloud_firestore/cloud_firestore.dart';

class OrderRequest {
  const OrderRequest({
    required this.id,
    required this.cropId,
    required this.buyerId,
    required this.sellerId,
    required this.quantity,
    required this.deliveryMethod,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String cropId;
  final String buyerId;
  final String sellerId;
  final double quantity;
  final String deliveryMethod;
  final String status;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cropId': cropId,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'quantity': quantity,
      'deliveryMethod': deliveryMethod,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory OrderRequest.fromMap(Map<String, dynamic> map) {
    return OrderRequest(
      id: map['id'] as String? ?? '',
      cropId: map['cropId'] as String? ?? '',
      buyerId: map['buyerId'] as String? ?? '',
      sellerId: map['sellerId'] as String? ?? '',
      quantity: (map['quantity'] as num? ?? 0).toDouble(),
      deliveryMethod: map['deliveryMethod'] as String? ?? 'pickup',
      status: map['status'] as String? ?? 'pending',
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
