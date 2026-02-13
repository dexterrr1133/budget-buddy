import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile_model.dart';

class OnboardingStorageService {
  static const _profileKey = 'user_profile_v1';

  Future<void> saveProfile(UserProfileModel profile) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(profile.toJson());
    await prefs.setString(_profileKey, payload);
  }

  Future<UserProfileModel?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = prefs.getString(_profileKey);
    if (payload == null || payload.isEmpty) return null;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      return UserProfileModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }
}
