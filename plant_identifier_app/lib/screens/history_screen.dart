import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/plant_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل التعرفات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              _showClearDialog(context);
            },
          ),
        ],
      ),
      body: Consumer<PlantService>(
        builder: (context, service, child) {
          final history = service.history;

          if (history.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final plant = history[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_florist,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  title: Text(
                    plant.commonName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    plant.scientificName ?? plant.family ?? '',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        plant.confidencePercentage,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: plant.confidence >= 0.5
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      if (plant.identifiedAt != null)
                        Text(
                          _formatDate(plant.identifiedAt!),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    // View details
                    service.clearCurrentPlant();
                    // Set current plant to view details
                    Navigator.pop(context);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد سجلات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بالتعرف على نباتاتك!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'الآن';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} دقيقة';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} ساعة';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح السجل'),
        content: const Text('هل أنت متأكد من مسح كل السجلات؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PlantService>().clearHistory();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }
}