import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/app_user.dart';
import '../models/chat_message.dart';
import '../models/crop_listing.dart';
import '../models/order_request.dart';

class FirestoreService {
  FirestoreService(this._firestore);

  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> get _users => _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _crops => _firestore.collection('crops');
  CollectionReference<Map<String, dynamic>> get _orders => _firestore.collection('orders');

  Future<void> saveUser(AppUser user) async {
    await _users.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Future<AppUser?> getUserById(String uid) async {
    final snap = await _users.doc(uid).get();
    final data = snap.data();
    if (!snap.exists || data == null) return null;
    return AppUser.fromMap(data);
  }

  Stream<AppUser?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return AppUser.fromMap(snap.data()!);
    });
  }

  Future<void> addCrop(CropListing crop) async {
    await _crops.doc(crop.id).set(crop.toMap());
  }

  Future<void> seedSampleCrops(String sellerId) async {
    final samples = [
      CropListing(
        id: _uuid.v4(),
        sellerId: sellerId,
        cropName: 'Wheat',
        quantity: 120,
        pricePerKg: 28,
        location: 'Pune',
        imageUrl: '',
        mandiRate: 2700,
        createdAt: DateTime.now(),
      ),
      CropListing(
        id: _uuid.v4(),
        sellerId: sellerId,
        cropName: 'Tomato',
        quantity: 80,
        pricePerKg: 35,
        location: 'Nashik',
        imageUrl: '',
        mandiRate: 3200,
        createdAt: DateTime.now(),
      ),
    ];
    for (final crop in samples) {
      await _crops.doc(crop.id).set(crop.toMap());
    }
  }

  Future<void> updateCrop(CropListing crop) async {
    await _crops.doc(crop.id).update(crop.toMap());
  }

  Future<void> deleteCrop(String cropId) async {
    await _crops.doc(cropId).delete();
  }

  Stream<List<CropListing>> watchCrops() {
    return _crops.orderBy('createdAt', descending: true).snapshots().map(
      (snap) => snap.docs.map((doc) => CropListing.fromMap(doc.data())).toList(),
    );
  }

  Stream<List<CropListing>> watchSellerCrops(String sellerId) {
    return _crops
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => CropListing.fromMap(doc.data())).toList());
  }

  Future<void> createOrder({
    required String cropId,
    required String buyerId,
    required String sellerId,
    required double quantity,
    required String deliveryMethod,
  }) async {
    final order = OrderRequest(
      id: _uuid.v4(),
      cropId: cropId,
      buyerId: buyerId,
      sellerId: sellerId,
      quantity: quantity,
      deliveryMethod: deliveryMethod,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    await _orders.doc(order.id).set(order.toMap());
  }

  Stream<List<OrderRequest>> watchOrdersForSeller(String sellerId) {
    return _orders
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => OrderRequest.fromMap(doc.data())).toList());
  }

  Stream<List<OrderRequest>> watchOrdersForBuyer(String buyerId) {
    return _orders
        .where('buyerId', isEqualTo: buyerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => OrderRequest.fromMap(doc.data())).toList());
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _orders.doc(orderId).update({'status': status});
  }

  String getChatRoomId(String a, String b) {
    final sorted = [a, b]..sort();
    return '${sorted.first}_${sorted.last}';
  }

  Stream<List<ChatMessage>> watchChat(String roomId) {
    return _firestore
        .collection('chats')
        .doc(roomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ChatMessage.fromMap(doc.data())).toList());
  }

  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String text,
  }) async {
    final message = ChatMessage(
      id: _uuid.v4(),
      chatRoomId: roomId,
      senderId: senderId,
      text: text,
      createdAt: DateTime.now(),
    );
    await _firestore
        .collection('chats')
        .doc(roomId)
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());
  }
}
