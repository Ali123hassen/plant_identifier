import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../services/plant_service.dart';

class IdentifyScreen extends StatefulWidget {
  const IdentifyScreen({super.key});

  @override
  State<IdentifyScreen> createState() => _IdentifyScreenState();
}

class _IdentifyScreenState extends State<IdentifyScreen> {
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التعرف على النبات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<PlantService>(
        builder: (context, service, child) {
          if (service.isLoading) {
            return _buildLoadingView();
          }

          if (_selectedImage != null) {
            return _buildImagePreview(service);
          }

          return _buildImageOptions(service);
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SpinKitWave(
            color: Color(0xFF2E7D32),
            size: 80,
          ),
          const SizedBox(height: 24),
          const Text(
            'جاري التعرف على النبات...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'قد يستغرق ذلك بضع ثوانٍ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageOptions(PlantService service) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Placeholder Icon
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF2E7D32),
                width: 3,
                style: BorderStyle.solid,
              ),
            ),
            child: const Icon(
              Icons.local_florist,
              size: 100,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 32),

          // Instruction Text
          const Text(
            'التقط صورة لنباتك',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تأكد من أن الصورة واضحة',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Camera Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await service.identifyFromCamera();
                if (result != null && mounted) {
                  Navigator.pushNamed(context, '/result');
                } else if (service.error != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(service.error!),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text(
                'التقط صورة بالكاميرا',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Gallery Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () async {
                final result = await service.identifyFromGallery();
                if (result != null && mounted) {
                  Navigator.pushNamed(context, '/result');
                } else if (service.error != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(service.error!),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2E7D32),
                side: const BorderSide(color: Color(0xFF2E7D32), width: 2),
              ),
              icon: const Icon(Icons.photo_library),
              label: const Text(
                'اختر من الاستوديو',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(PlantService service) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Image Preview
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              _selectedImage!,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 24),

          // Identify Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await service.identifyPlant(_selectedImage!);
                if (result != null && mounted) {
                  Navigator.pushNamed(context, '/result');
                } else if (service.error != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(service.error!),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.search),
              label: const Text(
                'تعرف على النبات',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Change Image Button
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedImage = null;
              });
              service.clearCurrentPlant();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('اختر صورة أخرى'),
          ),
        ],
      ),
    );
  }
}