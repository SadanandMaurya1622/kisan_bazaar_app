import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../models/app_user.dart';
import '../models/crop_listing.dart';
import '../models/order_request.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/mandi_rate_service.dart';
import '../services/storage_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(FirebaseAuth.instance, GoogleSignIn());
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(FirebaseFirestore.instance);
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(FirebaseStorage.instance);
});

final mandiRateServiceProvider = Provider<MandiRateService>((ref) {
  return MandiRateService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

final currentUserDocProvider = StreamProvider<AppUser?>((ref) {
  final user = ref.watch(authServiceProvider).currentUser;
  if (user == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).watchUser(user.uid);
});

final allCropsProvider = StreamProvider<List<CropListing>>((ref) {
  return ref.watch(firestoreServiceProvider).watchCrops();
});

final sellerCropsProvider = StreamProvider<List<CropListing>>((ref) {
  final user = ref.watch(authServiceProvider).currentUser;
  if (user == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).watchSellerCrops(user.uid);
});

final buyerOrdersProvider = StreamProvider<List<OrderRequest>>((ref) {
  final user = ref.watch(authServiceProvider).currentUser;
  if (user == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).watchOrdersForBuyer(user.uid);
});

final sellerOrdersProvider = StreamProvider<List<OrderRequest>>((ref) {
  final user = ref.watch(authServiceProvider).currentUser;
  if (user == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).watchOrdersForSeller(user.uid);
});

final selectedLocationFilterProvider = StateProvider<String>((ref) => 'All');
final cropSearchProvider = StateProvider<String>((ref) => '');

final createCropControllerProvider =
    Provider<CreateCropController>((ref) => CreateCropController(ref));

class CreateCropController {
  CreateCropController(this._ref);

  final Ref _ref;
  final _uuid = const Uuid();

  Future<void> createCrop({
    required String cropName,
    required double quantity,
    required double pricePerKg,
    required String location,
    required XFile image,
  }) async {
    final user = _ref.read(authServiceProvider).currentUser;
    if (user == null) return;
    final imageUrl = await _ref.read(storageServiceProvider).uploadCropImage(File(image.path));
    final mandiRate = await _ref.read(mandiRateServiceProvider).fetchRate(
          cropName: cropName,
          location: location,
        );
    final crop = CropListing(
      id: _uuid.v4(),
      sellerId: user.uid,
      cropName: cropName,
      quantity: quantity,
      pricePerKg: pricePerKg,
      location: location,
      imageUrl: imageUrl,
      mandiRate: mandiRate,
      createdAt: DateTime.now(),
    );
    await _ref.read(firestoreServiceProvider).addCrop(crop);
  }
}
