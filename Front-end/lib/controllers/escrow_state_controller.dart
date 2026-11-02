import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/styling_request_provider.dart';
import '../providers/wallet_provider.dart';

/// Global State Controller for Escrow Workspace & Active Styling Orders
/// Ensures active orders, deliverable submissions, and milestone stage progression
/// are never lost across screens, navigation tabs, or app restarts.
class EscrowStateController extends ChangeNotifier {
  EscrowStateController._();
  static final EscrowStateController instance = EscrowStateController._();

  static const String _storageKeyOrder = 'posenova_active_escrow_order_v2';
  static const String _storageKeyStages = 'posenova_escrow_stages_v2';
  static const String _storageKeyDeliverables = 'posenova_stage_deliverables_v2';

  Map<String, dynamic>? _cachedOrder;
  Map<int, String> _cachedStageStatuses = {
    1: 'ACTIVE',
    2: 'LOCKED',
    3: 'LOCKED',
  };
  final Map<int, Map<String, dynamic>> _stageDeliverables = {};
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Active styling order request map
  Map<String, dynamic>? get activeStylingRequest =>
      _cachedOrder ?? StylingRequestProvider.instance.activeRequest;

  bool get hasActiveOrder => activeStylingRequest != null;

  String get activeOrderCode {
    final raw = activeStylingRequest?['code']?.toString() ?? '';
    if (raw.isEmpty) return '';
    return raw.startsWith('#') ? raw : '#$raw';
  }

  int get activeTotalBudget {
    final val = activeStylingRequest?['totalBudget'];
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return StylingRequestProvider.instance.activeTotalBudget;
  }

  Map<int, String> get stageStatuses => Map.unmodifiable(_cachedStageStatuses);

  String stageStatus(int stageOrder) =>
      _cachedStageStatuses[stageOrder] ??
      StylingRequestProvider.instance.stageStatus(stageOrder);

  bool isStageApproved(int stageOrder) => stageStatus(stageOrder) == 'APPROVED';
  bool isStageInReview(int stageOrder) => stageStatus(stageOrder) == 'IN_REVIEW';
  bool isStageActive(int stageOrder) => stageStatus(stageOrder) == 'ACTIVE';
  bool isStageLocked(int stageOrder) => stageStatus(stageOrder) == 'LOCKED';

  Map<int, Map<String, dynamic>> get stageDeliverables =>
      Map.unmodifiable(_stageDeliverables);

  Map<String, dynamic>? stageDeliverable(int stageOrder) =>
      _stageDeliverables[stageOrder];

  String? stageDeliverableImageUrl(int stageOrder) =>
      _stageDeliverables[stageOrder]?['imageUrl']?.toString();

  String? stageDeliverableNotes(int stageOrder) =>
      _stageDeliverables[stageOrder]?['notes']?.toString();

  String? stageDeliverableAffiliate(int stageOrder) =>
      _stageDeliverables[stageOrder]?['affiliateUrl']?.toString();

  bool hasStageDeliverable(int stageOrder) {
    final url = stageDeliverableImageUrl(stageOrder);
    return url != null && url.isNotEmpty;
  }

  /// Initializes controller from persistent storage (SharedPreferences)
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final orderJson = prefs.getString(_storageKeyOrder);
      if (orderJson != null && orderJson.isNotEmpty) {
        final decoded = jsonDecode(orderJson);
        if (decoded is Map<String, dynamic>) {
          final code = decoded['code']?.toString() ?? '';
          final budget = decoded['totalBudget'];
          // Purge stale mock order (#REQ-8452 or 2.500.000đ mock)
          if (code.contains('8452') || budget == 2500000) {
            await prefs.remove(_storageKeyOrder);
            await prefs.remove(_storageKeyStages);
            await prefs.remove(_storageKeyDeliverables);
            _cachedOrder = null;
          } else {
            _cachedOrder = decoded;
            StylingRequestProvider.instance.restoreActiveRequest(decoded);
          }
        }
      }

      final stagesJson = prefs.getString(_storageKeyStages);
      if (stagesJson != null && stagesJson.isNotEmpty) {
        final decodedStages = jsonDecode(stagesJson);
        if (decodedStages is Map) {
          final mapped = <int, String>{};
          decodedStages.forEach((k, v) {
            final order = int.tryParse(k.toString());
            if (order != null && v is String) {
              mapped[order] = v;
            }
          });
          if (mapped.isNotEmpty) {
            _cachedStageStatuses = mapped;
            StylingRequestProvider.instance.restoreStageStatuses(mapped);
          }
        }
      }

      final deliverablesJson = prefs.getString(_storageKeyDeliverables);
      if (deliverablesJson != null && deliverablesJson.isNotEmpty) {
        final decodedDelivs = jsonDecode(deliverablesJson);
        if (decodedDelivs is Map) {
          decodedDelivs.forEach((k, v) {
            final order = int.tryParse(k.toString());
            if (order != null && v is Map) {
              _stageDeliverables[order] = Map<String, dynamic>.from(v);
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error restoring EscrowStateController: $e');
    } finally {
      _isInitialized = true;
      _syncWallet();
      notifyListeners();
    }
  }

  void _syncWallet() {
    if (hasActiveOrder) {
      WalletProvider.instance.syncOrderEscrowState(
        orderCode: activeOrderCode,
        totalBudget: activeTotalBudget,
        stageStatuses: _cachedStageStatuses,
        notify: true,
      );
    }
  }

  /// Saves the active order into memory and persistent storage
  Future<void> saveActiveOrder(Map<String, dynamic> order) async {
    _cachedOrder = Map<String, dynamic>.from(order);
    StylingRequestProvider.instance.restoreActiveRequest(_cachedOrder!);
    _syncWallet();
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKeyOrder, jsonEncode(_cachedOrder));
    } catch (e) {
      debugPrint('Error saving active order: $e');
    }
  }

  /// Saves a deliverable submitted by Stylist for a specific stage
  Future<void> saveStageDeliverable({
    required int stageOrder,
    required String imageUrl,
    String? notes,
    String? affiliateUrl,
  }) async {
    _stageDeliverables[stageOrder] = {
      'imageUrl': imageUrl,
      if (notes != null) 'notes': notes,
      if (affiliateUrl != null) 'affiliateUrl': affiliateUrl,
      'submittedAt': DateTime.now().toIso8601String(),
    };
    await updateStageStatus(stageOrder, 'IN_REVIEW');

    try {
      final prefs = await SharedPreferences.getInstance();
      final stringMap =
          _stageDeliverables.map((k, v) => MapEntry(k.toString(), v));
      await prefs.setString(_storageKeyDeliverables, jsonEncode(stringMap));
    } catch (e) {
      debugPrint('Error saving deliverables: $e');
    }
  }

  /// Updates a milestone stage status (e.g. 'APPROVED', 'IN_REVIEW', 'ACTIVE', 'LOCKED')
  Future<void> updateStageStatus(int stageOrder, String status) async {
    _cachedStageStatuses = Map<int, String>.from(_cachedStageStatuses);
    _cachedStageStatuses[stageOrder] = status;
    StylingRequestProvider.instance.setStageStatus(stageOrder, status);
    _syncWallet();
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final stringMap =
          _cachedStageStatuses.map((k, v) => MapEntry(k.toString(), v));
      await prefs.setString(_storageKeyStages, jsonEncode(stringMap));
    } catch (e) {
      debugPrint('Error saving stage statuses: $e');
    }
  }

  /// Approves a milestone and unlocks the subsequent milestone
  Future<void> approveMilestone(int stageOrder) async {
    await updateStageStatus(stageOrder, 'APPROVED');
    if (stageOrder < 3 && stageStatus(stageOrder + 1) == 'LOCKED') {
      await updateStageStatus(stageOrder + 1, 'ACTIVE');
    }
  }

  /// Clears the active order completely (e.g. on contract completion or dispute refund)
  Future<void> clearActiveOrder() async {
    _cachedOrder = null;
    _cachedStageStatuses = {
      1: 'ACTIVE',
      2: 'LOCKED',
      3: 'LOCKED',
    };
    _stageDeliverables.clear();
    StylingRequestProvider.instance.clearActiveRequest();
    WalletProvider.instance.clearActiveOrderState(notify: true);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKeyOrder);
      await prefs.remove(_storageKeyStages);
      await prefs.remove(_storageKeyDeliverables);
    } catch (e) {
      debugPrint('Error clearing active order: $e');
    }
  }
}
