class PlantModel {
  final String? scientificName;
  final String commonName;
  final String? family;
  final String? genus;
  final double confidence;
  final bool needsWater;
  final bool needsFertilizer;
  final bool needsSunlight;
  final String careInstructions;
  final String description;
  final DateTime? identifiedAt;
  final String? imagePath;

  PlantModel({
    this.scientificName,
    required this.commonName,
    this.family,
    this.genus,
    this.confidence = 0,
    this.needsWater = true,
    this.needsFertilizer = true,
    this.needsSunlight = true,
    this.careInstructions = '',
    this.description = '',
    this.identifiedAt,
    this.imagePath,
  });

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      scientificName: json['scientific_name'],
      commonName: json['common_name'] ?? 'غير معروف',
      family: json['family'],
      genus: json['genus'],
      confidence: (json['confidence'] ?? 0).toDouble(),
      needsWater: json['needs_water'] ?? true,
      needsFertilizer: json['needs_fertilizer'] ?? true,
      needsSunlight: json['needs_sunlight'] ?? true,
      careInstructions: json['care_instructions'] ?? '',
      description: json['description'] ?? '',
      identifiedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scientific_name': scientificName,
      'common_name': commonName,
      'family': family,
      'genus': genus,
      'confidence': confidence,
      'needs_water': needsWater,
      'needs_fertilizer': needsFertilizer,
      'needs_sunlight': needsSunlight,
      'care_instructions': careInstructions,
      'description': description,
    };
  }

  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(1)}%';

  List<String> get needsList {
    List<String> needs = [];
    if (needsWater) needs.add('💧 ماء');
    if (needsFertilizer) needs.add('🧪 سماد');
    if (needsSunlight) needs.add('☀️ ضوء');
    return needs.isEmpty ? ['✓ لا يحتاج شيء خاص'] : needs;
  }
}