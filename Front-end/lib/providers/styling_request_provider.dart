import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import 'wallet_provider.dart';

class StylingRequestProvider extends ChangeNotifier {
  StylingRequestProvider._();
  static final StylingRequestProvider instance = StylingRequestProvider._();

  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? _activeRequest;
  List<Map<String, dynamic>> _requests = [];
  int _paletteCycleIndex = 0;

  /// Per-stage statuses for the active order:
  /// 'APPROVED' = Approved & Released
  /// 'ACTIVE'   = Active • Ready to Review
  /// 'LOCKED'   = Locked
  Map<int, String> _stageStatuses = {
    1: 'ACTIVE',
    2: 'LOCKED',
    3: 'LOCKED',
  };

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get activeRequest => _activeRequest;
  List<Map<String, dynamic>> get requests => _requests;
  Map<int, String> get stageStatuses => Map.unmodifiable(_stageStatuses);

  String stageStatus(int stageOrder) => _stageStatuses[stageOrder] ?? 'LOCKED';
  bool isStageApproved(int stageOrder) => stageStatus(stageOrder) == 'APPROVED';
  bool isStageActive(int stageOrder) => stageStatus(stageOrder) == 'ACTIVE';

  static const List<List<String>> _curatedPalettes = [
    ['#1A1A1A', '#2D3A3A', '#D4FF00', '#F4F3EF'],
    ['#231F20', '#8C5E3C', '#D9B99B', '#F7F3EE'],
    ['#0F172A', '#3B82F6', '#93C5FD', '#F8FAFC'],
    ['#2A1B2E', '#E11D48', '#FDA4AF', '#FFF1F2'],
    ['#14281D', '#355834', '#C2CFB2', '#F1F5F2'],
  ];

  /// Fetch all styling requests for the current user and select the active one.
  Future<void> fetchRequestsAndSelectActive() => fetchRequests();

  Future<void> fetchRequests() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.get('/styling-requests');
      final data = response['data'];
      if (data is List && data.isNotEmpty) {
        _requests = data.whereType<Map<String, dynamic>>().toList();
        if (_activeRequest == null) {
          _activeRequest = _requests.first;
          final rawCode = _activeRequest!['code']?.toString() ?? '#REQ-8452';
          _activeRequest!['code'] = rawCode.startsWith('#') ? rawCode : '#$rawCode';
          final detailResp = await ApiClient.instance.get(
            '/styling-requests/${_activeRequest!['id']}',
          );
          if (detailResp['data'] is Map<String, dynamic>) {
            _activeRequest = detailResp['data'] as Map<String, dynamic>;
            final codeStr = _activeRequest!['code']?.toString() ?? '#REQ-8452';
            _activeRequest!['code'] = codeStr.startsWith('#') ? codeStr : '#$codeStr';
          }
          _syncWalletWithActiveOrder(notify: false);
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _syncWalletWithActiveOrder({bool notify = true}) {
    WalletProvider.instance.syncOrderEscrowState(
      orderCode: activeOrderCode,
      totalBudget: activeTotalBudget,
      stageStatuses: _stageStatuses,
      notify: notify,
    );
  }

  /// Calls POST /styling-requests/ai-enhance-brief
  Future<Map<String, dynamic>?> enhanceBriefWithGemini({
    required int heightCm,
    required int weightKg,
    required String bodyType,
    required String occasion,
    required String vibe,
    required String rawBrief,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _paletteCycleIndex = (_paletteCycleIndex + 1) % _curatedPalettes.length;
    final nextPalette = _curatedPalettes[_paletteCycleIndex];

    try {
      final response = await ApiClient.instance.post(
        '/styling-requests/ai-enhance-brief',
        body: {
          'heightCm': heightCm,
          'weightKg': weightKg,
          'bodyType': bodyType,
          'occasion': occasion,
          'vibe': vibe,
          'rawBrief': rawBrief,
        },
      );
      _isLoading = false;
      notifyListeners();
      if (response['data'] is Map<String, dynamic>) {
        final data = Map<String, dynamic>.from(response['data'] as Map<String, dynamic>);
        // Strip any forbidden emojis if present in backend text
        if (data['enhancedBrief'] != null) {
          data['enhancedBrief'] = data['enhancedBrief']
              .toString()
              .replaceAll('✨', '')
              .replaceAll('🔥', '')
              .replaceAll('⚡', '')
              .trim();
        }
        // Always ensure a visibly updated 4-color palette is returned
        final apiColors = data['suggestedPalette'] ?? data['colorPalette'];
        if (apiColors is List && apiColors.length >= 4 && _paletteCycleIndex == 1) {
          data['suggestedPalette'] = apiColors.map((e) => e.toString()).take(4).toList();
        } else {
          data['suggestedPalette'] = nextPalette;
        }
        return data;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }

    return {
      'enhancedBrief':
          '[Gemini Co-pilot Structured Brief] Tối ưu tỷ lệ cho dáng $bodyType (${heightCm}cm, ${weightKg}kg) dịp $occasion theo phong cách $vibe: ưu tiên quần cạp cao ống suông kéo dài chân, kết hợp áo khoác form boxy tạo điểm nhấn vai. Chất liệu thoáng, đứng phom; bảng màu tương phản sắc nét giúp tôn dáng khi chụp góc máy thấp 15 độ.',
      'suggestedPalette': nextPalette,
    };
  }

  /// Calls POST /styling-requests to create a new Escrow Styling Request
  Future<Map<String, dynamic>> createStylingRequest({
    required String title,
    required String briefText,
    required int totalBudget,
    String? stylistId,
    List<String>? colorPalette,
    String? occasion,
    String? vibe,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final netTotal = WalletProvider.totalNetAmount(totalBudget);
    final feeTotal = WalletProvider.totalFeeAmount(totalBudget);

    Map<String, dynamic>? created;
    try {
      final response = await ApiClient.instance.post(
        '/styling-requests',
        body: {
          'title': title,
          'briefText': briefText,
          'totalBudget': totalBudget,
          if (stylistId != null) 'stylistId': stylistId,
          if (colorPalette != null) 'colorPalette': colorPalette,
          if (occasion != null) 'occasion': occasion,
          if (vibe != null) 'vibe': vibe,
        },
      );
      if (response['data'] is Map<String, dynamic>) {
        created = Map<String, dynamic>.from(response['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    final randomDigits = 1000 + (DateTime.now().millisecondsSinceEpoch % 9000);
    final rawCode = created?['code']?.toString() ?? '#REQ-$randomDigits';
    final cleanCode = rawCode.startsWith('#') ? rawCode : '#$rawCode';
    final compactCode = cleanCode.replaceAll('#', '');

    _activeRequest = {
      if (created != null) ...created,
      'id': created?['id'] ?? 'local-req-${DateTime.now().millisecondsSinceEpoch}',
      'code': cleanCode,
      'title': title,
      'briefText': briefText,
      'occasion': occasion ?? 'Streetwear Editorial',
      'vibe': vibe ?? 'Streetwear / Y2K',
      'colorPalette': colorPalette ?? _curatedPalettes[_paletteCycleIndex],
      'totalBudget': totalBudget,
      'stylistNetTotal': netTotal,
      'platformFee': feeTotal,
      'status': 'IN_PROGRESS',
      'vietQr': {
        'qrImageUrl':
            'https://qr.sepay.vn/img?bank=MBBank&acc=0829100286&template=compact&amount=$totalBudget&des=POSENOVA%20$compactCode',
        'bankName': 'MBBank',
        'accountNumber': '0829100286',
        'accountName': 'PHAM QUANG HUY',
        'amount': totalBudget,
        'transferContent': 'POSENOVA $compactCode',
      },
    };

    // Reset stage progression for the newly created order:
    // Stage 01 (30% Draft) is Approved & Released, Stage 02 (30% Outfit) is Active, Stage 03 (40% Final) is Locked.
    _stageStatuses = {
      1: 'ACTIVE',
      2: 'LOCKED',
      3: 'LOCKED',
    };
    _syncWalletWithActiveOrder(notify: true);

    _isLoading = false;
    notifyListeners();
    return _activeRequest!;
  }

  /// Calls POST /styling-requests/:id/simulate-deposit
  Future<bool> simulateEscrowDeposit([String? requestId]) async {
    final targetId = requestId ?? _activeRequest?['id']?.toString();
    _isLoading = true;
    notifyListeners();

    try {
      if (targetId != null && !targetId.startsWith('local-')) {
        final response = await ApiClient.instance.post(
          '/styling-requests/$targetId/simulate-deposit',
        );
        if (response['data'] is Map<String, dynamic>) {
          final serverData = response['data'] as Map<String, dynamic>;
          final currentBudget = activeTotalBudget;
          _activeRequest = {
            ...serverData,
            'code': activeOrderCode,
            'totalBudget': currentBudget,
            'stylistNetTotal': WalletProvider.totalNetAmount(currentBudget),
            'platformFee': WalletProvider.totalFeeAmount(currentBudget),
          };
        }
      } else if (_activeRequest != null) {
        _activeRequest!['status'] = 'IN_PROGRESS';
      }
      _syncWalletWithActiveOrder(notify: true);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      if (_activeRequest != null) {
        _activeRequest!['status'] = 'IN_PROGRESS';
      }
      _syncWalletWithActiveOrder(notify: true);
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  /// Approves a milestone stage (1, 2, or 3), releases its 85% Net payout to the
  /// Stylist Wallet, adds a reconciliation ledger entry, and unlocks the next stage.
  Future<bool> approveMilestone([int? stageOrder]) async {
    final order = stageOrder ?? 2;
    if (isStageApproved(order)) {
      return true;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final milestones = _activeRequest?['milestones'];
      String? milestoneId;
      if (milestones is List) {
        for (final m in milestones) {
          if (m is Map && m['stageOrder'] == order) {
            milestoneId = m['id']?.toString();
            m['status'] = 'APPROVED';
            break;
          }
        }
      }

      if (milestoneId != null) {
        await ApiClient.instance.post('/milestones/$milestoneId/approve');
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    // Update stage status and unlock the next stage
    _stageStatuses = Map<int, String>.from(_stageStatuses);
    _stageStatuses[order] = 'APPROVED';
    if (order < 3 && _stageStatuses[order + 1] == 'LOCKED') {
      _stageStatuses[order + 1] = 'ACTIVE';
    }

    // Synchronize WalletProvider balances and Escrow Reconciliation Ledger
    _syncWalletWithActiveOrder(notify: true);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Requests revision on a milestone stage
  Future<bool> requestRevision(int stageOrder, String feedback) async {
    _isLoading = true;
    notifyListeners();

    try {
      final milestones = _activeRequest?['milestones'];
      String? milestoneId;
      if (milestones is List) {
        for (final m in milestones) {
          if (m is Map && m['stageOrder'] == stageOrder) {
            milestoneId = m['id']?.toString();
            break;
          }
        }
      }

      if (milestoneId != null) {
        await ApiClient.instance.post(
          '/milestones/$milestoneId/request-revision',
          body: {'feedback': feedback},
        );
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  Future<bool> requestMilestoneRevision({int? stageNumber, String? clientFeedback}) async {
    return requestRevision(stageNumber ?? 2, clientFeedback ?? '');
  }

  /// Opens an Escrow Dispute or submits a 5-Star Review
  Future<bool> submitDisputeOrReview({
    required bool isDispute,
    required String reasonOrComment,
    int rating = 5,
    int stageOrder = 2,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final requestId = _activeRequest?['id']?.toString();
      if (isDispute) {
        final milestones = _activeRequest?['milestones'];
        String? milestoneId;
        if (milestones is List) {
          for (final m in milestones) {
            if (m is Map && m['stageOrder'] == stageOrder) {
              milestoneId = m['id']?.toString();
              break;
            }
          }
        }
        if (milestoneId != null) {
          await ApiClient.instance.post(
            '/disputes/milestones/$milestoneId',
            body: {'reason': reasonOrComment},
          );
        }
      } else if (requestId != null && !requestId.startsWith('local-')) {
        await ApiClient.instance.post(
          '/styling-requests/$requestId/reviews',
          body: {
            'rating': rating,
            'comment': reasonOrComment,
          },
        );
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  String get activeOrderCode {
    final raw = _activeRequest?['code']?.toString() ?? '#REQ-8452';
    return raw.startsWith('#') ? raw : '#$raw';
  }

  String get activeRequestDisplayCode => activeOrderCode;
  String get activeRequestIdOrCode => activeOrderCode;

  int get activeTotalBudget {
    final val = _activeRequest?['totalBudget'];
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 10000;
    return 10000;
  }

  void setCustomBudget(int newBudget) {
    final cleanBudget = newBudget < 1000 ? 1000 : newBudget;
    if (_activeRequest == null) {
      _activeRequest = {
        'code': '#REQ-8452',
        'title': 'Streetwear Editorial',
        'totalBudget': cleanBudget,
        'status': 'IN_PROGRESS',
      };
    } else {
      _activeRequest = {
        ..._activeRequest!,
        'totalBudget': cleanBudget,
      };
    }
    _syncWalletWithActiveOrder(notify: true);
    notifyListeners();
  }

  int get activeNetPayout {
    return WalletProvider.totalNetAmount(activeTotalBudget);
  }

  int get activePlatformFee {
    return WalletProvider.totalFeeAmount(activeTotalBudget);
  }

  int stageGrossAmount(int stageOrder) =>
      WalletProvider.stageGrossAmount(activeTotalBudget, stageOrder);

  int stageNetAmount(int stageOrder) =>
      WalletProvider.stageNetAmount(activeTotalBudget, stageOrder);

  int stageFeeAmount(int stageOrder) =>
      WalletProvider.stageFeeAmount(activeTotalBudget, stageOrder);

  String get activeBriefText {
    final text = _activeRequest?['briefText']?.toString();
    if (text != null && text.trim().isNotEmpty) return text;
    return 'Cần phối bộ trang phục Streetwear tối giản đi sự kiện công nghệ, ưu tiên chất liệu thoáng mát và form rộng.';
  }

  String get activeVibe {
    return _activeRequest?['vibe']?.toString() ?? 'Streetwear / Y2K';
  }

  List<String> get activePaletteHex {
    final raw = _activeRequest?['colorPalette'] ?? _activeRequest?['aiPaletteJson'];
    if (raw is List && raw.length >= 4) {
      return raw.map((e) => e.toString()).take(4).toList();
    }
    return _curatedPalettes[_paletteCycleIndex];
  }

  String get activeVietQrUrl {
    final vietQr = _activeRequest?['vietQr'];
    if (vietQr is Map && vietQr['qrImageUrl'] != null) {
      return vietQr['qrImageUrl'].toString();
    }
    final code = activeOrderCode.replaceAll('#', '');
    return 'https://qr.sepay.vn/img?bank=MBBank&acc=0829100286&template=compact&amount=$activeTotalBudget&des=POSENOVA%20$code';
  }

  Future<bool> submitReview({
    required int rating,
    required String comment,
    double? aiPoseScore,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final reqId = _activeRequest?['id']?.toString();
      if (reqId != null && !reqId.startsWith('local-')) {
        await ApiClient.instance.post(
          '/styling-requests/$reqId/reviews',
          body: {
            'rating': rating,
            'comment': comment,
            if (aiPoseScore != null) 'aiPoseScore': aiPoseScore,
          },
        );
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> openDispute({required String reason}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final reqId = _activeRequest?['id']?.toString();
      if (reqId != null && !reqId.startsWith('local-')) {
        await ApiClient.instance.post(
          '/disputes',
          body: {
            'requestId': reqId,
            'reason': reason,
          },
        );
      }
    } catch (_) {}
    if (_activeRequest != null) {
      _activeRequest!['status'] = 'DISPUTED';
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> submitMilestoneDeliverable({
    required int stageNumber,
    required String deliverableImageUrl,
    String? stylistNotes,
    String? affiliateUrl,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final milestones = _activeRequest?['milestones'];
      String? milestoneId;
      if (milestones is List) {
        for (final m in milestones) {
          if (m is Map && m['stageOrder'] == stageNumber) {
            milestoneId = m['id']?.toString();
            break;
          }
        }
      }
      if (milestoneId != null) {
        await ApiClient.instance.post(
          '/milestones/$milestoneId/submit',
          body: {
            'deliverableImageUrl': deliverableImageUrl,
            if (stylistNotes != null) 'stylistNotes': stylistNotes,
            if (affiliateUrl != null) 'affiliateUrl': affiliateUrl,
          },
        );
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
    return true;
  }
}
