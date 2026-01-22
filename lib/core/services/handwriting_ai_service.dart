/// HTTP-based AI service for handwriting analysis.
/// Replaces direct Gemini SDK with backend API calls.
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the handwriting AI service
final handwritingAIServiceProvider = Provider<HandwritingAIService>(
  (ref) => HandwritingAIService(),
);

class HandwritingAIService {
  // 🔧 CONFIGURATION: Update this URL for your deployment
  // Development (local backend):
  static const String _backendUrl = 'http://10.127.126.45:8000';
  
  // For Android emulator (backend on host machine):
  // static const String _backendUrl = 'http://10.0.2.2:8000';
  
  // For production (deployed backend):
  // static const String _backendUrl = 'https://your-backend.com';
  
  static const Duration _timeout = Duration(seconds: 30);
  
  /// Mock response for offline/failure scenarios
  static const Map<String, dynamic> _mockResponse = {
    "shape_similarity": "medium",
    "missing_parts": [],
    "extra_strokes": [],
    "description": "Let's try again and write it a bit more clearly!"
  };

  /// Analyze handwriting by sending image to backend
  Future<Map<String, dynamic>> analyzeHandwriting(
    Uint8List imageBytes,
    String targetChar,
  ) async {
    try {
      debugPrint('🔍 Analyzing handwriting for "$targetChar" via backend...');
      
      // Encode image to base64
      final base64Image = base64Encode(imageBytes);
      
      // Prepare request
      final url = Uri.parse('$_backendUrl/ai/handwriting/analyze');
      final headers = {
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({
        'image_base64': base64Image,
        'target_char': targetChar,
      });
      
      // Send request with timeout
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(_timeout);
      
      // Check response status
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('✅ Backend analysis successful: ${result['shape_similarity']} similarity');
        return _validateResponse(result);
      } else {
        debugPrint('⚠️ Backend returned status ${response.statusCode}');
        return _mockResponse;
      }
      
    } on http.ClientException catch (e) {
      // Network error - backend unreachable
      debugPrint('⚠️ Backend unreachable: $e');
      debugPrint('📱 Using offline mode with mock response');
      return _mockResponse;
      
    } on FormatException catch (e) {
      // JSON parsing error
      debugPrint('⚠️ Invalid JSON response: $e');
      return _mockResponse;
      
    } catch (e) {
      // Any other error
      debugPrint('⚠️ Analysis failed: $e');
      return _mockResponse;
    }
  }

  /// Validate and sanitize backend response
  Map<String, dynamic> _validateResponse(Map<String, dynamic> response) {
    // Validate shape_similarity
    final similarity = response['shape_similarity']?.toString().toLowerCase();
    final validSimilarity = ['high', 'medium', 'low'].contains(similarity)
        ? similarity
        : 'medium';
    
    // Validate arrays
    final missingParts = response['missing_parts'] is List
        ? List<String>.from(response['missing_parts'])
        : <String>[];
    
    final extraStrokes = response['extra_strokes'] is List
        ? List<String>.from(response['extra_strokes'])
        : <String>[];
    
    // Validate description
    final description = response['description']?.toString().trim();
    final validDescription = description != null && description.isNotEmpty
        ? description
        : "Let's try again and write it a bit more clearly!";
    
    return {
      'shape_similarity': validSimilarity,
      'missing_parts': missingParts,
      'extra_strokes': extraStrokes,
      'description': validDescription,
    };
  }

  /// Check if backend is reachable (for health checks)
  Future<bool> checkBackendHealth() async {
    try {
      final url = Uri.parse('$_backendUrl/health');
      final response = await http.get(url).timeout(
        const Duration(seconds: 5),
      );
      
      if (response.statusCode == 200) {
        debugPrint('✅ Backend is healthy');
        return true;
      }
      
      debugPrint('⚠️ Backend returned status ${response.statusCode}');
      return false;
      
    } catch (e) {
      debugPrint('⚠️ Backend health check failed: $e');
      return false;
    }
  }
}
