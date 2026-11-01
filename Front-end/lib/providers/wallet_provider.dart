import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import 'auth_provider.dart';

/// Provider managing Cyber Wallet, Reconciliation Ledger & Bank Withdrawal (TSK-19 & TSK-20)
class WalletProvider extends ChangeNotifier {
  WalletProvider._();
  static final WalletProvider instance = WalletProvider._();

  bool _isLoading = false;
  int _availableBalanceVnd = 765000;
  int _escrowLockedVnd = 850000;
  final String _walletId = 'WAL-STY-8452 (Maya Trần)';
  Map<String, dynamic>? _reconciliation;
  List<Map<String, dynamic>> _ledger = [];
  String? _lastError;

  bool get isLoading => _isLoading;
  int get availableBalanceVnd => _availableBalanceVnd;
  int get escrowLockedVnd => _escrowLockedVnd;
  String get walletId => _walletId;
  Map<String, dynamic>? get reconciliation => _reconciliation;
  List<Map<String, dynamic>> get ledger => _ledger;
  String? get lastError => _lastError;

  /// Updates balances locally when user profile or role change delivers updated numbers
  void updateBalances({int? availableVnd, int? escrowLockedVnd}) {
    bool changed = false;
    if (availableVnd != null && availableVnd != _availableBalanceVnd) {
      _availableBalanceVnd = availableVnd;
      changed = true;
    }
    if (escrowLockedVnd != null && escrowLockedVnd != _escrowLockedVnd) {
      _escrowLockedVnd = escrowLockedVnd;
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }

  /// Fetches live Stylist Wallet & Reconciliation Ledger via `GET /api/v1/wallets/me`
  Future<void> fetchMyWallet() async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthProvider.instance.ensureRoleAuthenticated('STYLIST');
      final response = await ApiClient.instance.get(
        '/wallets/me',
        overrideToken: ApiClient.instance.stylistToken,
      );

      final data = response['data'] as Map<String, dynamic>?;
      if (data != null) {
        final wallet = data['wallet'] as Map<String, dynamic>?;
        if (wallet != null) {
          _availableBalanceVnd =
              (wallet['availableBalance'] as num?)?.toInt() ?? _availableBalanceVnd;
          _escrowLockedVnd =
              (wallet['escrowLockedBalance'] as num?)?.toInt() ??
              (wallet['escrowLocked'] as num?)?.toInt() ??
              _escrowLockedVnd;
        }
        if (data['reconciliation'] is Map<String, dynamic>) {
          _reconciliation = data['reconciliation'] as Map<String, dynamic>;
        }
        if (data['ledger'] is List) {
          _ledger = (data['ledger'] as List<dynamic>)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
      }
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Withdraws available balance to linked bank account via `POST /api/v1/wallets/withdraw`
  Future<Map<String, dynamic>?> withdrawToBank({int? amountVnd}) async {
    try {
      await AuthProvider.instance.ensureRoleAuthenticated('STYLIST');
      final withdrawAmount = amountVnd ??
          (_availableBalanceVnd >= 100000 ? 200000 : _availableBalanceVnd);
      if (withdrawAmount < 50000) {
        return null;
      }

      final response = await ApiClient.instance.post(
        '/wallets/withdraw',
        overrideToken: ApiClient.instance.stylistToken,
        body: {'amount': withdrawAmount},
      );

      final data = response['data'] as Map<String, dynamic>?;
      await fetchMyWallet();
      return data;
    } catch (e) {
      _lastError = e.toString();
      return null;
    }
  }
}
