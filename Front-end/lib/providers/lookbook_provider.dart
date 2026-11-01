import 'package:flutter/material.dart';
import '../core/network/api_client.dart';

/// Lookbook duoc chon de lam tu the muc tieu (Target) cho man hinh Camera AI.
class PoseLookbook {
  final String id;
  final String title;
  final String imageUrl;
  final dynamic poseLandmarksJson;

  const PoseLookbook({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.poseLandmarksJson,
  });

  factory PoseLookbook.fromMap(Map<String, dynamic> map) {
    final title = map['title']?.toString() ?? 'Lookbook';
    return PoseLookbook(
      id: map['id']?.toString() ?? title,
      title: title,
      imageUrl: (map['imageUrl'] ?? map['image'])?.toString() ?? fallback.imageUrl,
      poseLandmarksJson: map['poseLandmarksJson'],
    );
  }

  static const PoseLookbook fallback = PoseLookbook(
    id: 'default-lookbook',
    title: 'Tokyo Outlaw • AW26',
    imageUrl:
        'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=800&q=80',
  );
}

/// Provider managing Lookbooks, Likes, Affiliate Scraper & Tag Clicks (TSK-20)
class LookbookProvider extends ChangeNotifier {
  LookbookProvider._();
  static final LookbookProvider instance = LookbookProvider._();

  bool _isLoading = false;
  List<Map<String, dynamic>> _lookbooks = [];
  final Set<String> _likedLookbookIds = {};

  PoseLookbook? _selectedPoseLookbook;

  /// Lookbook nguoi dung vua chon tu Discovery Feed (null neu chua chon).
  PoseLookbook? get selectedPoseLookbook => _selectedPoseLookbook;

  /// Lookbook dung cho Camera AI: ban da chon, neu khong thi lookbook dau tien.
  PoseLookbook get activePoseLookbook {
    final selected = _selectedPoseLookbook;
    if (selected != null) return selected;
    if (_lookbooks.isNotEmpty) return PoseLookbook.fromMap(_lookbooks.first);
    return PoseLookbook.fallback;
  }

  void selectLookbookForCamera(Map<String, dynamic> item) {
    _selectedPoseLookbook = PoseLookbook.fromMap(item);
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get lookbooks => _lookbooks;
  Set<String> get likedLookbookIds => _likedLookbookIds;

  /// Fetches live Lookbooks from `GET /api/v1/lookbooks`
  Future<List<Map<String, dynamic>>> fetchLookbooks({String? styleCategory}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final query = <String, String>{};
      if (styleCategory != null &&
          styleCategory.isNotEmpty &&
          !styleCategory.toLowerCase().contains('tất cả') &&
          !styleCategory.toLowerCase().contains('all')) {
        query['styleCategory'] = styleCategory;
      }

      final response = await ApiClient.instance.get(
        '/lookbooks',
        queryParameters: query.isEmpty ? null : query,
      );

      final data = response['data'];
      List<dynamic> rawItems = [];
      if (data is List) {
        rawItems = data;
      } else if (data is Map && data['items'] is List) {
        rawItems = data['items'] as List<dynamic>;
      }

      if (rawItems.isNotEmpty) {
        final ambientColors = [
          const Color(0x38FF5E7E),
          const Color(0x38FFB830),
          const Color(0x38FB923C),
          const Color(0x38A855F7),
        ];
        final stickers = ['TRENDING', "AW'26", 'OFFICE', 'STREET'];

        _lookbooks = List<Map<String, dynamic>>.generate(rawItems.length, (idx) {
          final item = Map<String, dynamic>.from(rawItems[idx] as Map);
          final id = item['id']?.toString() ?? 'lb-$idx';
          final tags = (item['productTags'] as List<dynamic>?) ?? [];
          final stylist = item['stylist'] as Map<String, dynamic>?;
          final stylistName = stylist?['fullName']?.toString() ?? 'Maya Trần';
          final stylistAvatar = stylist?['avatarUrl']?.toString() ??
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&auto=format&fit=crop&q=80';
          final isLiked = item['isLiked'] == true || _likedLookbookIds.contains(id);
          if (isLiked) {
            _likedLookbookIds.add(id);
          }

          return {
            'id': id,
            'title': item['title']?.toString() ?? 'Cyber Streetwear AW26',
            'stylist': '@${stylistName.toLowerCase().replaceAll(' ', '.')}',
            'stylistName': stylistName,
            'creatorInfo': '$stylistName • ${tags.isNotEmpty ? tags.length : 3} Items',
            'stylistAvatar': stylistAvatar,
            'poseMatch': '96%',
            'tagCount': tags.isNotEmpty ? tags.length : 3,
            'image': item['imageUrl']?.toString() ??
                'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=800&q=80',
            'isFeatured': idx % 2 == 0,
            'sticker': item['styleCategory']?.toString().toUpperCase() ??
                stickers[idx % stickers.length],
            'ambientGlow': ambientColors[idx % ambientColors.length],
            'likesCount': (item['likesCount'] as num?)?.toInt() ?? 42,
            'isLiked': isLiked,
            'poseLandmarksJson': item['poseLandmarksJson'],
            'productTags': tags,
          };
        });
      }
    } catch (_) {
      // Keep existing or fallback items on network error
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _lookbooks;
  }

  /// Toggles like on a Lookbook via `POST /api/v1/lookbooks/:id/like`
  Future<Map<String, dynamic>?> toggleLike(String lookbookId) async {
    if (_likedLookbookIds.contains(lookbookId)) {
      _likedLookbookIds.remove(lookbookId);
    } else {
      _likedLookbookIds.add(lookbookId);
    }
    notifyListeners();

    try {
      final res = await ApiClient.instance.post('/lookbooks/$lookbookId/like');
      final data = res['data'] as Map<String, dynamic>?;
      if (data != null) {
        final liked = data['liked'] == true;
        if (liked) {
          _likedLookbookIds.add(lookbookId);
        } else {
          _likedLookbookIds.remove(lookbookId);
        }
        notifyListeners();
      }
      return data;
    } catch (_) {
      return null;
    }
  }

  /// Tracks affiliate tag click via `POST /api/v1/tags/:id/click`
  Future<String?> trackTagClick(String tagId) async {
    try {
      final res = await ApiClient.instance.post('/tags/$tagId/click');
      final data = res['data'] as Map<String, dynamic>?;
      return data?['redirectUrl']?.toString();
    } catch (_) {
      return null;
    }
  }

  /// Scrapes Shopee/Lazada affiliate link via `POST /api/v1/affiliate/scrape`
  Future<Map<String, dynamic>> scrapeAffiliateUrl(String url) async {
    try {
      final res = await ApiClient.instance.post(
        '/affiliate/scrape',
        body: {'url': url.trim()},
      );
      final data = res['data'] as Map<String, dynamic>?;
      if (data != null) {
        return data;
      }
    } catch (_) {
      // Fallback smart metadata
    }
    return {
      'itemName': 'Cyber Utility Jacket AW26',
      'price': 1250000,
      'affiliateUrl': url.trim(),
      'platform': 'SHOPEE',
    };
  }
}
