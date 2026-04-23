import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../widgets/crop_card.dart';
import '../shared/chat_screen.dart';
import '../shared/create_crop_screen.dart';
import '../shared/order_management_screen.dart';

class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cropsAsync = ref.watch(sellerCropsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        actions: [
          IconButton(
            onPressed: () async {
              final user = ref.read(authServiceProvider).currentUser;
              if (user != null) {
                await ref.read(firestoreServiceProvider).seedSampleCrops(user.uid);
              }
            },
            icon: const Icon(Icons.data_array),
            tooltip: 'Add sample data',
          ),
          IconButton(
            onPressed: () => ref.read(authServiceProvider).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateCropScreen()));
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Crop'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OrderManagementScreen(isSeller: true)),
              );
            },
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Manage Buyer Requests'),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: cropsAsync.when(
              data: (crops) {
                if (crops.isEmpty) {
                  return const Center(child: Text('No crop listings yet.'));
                }
                return ListView.builder(
                  itemCount: crops.length,
                  itemBuilder: (context, i) {
                    final crop = crops[i];
                    return CropCard(
                      crop: crop,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'delete') {
                            await ref.read(firestoreServiceProvider).deleteCrop(crop.id);
                          } else if (value == 'chat') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ChatScreen(
                                  otherUserId: 'sample_buyer',
                                  otherUserLabel: 'Buyer',
                                ),
                              ),
                            );
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'chat', child: Text('Open Chat')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
