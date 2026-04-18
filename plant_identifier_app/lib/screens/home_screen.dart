import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/plant_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // فحص حالة API عند بدء التطبيق
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkApiStatus();
    });
  }

  Future<void> _checkApiStatus() async {
    final plantService = context.read<PlantService>();
    final isHealthy = await plantService.checkApiHealth();
    
    if (!isHealthy && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ تحذير: الخادم غير متوفر - تأكد من تشغيل API'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF1B5E20),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      '🌿',
                      style: TextStyle(fontSize: 60),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'معرف النبات',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'تعرف على نباتاتك من الصورة',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Main Content
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Camera Button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.pushNamed(context, '/identify');
                            },
                            icon: const Icon(Icons.camera_alt, size: 28),
                            label: const Text(
                              '📷 التقط صورة',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Gallery Button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final service = context.read<PlantService>();
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
                              side: const BorderSide(
                                color: Color(0xFF2E7D32),
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.photo_library, size: 28),
                            label: const Text(
                              '🖼️ اختر من gallery',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // History Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/history');
                            },
                            icon: const Icon(Icons.history),
                            label: const Text(
                              'سجل التعرفات السابقة',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}