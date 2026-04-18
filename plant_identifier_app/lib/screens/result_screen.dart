import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/plant_service.dart';
import '../models/plant_model.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نتيجة التعرف'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<PlantService>().clearCurrentPlant();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('TODO: Share feature')),
              );
            },
          ),
        ],
      ),
      body: Consumer<PlantService>(
        builder: (context, service, child) {
          final plant = service.currentPlant;

          if (plant == null) {
            return const Center(
              child: Text('لا توجد نتيجة'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plant Name Card
                _buildNameCard(plant),
                const SizedBox(height: 16),

                // Confidence Card
                _buildConfidenceCard(plant),
                const SizedBox(height: 16),

                // Plant Needs
                _buildNeedsCard(plant),
                const SizedBox(height: 16),

                // Care Instructions
                _buildCareCard(plant),
                const SizedBox(height: 24),

                // Action Buttons
                _buildActionButtons(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNameCard(PlantModel plant) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_florist,
                    color: Color(0xFF2E7D32),
                    size: 40,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.commonName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (plant.scientificName != null)
                        Text(
                          plant.scientificName!,
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (plant.family != null) ...[
              const Divider(height: 24),
              Row(
                children: [
                  const Text('الفصيلة: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(plant.family!),
                ],
              ),
            ],
            if (plant.genus != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('الجنس: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(plant.genus!),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceCard(PlantModel plant) {
    Color confidenceColor;
    if (plant.confidence >= 0.8) {
      confidenceColor = Colors.green;
    } else if (plant.confidence >= 0.5) {
      confidenceColor = Colors.orange;
    } else {
      confidenceColor = Colors.red;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.verified_user, color: Color(0xFF2E7D32)),
            const SizedBox(width: 12),
            const Text(
              'ثقة التعرف: ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              plant.confidencePercentage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: confidenceColor,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                value: plant.confidence,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(confidenceColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeedsCard(PlantModel plant) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.help_outline, color: Color(0xFF2E7D32)),
                SizedBox(width: 12),
                Text(
                  'احتياجات النبات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: plant.needsList.map((need) {
                return Chip(
                  label: Text(need),
                  backgroundColor: const Color(0xFF2E7D32).withOpacity(0.1),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareCard(PlantModel plant) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.eco, color: Color(0xFF2E7D32)),
                SizedBox(width: 12),
                Text(
                  'تعليمات العناية',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...plant.careInstructions.split('\n').map((instruction) {
              if (instruction.trim().isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        instruction.replaceAll('•', '').trim(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (plant.description.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                plant.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('تعرف على آخر'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              context.read<PlantService>().clearCurrentPlant();
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2E7D32),
            ),
            icon: const Icon(Icons.home),
            label: const Text('الرئيسية'),
          ),
        ),
      ],
    );
  }
}