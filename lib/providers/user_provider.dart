import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

    // State
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePages = true;

    // Getters — UI reads these, never _private fields
  List<User> get users => List.unmodifiable(_users);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMorePages => _hasMorePages;
  bool get hasError => _error != null;

    // READ — fetch page of users
  Future<void> fetchUsers({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMorePages = true;
      _users = [];
    }

    if (!_hasMorePages || _isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      final newUsers = await _apiService.getUsers(page: _currentPage);

      if (newUsers.isEmpty) {
        _hasMorePages = false;
      } else {
        _users = refresh ? newUsers : [..._users, ...newUsers];
        _currentPage++;
      }
    } on ApiException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Something went wrong. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

    // CREATE — add a new user
    Future<bool> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final newUser = await _apiService.createUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
      );

      // Prepend so the new user appears at the top of the list
      _users = [newUser, ..._users];
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to create user. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

    // UPDATE — edit an existing user
    Future<bool> updateUser({
    required int id,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedUser = await _apiService.updateUser(
        id: id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
      );

      // Replace only the updated user in the list
      _users = _users.map((user) {
        if (user.id != id) return user;
        return updatedUser.copyWith(
          // Preserve fields that may not be echoed back
          email: updatedUser.email.isNotEmpty ? updatedUser.email : user.email,
          phone: updatedUser.phone.isNotEmpty ? updatedUser.phone : user.phone,
          image: updatedUser.image.isNotEmpty ? updatedUser.image : user.image,
        );
      }).toList();

      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to update user. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

    // DELETE — remove a user
    Future<bool> deleteUser(int id) async {
    _setLoading(true);
    _clearError();

    try {
      await _apiService.deleteUser(id);

      // Remove from local list by id
      _users = _users.where((user) => user.id != id).toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to delete user. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

    // Helpers — keep state updates DRY
    void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}