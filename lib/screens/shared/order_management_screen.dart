import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/order_request.dart';
import '../../providers/app_providers.dart';

class OrderManagementScreen extends ConsumerWidget {
  const OrderManagementScreen({super.key, required this.isSeller});

  final bool isSeller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = isSeller ? ref.watch(sellerOrdersProvider) : ref.watch(buyerOrdersProvider);
    return Scaffold(
      appBar: AppBar(title: Text(isSeller ? 'Buyer Requests' : 'My Orders')),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) return const Center(child: Text('No orders found.'));
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, i) => _OrderTile(order: orders[i], isSeller: isSeller),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _OrderTile extends ConsumerWidget {
  const _OrderTile({required this.order, required this.isSeller});

  final OrderRequest order;
  final bool isSeller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        title: Text('Order ${order.id.substring(0, 6)}'),
        subtitle: Text(
          'Qty: ${order.quantity} | ${order.deliveryMethod}\nStatus: ${order.status}',
        ),
        isThreeLine: true,
        trailing: isSeller
            ? PopupMenuButton<String>(
                onSelected: (value) async {
                  await ref.read(firestoreServiceProvider).updateOrderStatus(order.id, value);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'accepted', child: Text('Accept')),
                  PopupMenuItem(value: 'rejected', child: Text('Reject')),
                  PopupMenuItem(value: 'delivered', child: Text('Delivered')),
                ],
              )
            : null,
      ),
    );
  }
}
