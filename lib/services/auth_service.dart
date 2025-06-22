import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import '../utils/logger.dart';
import '../models/user.dart';

class AuthService {
  // Logger para esta clase
  final Logger _logger = AppLogger.getLogger('AuthService');

  // URL base de la API (ajustar según sea necesario)
  static const String baseUrl =
      'http://platform.rentem.click'; // URL real de la API

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _usernameKey = 'username';
  static const String _emailKey = 'email';

  // Token de autenticación
  String? _token;
  String? _userId;
  String? _userRole;
  String? _username;
  String? _email;

  // Getter para verificar si el usuario está autenticado
  bool get isAuthenticated => _token != null;

  // Getters para token y datos de usuario
  String? get token => _token;
  String? get userId => _userId;
  String? get userRole => _userRole;
  String? get username => _username;
  String? get email => _email;

  // Getter para obtener los datos del usuario actual
  User? get currentUser => _token != null
      ? User(
          userId: _userId,
          userRole: _userRole,
          username: _username,
          email: _email,
        )
      : null;

  // Registro de usuario
  Future<Map<String, dynamic>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
    String role = 'customer',
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'username': name,
        'email': email,
        'password': password,
        'role': role,
      };

      // Agregar número de teléfono solo si se proporciona
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        requestBody['phone_number'] = phoneNumber;
      }

      final url = '$baseUrl/auth/register';
      _logger.info('🚀 REGISTER REQUEST:');
      _logger.info('URL: $url');
      _logger.info('Headers: {accept: application/json, Content-Type: application/json}');
      _logger.info('Body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 15));

      _logger.info('📨 REGISTER RESPONSE:');
      _logger.info('Status Code: ${response.statusCode}');
      _logger.info('Response Body: ${response.body}');
      _logger.info('Response Headers: ${response.headers}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        // Registro exitoso
        return responseData;
      } else {
        // Manejar errores
        throw Exception(responseData['detail'] ??
            responseData['message'] ??
            'Error al registrarse');
      }
    } catch (e) {
      _logger.severe('Error de conexión: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Inicio de sesión
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      final requestBody = {
        'email': email,
        'password': password,
      };

      final url = '$baseUrl/auth/login';
      _logger.info('🚀 LOGIN REQUEST:');
      _logger.info('URL: $url');
      _logger.info('Headers: {accept: application/json, Content-Type: application/json}');
      _logger.info('Body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 15));

      _logger.info('📨 LOGIN RESPONSE:');
      _logger.info('Status Code: ${response.statusCode}');
      _logger.info('Response Body: ${response.body}');
      _logger.info('Response Headers: ${response.headers}');

      final responseData = json.decode(response.body);
      _logger.info('Response data keys: ${responseData.keys.toList()}');

      if (response.statusCode == 200) {
        // Obtener token del formato correcto de respuesta
        _token =
            responseData['token']; // La API devuelve 'token', no 'access_token'
        _logger.info('Token recibido: $_token');

        // Obtener datos del usuario
        var userData = responseData['user'];
        _userId = userData['id'].toString(); // La API usa 'id', no 'user_id'
        _userRole = userData['role'] ?? 'customer';
        _username = userData['username'] ?? '';
        _email = userData['email'] ?? '';

        // Guardar en SharedPreferences para persistencia
        final prefs = await SharedPreferences.getInstance();
        if (_token != null) {
          prefs.setString(_tokenKey, _token!);
          prefs.setString(_userIdKey, _userId ?? '');
          prefs.setString(_userRoleKey, _userRole ?? 'customer');
          prefs.setString(_usernameKey, _username ?? '');
          prefs.setString(_emailKey, _email ?? '');
          _logger.info('Datos de usuario guardados en SharedPreferences');
        }
      } else {
        String errorMessage =
            responseData['detail'] ?? 'Error de autenticación';
        _logger.warning(
            'Error de inicio de sesión: ${response.statusCode} - $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      _logger.severe('Exception en signInWithEmailAndPassword: $e');
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    _token = null;
    _userId = null;
    _userRole = null;
    _username = null;
    _email = null;

    // Eliminar datos guardados
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_tokenKey);
    prefs.remove(_userIdKey);
    prefs.remove(_userRoleKey);
    prefs.remove(_usernameKey);
    prefs.remove(_emailKey);
  }

  // Intentar iniciar sesión automáticamente usando token almacenado
  Future<bool> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!prefs.containsKey(_tokenKey)) {
        _logger.info('No hay token almacenado');
        return false;
      }

      // Restaurar datos de sesión desde SharedPreferences
      _token = prefs.getString(_tokenKey);
      _userId = prefs.getString(_userIdKey);
      _userRole = prefs.getString(_userRoleKey) ?? 'user';
      _username = prefs.getString(_usernameKey);
      _email = prefs.getString(_emailKey);

      _logger.info('Datos restaurados de SharedPreferences:');
      _logger.info('Token: $_token');
      _logger.info('UserID: $_userId');
      _logger.info('Role: $_userRole');
      _logger.info('Username: $_username');
      _logger.info('Email: $_email');

      // Por ahora soportamos login sin validación del token para pruebas
      // En un entorno de producción, se debería validar el token con el servidor
      return _token != null && _token!.isNotEmpty;
    } catch (e) {
      _logger.severe('Error en tryAutoLogin: $e');
      return false;
    }
  }

  // Obtener perfil de usuario
  Future<Map<String, dynamic>> getUserProfile() async {
    if (!isAuthenticated) {
      throw Exception('Usuario no autenticado');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/users/$_userId'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener perfil: ${response.statusCode}');
      }
    } catch (e) {
      _logger.severe('Error de conexión: $e');
      throw Exception('Error de conexión: $e');
    }
  }
}
