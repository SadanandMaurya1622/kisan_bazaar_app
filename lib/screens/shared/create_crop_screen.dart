import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/app_providers.dart';

class CreateCropScreen extends ConsumerStatefulWidget {
  const CreateCropScreen({super.key});

  @override
  ConsumerState<CreateCropScreen> createState() => _CreateCropScreenState();
}

class _CreateCropScreenState extends ConsumerState<CreateCropScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cropCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  XFile? _image;
  bool _loading = false;

  @override
  void dispose() {
    _cropCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _image = image);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _image == null) return;
    setState(() => _loading = true);
    try {
      await ref.read(createCropControllerProvider).createCrop(
            cropName: _cropCtrl.text.trim(),
            quantity: double.parse(_qtyCtrl.text.trim()),
            pricePerKg: double.parse(_priceCtrl.text.trim()),
            location: _locationCtrl.text.trim(),
            image: _image!,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Crop Listing')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _cropCtrl,
                decoration: const InputDecoration(labelText: 'Crop Name'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity (kg/quintal)'),
                validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter valid number' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price per kg'),
                validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter valid number' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Upload Photo'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_image == null ? 'No image selected' : _image!.name)),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Publish Listing'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
