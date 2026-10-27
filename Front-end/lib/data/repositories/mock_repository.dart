import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/milestone_model.dart';
import '../models/styling_request_model.dart';

/// Repository to load mock data for UI/UX demonstration
class MockRepository {
  static const String _milestonesPath = 'assets/mock_data/milestones.json';
  static const String _stylingRequestsPath = 'assets/mock_data/styling_requests.json';

  /// Loads the 3 milestone stages for Escrow Tracking Workspace
  Future<List<MilestoneModel>> loadMilestones() async {
    final jsonString = await rootBundle.loadString(_milestonesPath);
    final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
    return list.map((e) => MilestoneModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Loads styling requests with AI brief drafts
  Future<List<StylingRequestModel>> loadStylingRequests() async {
    final jsonString = await rootBundle.loadString(_stylingRequestsPath);
    final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
    return list.map((e) => StylingRequestModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
