import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/crop_listing.dart';
import '../../providers/app_providers.dart';

class CropDetailScreen extends ConsumerStatefulWidget {
  const CropDetailScreen({super.key, required this.crop});

  final CropListing crop;

  @override
  ConsumerState<CropDetailScreen> createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends ConsumerState<CropDetailScreen> {
  final _qtyCtrl = TextEditingController();
  String _deliveryMethod = 'pickup';

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _requestOrder() async {
    final user = ref.read(authServiceProvider).currentUser;
    final qty = double.tryParse(_qtyCtrl.text.trim());
    if (user == null || qty == null) return;

    await ref.read(firestoreServiceProvider).createOrder(
          cropId: widget.crop.id,
          buyerId: user.uid,
          sellerId: widget.crop.sellerId,
          quantity: qty,
          deliveryMethod: _deliveryMethod,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order request sent')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final crop = widget.crop;
    return Scaffold(
      appBar: AppBar(title: Text(crop.cropName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (crop.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(crop.imageUrl, height: 220, width: double.infinity, fit: BoxFit.cover),
              ),
            const SizedBox(height: 12),
            Text('Price: Rs ${crop.pricePerKg}/kg', style: Theme.of(context).textTheme.titleLarge),
            Text('Location: ${crop.location}'),
            Text('Mandi Rate: Rs ${crop.mandiRate}/quintal'),
            const Divider(height: 24),
            TextField(
              controller: _qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity to buy'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _deliveryMethod,
              items: const [
                DropdownMenuItem(value: 'pickup', child: Text('Buyer pickup')),
                DropdownMenuItem(value: 'delivery', child: Text('Self delivery')),
              ],
              onChanged: (v) => setState(() => _deliveryMethod = v ?? 'pickup'),
              decoration: const InputDecoration(labelText: 'Delivery Option'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _requestOrder,
              child: const Text('Send Buy Request'),
            ),
          ],
        ),
      ),
    );
  }
}
