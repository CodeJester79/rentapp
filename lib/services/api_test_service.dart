import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import '../utils/logger.dart';

class ApiTestService {
  final Logger _logger = AppLogger.getLogger('ApiTestService');
  static const String baseUrl = 'http://platform.rentem.click';

  Future<void> testApiConnection() async {
    _logger.info('🧪 TESTING API CONNECTION...');
    
    try {
      // Test 1: Basic connectivity
      await _testBasicConnectivity();
      
      // Test 2: Check API endpoints
      await _testEndpoints();
      
    } catch (e) {
      _logger.severe('💥 API Test failed: $e');
    }
  }

  Future<void> _testBasicConnectivity() async {
    try {
      _logger.info('📡 Testing basic connectivity to: $baseUrl');
      
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      _logger.info('🌐 Basic connectivity result:');
      _logger.info('Status Code: ${response.statusCode}');
      _logger.info('Headers: ${response.headers}');
      _logger.info('Body length: ${response.body.length}');
      
    } catch (e) {
      _logger.severe('❌ Basic connectivity failed: $e');
    }
  }

  Future<void> _testEndpoints() async {
    final endpoints = [
      '/docs',
      '/properties',
      '/properties/properties', 
      '/auth/login',
      '/auth/register',
    ];

    for (String endpoint in endpoints) {
      try {
        final url = '$baseUrl$endpoint';
        _logger.info('🔍 Testing endpoint: $url');
        
        final response = await http.get(
          Uri.parse(url),
          headers: {'accept': 'application/json'},
        ).timeout(const Duration(seconds: 10));

        _logger.info('📊 Endpoint $endpoint result:');
        _logger.info('Status Code: ${response.statusCode}');
        _logger.info('Content-Type: ${response.headers['content-type']}');
        
        if (response.statusCode == 200) {
          _logger.info('✅ Endpoint $endpoint is working');
        } else {
          _logger.warning('⚠️ Endpoint $endpoint returned: ${response.statusCode}');
        }
        
      } catch (e) {
        _logger.severe('❌ Endpoint $endpoint failed: $e');
      }
    }
  }
}