import 'package:flutter/material.dart';

import '../models/crop_listing.dart';

class CropCard extends StatelessWidget {
  const CropCard({
    super.key,
    required this.crop,
    this.onTap,
    this.trailing,
  });

  final CropListing crop;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: crop.imageUrl.isEmpty
            ? const CircleAvatar(child: Icon(Icons.agriculture))
            : CircleAvatar(backgroundImage: NetworkImage(crop.imageUrl)),
        title: Text(crop.cropName),
        subtitle: Text(
          '${crop.quantity.toStringAsFixed(1)} kg | Rs ${crop.pricePerKg.toStringAsFixed(1)}/kg\n${crop.location}',
        ),
        isThreeLine: true,
        trailing: trailing,
      ),
    );
  }
}
