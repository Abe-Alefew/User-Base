import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com';
  static const int _pageSize = 10;

    // READ — GET /users?limit=10&skip=0
    Future<List<User>> getUsers({int page = 1}) async {
    try {
      final int skip = (page - 1) * _pageSize;
      final response = await http.get(
        Uri.parse('$baseUrl/users?limit=$_pageSize&skip=$skip'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final List<dynamic> data = body['users'] ?? [];
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: 'Failed to fetch users',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
       print('ERROR FETCHING USERS: $e');  // check flutter run terminal
      throw ApiException(message: 'Network error: ${e.toString()}');
    }
  }

    // READ — GET /users/:id
    Future<User> getUserById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        return User.fromJson(body);
      } else if (response.statusCode == 404) {
        throw ApiException(message: 'User not found', statusCode: 404);
      } else {
        throw ApiException(
          message: 'Failed to fetch user',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Network error: ${e.toString()}');
    }
  }

    // CREATE — POST /users/add
    Future<User> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/add'),
        headers: _headers,
        body: json.encode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body = json.decode(response.body);
        return User.fromJson(body);
      } else {
        throw ApiException(
          message: 'Failed to create user',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Network error: ${e.toString()}');
    }
  }

    // UPDATE — PUT /users/:id
    Future<User> updateUser({
    required int id,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$id'),
        headers: _headers,
        body: json.encode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        return User.fromJson(body);
      } else {
        throw ApiException(
          message: 'Failed to update user',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Network error: ${e.toString()}');
    }
  }

    // DELETE — DELETE /users/:id
    Future<void> deleteUser(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$id'),
        headers: _headers,
      );

      // DummyJSON returns 200 with the deleted user payload.
      // For users created via /users/add, the API does not persist them,
      // so delete can return 404 — treat that as a successful local delete.
      if (response.statusCode != 200 && response.statusCode != 204 && response.statusCode != 404) {
        throw ApiException(
          message: 'Failed to delete user',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Network error: ${e.toString()}');
    }
  }

    // Shared headers
    Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        
      };
}

// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() {
    return statusCode != null
        ? 'ApiException [$statusCode]: $message'
        : 'ApiException: $message';
  }
}