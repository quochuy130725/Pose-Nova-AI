import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import 'wallet_provider.dart';

/// Provider managing Authentication & 1-Tap Role Switching between
/// Client (Alex Đỗ) and Stylist Studio (Maya Trần) on the same device (TSK-20).
class AuthProvider extends ChangeNotifier {
  AuthProvider._();
  static final AuthProvider instance = AuthProvider._();

  String _activeRole = 'CLIENT';
  bool _isLoading = false;
  bool _isBackendConnected = false;
  String? _lastError;

  final List<Map<String, String>> _knownAccounts = [
    {
      'name': 'Alex Đỗ',
      'email': 'alex.do@gmail.com',
      'role': 'CLIENT',
      'subtitle': 'Khách hàng (Client)',
      'avatarUrl':
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Maya Trần',
      'email': 'maya.tran@posenova.com',
      'role': 'STYLIST',
      'subtitle': 'Top Stylist Studio',
      'avatarUrl':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
    },
  ];

  List<Map<String, String>> get knownAccounts => _knownAccounts;

  Map<String, dynamic> _clientUser = {
    'id': '11111111-1111-4111-8111-111111111111',
    'email': 'alex.do@posenova.ai',
    'role': 'CLIENT',
    'fullName': 'Alex Đỗ',
    'avatarUrl':
        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&auto=format&fit=crop&q=80',
    'heightCm': 175,
    'weightKg': 65,
    'bodyShape': 'ATHLETIC_RECTANGLE',
  };

  Map<String, dynamic> _stylistUser = {
    'id': '22222222-2222-4222-8222-222222222222',
    'email': 'maya.tran@posenova.ai',
    'role': 'STYLIST',
    'fullName': 'Maya Trần',
    'avatarUrl':
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
    'bio': 'Personal Stylist • Street-Zine & Cyber Atelier',
    'ratingAvg': 4.92,
    'totalReviews': 128,
  };

  String get activeRole => _activeRole;
  bool get isLoading => _isLoading;
  bool get isBackendConnected => _isBackendConnected;
  String? get lastError => _lastError;

  Map<String, dynamic> get currentUser =>
      _activeRole == 'STYLIST' ? _stylistUser : _clientUser;
  Map<String, dynamic> get clientUser => _clientUser;
  Map<String, dynamic> get stylistUser => _stylistUser;

  double get stylistRatingAvg {
    final val = _stylistUser['ratingAvg'] ??
        (_stylistUser['stylistProfile'] is Map
            ? _stylistUser['stylistProfile']['ratingAvg']
            : null);
    if (val is num) return val.toDouble();
    return double.tryParse(val?.toString() ?? '') ?? 4.92;
  }

  int get stylistTotalReviews {
    final val = _stylistUser['totalReviews'] ??
        (_stylistUser['stylistProfile'] is Map
            ? _stylistUser['stylistProfile']['totalReviews']
            : null);
    if (val is num) return val.toInt();
    return int.tryParse(val?.toString() ?? '') ?? 128;
  }

  /// Logs into the real Back-End via `POST /api/v1/auth/demo-login`
  Future<bool> demoLogin(String role) async {
    final normalizedRole = role.toUpperCase() == 'STYLIST' ? 'STYLIST' : 'CLIENT';
    _activeRole = normalizedRole;
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        '/auth/demo-login',
        body: {'role': normalizedRole},
      );

      final data = response['data'] as Map<String, dynamic>? ?? {};
      final token = data['token']?.toString() ?? '';
      final user = data['user'] as Map<String, dynamic>?;

      if (token.isNotEmpty) {
        ApiClient.instance.setRoleToken(role: normalizedRole, token: token);
        _isBackendConnected = true;
      }

      if (user != null) {
        if (normalizedRole == 'STYLIST') {
          _stylistUser = {..._stylistUser, ...user};
        } else {
          _clientUser = {..._clientUser, ...user};
        }
        if (user['wallet'] is Map) {
          final w = user['wallet'] as Map<String, dynamic>;
          WalletProvider.instance.updateBalances(
            availableVnd: (w['availableBalance'] as num?)?.toInt(),
            escrowLockedVnd: (w['escrowLockedBalance'] as num?)?.toInt(),
          );
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = e.toString();
      _isLoading = false;
      ApiClient.instance.activateRole(normalizedRole);
      notifyListeners();
      return false;
    }
  }

  /// Standard user registration via `POST /api/v1/auth/register`
  Future<bool> registerAccount({
    required String fullName,
    required String email,
    required String password,
    required String role,
    int? heightCm,
    int? weightKg,
    String? bio,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final normalizedRole = role.toUpperCase() == 'STYLIST' ? 'STYLIST' : 'CLIENT';
      final response = await ApiClient.instance.post(
        '/auth/register',
        body: {
          'fullName': fullName.trim(),
          'email': email.trim().toLowerCase(),
          'password': password.trim(),
          'role': normalizedRole,
          if (heightCm != null && heightCm > 0) 'heightCm': heightCm,
          if (weightKg != null && weightKg > 0) 'weightKg': weightKg,
          if (bio != null && bio.isNotEmpty) 'bio': bio,
        },
      );

      final data = response['data'] as Map<String, dynamic>? ?? {};
      final token = data['token']?.toString() ?? '';
      final user = data['user'] as Map<String, dynamic>? ?? {};
      final createdRole = (user['role']?.toString() ?? normalizedRole).toUpperCase();

      _activeRole = createdRole;
      if (token.isNotEmpty) {
        ApiClient.instance.setRoleToken(role: _activeRole, token: token);
        _isBackendConnected = true;
      }

      if (_activeRole == 'STYLIST') {
        _stylistUser = {..._stylistUser, ...user};
      } else {
        _clientUser = {..._clientUser, ...user};
      }

      // Add to known accounts list for fast re-login
      final existingIdx = _knownAccounts.indexWhere(
        (acc) => acc['email']?.toLowerCase() == email.trim().toLowerCase(),
      );
      final newAccountEntry = {
        'name': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'role': _activeRole,
        'subtitle': _activeRole == 'STYLIST' ? 'Stylist Studio' : 'Khách hàng',
        'avatarUrl': user['avatarUrl']?.toString() ??
            (_activeRole == 'STYLIST'
                ? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80'
                : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&auto=format&fit=crop&q=80'),
      };

      if (existingIdx != -1) {
        _knownAccounts[existingIdx] = newAccountEntry;
      } else {
        _knownAccounts.insert(0, newAccountEntry);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = e is ApiException ? e.message : e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Standard email/password login via `POST /api/v1/auth/login`
  Future<bool> loginWithCredentials({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        '/auth/login',
        body: {
          'email': email.trim().toLowerCase(),
          'password': password.trim(),
        },
      );
      final data = response['data'] as Map<String, dynamic>? ?? {};
      final token = data['token']?.toString() ?? '';
      final user = data['user'] as Map<String, dynamic>? ?? {};
      final role = (user['role']?.toString() ?? 'CLIENT').toUpperCase();

      _activeRole = role == 'STYLIST' ? 'STYLIST' : 'CLIENT';
      if (token.isNotEmpty) {
        ApiClient.instance.setRoleToken(role: _activeRole, token: token);
        _isBackendConnected = true;
      }
      if (_activeRole == 'STYLIST') {
        _stylistUser = {..._stylistUser, ...user};
      } else {
        _clientUser = {..._clientUser, ...user};
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Seamless 1-Tap Role Switcher on the same device (Client <-> Stylist)
  Future<void> switchRole(String targetRole) async {
    final normalizedRole =
        targetRole.toUpperCase() == 'STYLIST' ? 'STYLIST' : 'CLIENT';
    _activeRole = normalizedRole;
    ApiClient.instance.activateRole(normalizedRole);
    notifyListeners();

    final existingToken = normalizedRole == 'STYLIST'
        ? ApiClient.instance.stylistToken
        : ApiClient.instance.clientToken;

    if (existingToken == null || existingToken.isEmpty) {
      await demoLogin(normalizedRole);
    } else {
      await refreshCurrentProfile();
    }
  }

  /// Ensures both Client and Stylist tokens are pre-warmed for instant switching
  Future<void> ensureRoleAuthenticated(String role) async {
    final normalizedRole = role.toUpperCase() == 'STYLIST' ? 'STYLIST' : 'CLIENT';
    final existingToken = normalizedRole == 'STYLIST'
        ? ApiClient.instance.stylistToken
        : ApiClient.instance.clientToken;
    if (existingToken == null || existingToken.isEmpty) {
      await demoLogin(normalizedRole);
    } else {
      _activeRole = normalizedRole;
      ApiClient.instance.activateRole(normalizedRole);
      notifyListeners();
    }
  }

  Future<void> refreshCurrentProfile() async {
    try {
      final response = await ApiClient.instance.get('/auth/me');
      final data = response['data'] as Map<String, dynamic>?;
      if (data != null) {
        _isBackendConnected = true;
        final role = (data['role']?.toString() ?? _activeRole).toUpperCase();
        if (role == 'STYLIST') {
          _stylistUser = {..._stylistUser, ...data};
        } else {
          _clientUser = {..._clientUser, ...data};
        }
        if (data['wallet'] is Map) {
          final w = data['wallet'] as Map<String, dynamic>;
          WalletProvider.instance.updateBalances(
            availableVnd: (w['availableBalance'] as num?)?.toInt(),
            escrowLockedVnd: (w['escrowLockedBalance'] as num?)?.toInt(),
          );
        }
        notifyListeners();
      }
    } catch (_) {
      // Keep cached user profile
    }
  }

  void updateStylistRating({
    required double ratingAvg,
    required int totalReviews,
  }) {
    _stylistUser = {
      ..._stylistUser,
      'ratingAvg': ratingAvg,
      'totalReviews': totalReviews,
    };
    notifyListeners();
  }
}
