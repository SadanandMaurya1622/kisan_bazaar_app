import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/crop_listing.dart';
import '../../providers/app_providers.dart';
import '../../widgets/crop_card.dart';
import '../shared/chat_screen.dart';
import '../shared/crop_detail_screen.dart';
import '../shared/order_management_screen.dart';

class BuyerDashboardScreen extends ConsumerWidget {
  const BuyerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cropsAsync = ref.watch(allCropsProvider);
    final search = ref.watch(cropSearchProvider);
    final location = ref.watch(selectedLocationFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyer Dashboard'),
        actions: [
          IconButton(
            onPressed: () => ref.read(authServiceProvider).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search crop by name',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => ref.read(cropSearchProvider.notifier).state = v,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Text('Location: '),
                DropdownButton<String>(
                  value: location,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'Mumbai', child: Text('Mumbai')),
                    DropdownMenuItem(value: 'Pune', child: Text('Pune')),
                    DropdownMenuItem(value: 'Nashik', child: Text('Nashik')),
                  ],
                  onChanged: (v) {
                    ref.read(selectedLocationFilterProvider.notifier).state = v ?? 'All';
                  },
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const OrderManagementScreen(isSeller: false)),
                    );
                  },
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('My Orders'),
                ),
              ],
            ),
          ),
          Expanded(
            child: cropsAsync.when(
              data: (crops) {
                final filtered = _applyFilters(crops, search, location);
                if (filtered.isEmpty) {
                  return const Center(child: Text('No crops match your filters.'));
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final crop = filtered[i];
                    return CropCard(
                      crop: crop,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => CropDetailScreen(crop: crop)),
                        );
                      },
                      trailing: IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                otherUserId: crop.sellerId,
                                otherUserLabel: crop.cropName,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat),
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

  List<CropListing> _applyFilters(List<CropListing> crops, String search, String location) {
    return crops.where((crop) {
      final byName = crop.cropName.toLowerCase().contains(search.toLowerCase());
      final byLocation = location == 'All' || crop.location == location;
      return byName && byLocation;
    }).toList();
  }
}
