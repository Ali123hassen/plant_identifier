import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/plant_model.dart';

class PlantService extends ChangeNotifier {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1'; // Android emulator
  // static const String baseUrl = 'http://localhost:8000/api/v1'; // iOS simulator
  // static const String baseUrl = 'https://your-server.com/api/v1'; // Production

  bool _isLoading = false;
  String? _error;
  PlantModel? _currentPlant;
  final List<PlantModel> _history = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  PlantModel? get currentPlant => _currentPlant;
  List<PlantModel> get history => List.unmodifiable(_history);

  /**
   * التعرف على النبات من صورة
   */
  Future<PlantModel?> identifyPlant(File imageFile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/identify'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true || data['success'] == 1) {
          _currentPlant = PlantModel.fromJson(data);
          _history.insert(0, _currentPlant!);
          notifyListeners();
          return _currentPlant;
        } else {
          _error = data['message'] ?? 'لم يتم التعرف على النبات';
          return null;
        }
      } else {
        _error = 'خطأ في الاتصال بالخادم';
        return null;
      }
    } catch (e) {
      _error = 'خطأ: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /**
   * التعرف على النبات من الكاميرا
   */
  Future<PlantModel?> identifyFromCamera() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        return identifyPlant(File(image.path));
      }
      return null;
    } catch (e) {
      _error = 'خطأ في فتح الكاميرا: $e';
      notifyListeners();
      return null;
    }
  }

  /**
   * التعرف على النبات من الاستوديو
   */
  Future<PlantModel?> identifyFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        return identifyPlant(File(image.path));
      }
      return null;
    } catch (e) {
      _error = 'خطأ في اختيار الصورة: $e';
      notifyListeners();
      return null;
    }
  }

  /**
   * التعرف على النبات من Base64
   */
  Future<PlantModel?> identifyFromBase64(String base64Image) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/identify/base64'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'image': base64Image}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true || data['success'] == 1) {
          _currentPlant = PlantModel.fromJson(data);
          _history.insert(0, _currentPlant!);
          notifyListeners();
          return _currentPlant;
        } else {
          _error = data['message'] ?? 'لم يتم التعرف على النبات';
          return null;
        }
      } else {
        _error = 'خطأ في الاتصال بالخادم';
        return null;
      }
    } catch (e) {
      _error = 'خطأ: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /**
   * فحص حالة API
   */
  Future<bool> checkApiHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /**
   * مسح النتيجة الحالية
   */
  void clearCurrentPlant() {
    _currentPlant = null;
    _error = null;
    notifyListeners();
  }

  /**
   * مسح السجل
   */
  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  /**
   * حذف عنصر من السجل
   */
  void removeFromHistory(int index) {
    if (index >= 0 && index < _history.length) {
      _history.removeAt(index);
      notifyListeners();
    }
  }
}