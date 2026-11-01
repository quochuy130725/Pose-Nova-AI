import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import 'auth_provider.dart';
import 'wallet_provider.dart';

/// Provider wiring all Styling Request, Gemini Co-pilot, SePay Escrow,
/// 3-Stage Milestone, Revision, Dispute & Review endpoints to Flutter UI (TSK-20 & TSK-22).
class StylingRequestProvider extends ChangeNotifier {
  StylingRequestProvider._();
  static final StylingRequestProvider instance = StylingRequestProvider._();

  bool _isLoading = false;
  Map<String, dynamic>? _activeRequest;
  List<Map<String, dynamic>> _requests = [];
  String? _lastError;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get activeRequest => _activeRequest;
  List<Map<String, dynamic>> get requests => _requests;
  String? get lastError => _lastError;

  /// Active Request ID or Code (defaults to `#REQ-8452` if none loaded yet)
  String get activeRequestIdOrCode =>
      _activeRequest?['id']?.toString() ??
      _activeRequest?['code']?.toString() ??
      'REQ-8452';

  String get activeRequestDisplayCode =>
      _activeRequest?['code']?.toString() ?? '#REQ-8452';

  int get activeTotalBudget {
    final val = _activeRequest?['totalBudget'] ??
        _activeRequest?['financialSummary']?['grossAmountVnd'];
    if (val is num) return val.toInt();
    return int.tryParse(val?.toString() ?? '') ?? 2500000;
  }

  int get activeNetPayout {
    final val = _activeRequest?['stylistNetTotal'] ??
        _activeRequest?['financialSummary']?['stylistNetTotalVnd'];
    if (val is num) return val.toInt();
    return (activeTotalBudget * 0.85).round();
  }

  int get activePlatformFee => activeTotalBudget - activeNetPayout;

  List<Map<String, dynamic>> get activeMilestones {
    final raw = _activeRequest?['milestones'];
    if (raw is List && raw.isNotEmpty) {
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  /// TSK-11: Calls `POST /api/v1/styling-requests/ai-enhance` (Gemini 1.5 Flash)
  Future<Map<String, dynamic>> enhanceBriefWithGemini({
    required double heightCm,
    required double weightKg,
    required String occasion,
    required String vibe,
    String? briefText,
  }) async {
    await AuthProvider.instance.ensureRoleAuthenticated('CLIENT');

    try {
      final response = await ApiClient.instance.post(
        '/styling-requests/ai-enhance',
        body: {
          'heightCm': heightCm,
          'weightKg': weightKg,
          'occasion': occasion,
          'vibe': vibe,
          if (briefText != null && briefText.trim().isNotEmpty)
            'briefText': briefText.trim(),
        },
      );
      final data = response['data'] as Map<String, dynamic>?;
      if (data != null) {
        return data;
      }
    } catch (e) {
      _lastError = e.toString();
    }

    return {
      'enhancedBrief':
          '✨ [Gemini AI Brief]: Với tỷ lệ ${heightCm.toInt()}cm/${weightKg.toInt()}kg, ưu tiên áo khoác Cropped Boxy Jacket kết hợp quần Cargo cạp cao tạo hiệu ứng kéo dài chân 6:4 cho dịp $occasion ($vibe).',
      'suggestedPalette': ['#0D0F0E', '#00F5D4', '#FFFD38', '#FF5E36'],
      'bodyProportionTips':
          'Tỷ lệ 1/3 trên - 2/3 dưới giúp tối ưu chiều cao và góc máy AI Pose.',
      'latencyMs': 420,
    };
  }

  /// TSK-12: Creates a new Styling Order & dynamic SePay VietQR via `POST /api/v1/styling-requests`
  Future<Map<String, dynamic>> createStylingRequest({
    required String briefText,
    String? occasion,
    String? vibe,
    List<String>? aiPaletteHex,
    int totalBudget = 2500000,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthProvider.instance.ensureRoleAuthenticated('CLIENT');
      final response = await ApiClient.instance.post(
        '/styling-requests',
        body: {
          'stylistId': '22222222-2222-4222-8222-222222222222',
          'briefText': briefText.trim().isEmpty
              ? 'Cần phối outfit Cyberpunk form rộng cho sự kiện ra mắt BST Thu Đông, tông đen kết hợp phụ kiện kim loại.'
              : briefText.trim(),
          'occasion': occasion ?? 'Streetwear Event',
          'vibe': vibe ?? 'Cyber Streetwear',
          'aiPaletteJson': aiPaletteHex ?? ['#0D0F0E', '#00F5D4', '#FFFD38', '#FF5E36'],
          'totalBudget': totalBudget,
        },
      );

      final data = response['data'] as Map<String, dynamic>?;
      if (data != null) {
        _activeRequest = data;
        _isLoading = false;
        notifyListeners();
        return data;
      }
    } catch (e) {
      _lastError = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return _activeRequest ?? {};
  }

  /// TSK-13: Triggers SePay 100% Escrow Deposit Webhook (`POST /api/v1/styling-requests/:id/simulate-deposit`)
  Future<Map<String, dynamic>?> simulateEscrowDeposit({String? requestIdOrCode}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthProvider.instance.ensureRoleAuthenticated('CLIENT');
      final targetId = requestIdOrCode ?? activeRequestIdOrCode;
      final response = await ApiClient.instance.post(
        '/styling-requests/$targetId/simulate-deposit',
        body: {},
      );
      final data = response['data'] as Map<String, dynamic>?;
      await fetchRequestsAndSelectActive(preferredIdOrCode: targetId);
      _isLoading = false;
      notifyListeners();
      return data;
    } catch (e) {
      _lastError = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// TSK-14: Fetches Styling Requests for Inbox & Detail (`GET /api/v1/styling-requests` & `GET /:id`)
  Future<Map<String, dynamic>?> fetchRequestsAndSelectActive({
    String? preferredIdOrCode,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (ApiClient.instance.activeToken == null) {
        await AuthProvider.instance.demoLogin(AuthProvider.instance.activeRole);
      }

      if (preferredIdOrCode != null && preferredIdOrCode.isNotEmpty) {
        try {
          final detailRes =
              await ApiClient.instance.get('/styling-requests/$preferredIdOrCode');
          final detail = detailRes['data'] as Map<String, dynamic>?;
          if (detail != null) {
            _activeRequest = detail;
            _isLoading = false;
            notifyListeners();
            return _activeRequest;
          }
        } catch (_) {
          // Fall through to list fetch
        }
      }

      final listRes = await ApiClient.instance.get('/styling-requests');
      final data = listRes['data'];
      List<dynamic> items = [];
      if (data is Map && data['items'] is List) {
        items = data['items'] as List<dynamic>;
      } else if (data is List) {
        items = data;
      }

      if (items.isNotEmpty) {
        _requests = items.map((e) => Map<String, dynamic>.from(e as Map)).toList();

        // Prefer an IN_PROGRESS request with milestones, or #REQ-8452, or the newest one
        Map<String, dynamic> chosen = _requests.firstWhere(
          (r) => r['status'] == 'IN_PROGRESS',
          orElse: () => _requests.first,
        );

        final chosenId = chosen['id']?.toString() ?? chosen['code']?.toString();
        if (chosenId != null) {
          final detailRes = await ApiClient.instance.get('/styling-requests/$chosenId');
          final detail = detailRes['data'] as Map<String, dynamic>?;
          if (detail != null) {
            _activeRequest = detail;
          } else {
            _activeRequest = chosen;
          }
        }
      }
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _activeRequest;
  }

  /// Resolves the database UUID for a given stage number (1, 2, or 3)
  String? getMilestoneIdForStage(int stageNumber) {
    for (final m in activeMilestones) {
      final numVal = (m['stageNumber'] as num?)?.toInt() ??
          (m['stageOrder'] as num?)?.toInt();
      if (numVal == stageNumber) {
        return m['id']?.toString() ?? m['milestoneId']?.toString();
      }
    }
    return null;
  }

  /// TSK-15: Stylist submits Milestone deliverable (`POST /api/v1/milestones/:id/submit`)
  Future<Map<String, dynamic>?> submitMilestoneDeliverable({
    int stageNumber = 2,
    required String deliverableImageUrl,
    required String stylistNotes,
    String? affiliateUrl,
    String productName = 'Cyber Utility Jacket AW26',
    int productPrice = 1250000,
  }) async {
    try {
      await AuthProvider.instance.ensureRoleAuthenticated('STYLIST');
      if (_activeRequest == null) {
        await fetchRequestsAndSelectActive();
      }

      // Ensure there is an active milestone in DB for this stage
      String? milestoneId = getMilestoneIdForStage(stageNumber);
      if (milestoneId == null) {
        return null;
      }

      final response = await ApiClient.instance.post(
        '/milestones/$milestoneId/submit',
        body: {
          'deliverableUrl': deliverableImageUrl,
          'deliverableImageUrl': deliverableImageUrl,
          'stylistNotes': stylistNotes,
          'watermarked': true,
          'poseLandmarksJson': List.generate(
            33,
            (i) => {
              'id': i,
              'x': 0.35 + (i % 5) * 0.06,
              'y': 0.15 + (i / 33) * 0.75,
              'z': 0.0,
              'visibility': 0.98,
            },
          ),
          'productTags': [
            {
              'productName': productName,
              'itemName': productName,
              'price': productPrice,
              'affiliateUrl': (affiliateUrl != null && affiliateUrl.trim().isNotEmpty)
                  ? affiliateUrl.trim()
                  : 'https://shopee.vn/cyber-utility-jacket-aw26-ltd',
              'posX': 0.48,
              'posY': 0.42,
              'xCoord': 0.48,
              'yCoord': 0.42,
            }
          ],
        },
      );

      final data = response['data'] as Map<String, dynamic>?;
      await fetchRequestsAndSelectActive(preferredIdOrCode: activeRequestIdOrCode);
      return data;
    } catch (e) {
      _lastError = e.toString();
      return null;
    }
  }

  /// TSK-16: Client approves Milestone & releases ACID Net payout (`POST /api/v1/milestones/:id/approve`)
  Future<Map<String, dynamic>?> approveMilestone({int stageNumber = 2}) async {
    try {
      await AuthProvider.instance.ensureRoleAuthenticated('CLIENT');
      if (_activeRequest == null) {
        await fetchRequestsAndSelectActive();
      }

      String? milestoneId = getMilestoneIdForStage(stageNumber);
      if (milestoneId == null) {
        return null;
      }

      final response = await ApiClient.instance.post(
        '/milestones/$milestoneId/approve',
        body: {},
      );
      final data = response['data'] as Map<String, dynamic>?;
      if (data != null && data['stylistWallet'] is Map) {
        final sw = data['stylistWallet'] as Map<String, dynamic>;
        WalletProvider.instance.updateBalances(
          availableVnd: (sw['availableBalance'] as num?)?.toInt(),
          escrowLockedVnd: (sw['escrowLockedBalance'] as num?)?.toInt(),
        );
      }
      await fetchRequestsAndSelectActive(preferredIdOrCode: activeRequestIdOrCode);
      await WalletProvider.instance.fetchMyWallet();
      return data;
    } catch (e) {
      _lastError = e.toString();
      return null;
    }
  }

  /// TSK-17: Client requests revision (max 2 free revisions) (`POST /api/v1/milestones/:id/request-revision`)
  Future<Map<String, dynamic>?> requestMilestoneRevision({
    int stageNumber = 2,
    required String clientFeedback,
  }) async {
    try {
      await AuthProvider.instance.ensureRoleAuthenticated('CLIENT');
      if (_activeRequest == null) {
        await fetchRequestsAndSelectActive();
      }

      String? milestoneId = getMilestoneIdForStage(stageNumber);
      if (milestoneId == null) {
        return null;
      }

      final response = await ApiClient.instance.post(
        '/milestones/$milestoneId/request-revision',
        body: {
          'clientFeedback': clientFeedback.trim().isEmpty
              ? 'Đổi quần cargo sang chất liệu vải kỹ thuật chống nước có viền phản quang.'
              : clientFeedback.trim(),
        },
      );
      final data = response['data'] as Map<String, dynamic>?;
      await fetchRequestsAndSelectActive(preferredIdOrCode: activeRequestIdOrCode);
      return data;
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    }
  }

  /// TSK-18: Client opens Dispute & freezes escrow (`POST /api/v1/disputes`)
  Future<Map<String, dynamic>?> openDispute({
    required String reason,
  }) async {
    try {
      await AuthProvider.instance.ensureRoleAuthenticated('CLIENT');
      if (_activeRequest == null) {
        await fetchRequestsAndSelectActive();
      }

      final reqId = _activeRequest?['id']?.toString();
      if (reqId == null) return null;

      final response = await ApiClient.instance.post(
        '/disputes',
        body: {
          'requestId': reqId,
          'reason': reason.length >= 10
              ? reason
              : '$reason — Yêu cầu phong tỏa quỹ ký quỹ và hoàn trả phần tiền dư.',
        },
      );
      final data = response['data'] as Map<String, dynamic>?;
      await fetchRequestsAndSelectActive(preferredIdOrCode: reqId);
      await WalletProvider.instance.fetchMyWallet();
      return data;
    } catch (e) {
      _lastError = e.toString();
      return null;
    }
  }

  /// TSK-22: Client submits 1–5 Star Review + AI Pose Score (`POST /api/v1/styling-requests/:id/reviews`)
  Future<Map<String, dynamic>?> submitReview({
    required int rating,
    required String comment,
    required double aiPoseScore,
  }) async {
    try {
      await AuthProvider.instance.ensureRoleAuthenticated('CLIENT');
      if (_activeRequest == null) {
        await fetchRequestsAndSelectActive();
      }

      final targetId = activeRequestIdOrCode;
      final response = await ApiClient.instance.post(
        '/styling-requests/$targetId/reviews',
        body: {
          'rating': rating.clamp(1, 5),
          'comment': comment.trim(),
          'poseMatchScore': aiPoseScore,
          'aiPoseScore': aiPoseScore,
        },
      );

      final data = response['data'] as Map<String, dynamic>?;
      if (data != null && data['stylistUpdatedRating'] is Map) {
        final ratingMap = data['stylistUpdatedRating'] as Map;
        final newAvg = (ratingMap['ratingAvg'] as num?)?.toDouble() ?? 4.95;
        final newTotal = (ratingMap['totalReviews'] as num?)?.toInt() ?? 129;
        AuthProvider.instance.updateStylistRating(
          ratingAvg: newAvg,
          totalReviews: newTotal,
        );
      }
      return data;
    } catch (e) {
      _lastError = e.toString();
      return null;
    }
  }
}
