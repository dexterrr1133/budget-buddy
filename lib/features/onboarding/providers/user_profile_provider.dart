import 'package:flutter/foundation.dart';

import '../models/user_profile_model.dart';
import '../services/onboarding_storage_service.dart';

class UserProfileProvider extends ChangeNotifier {
  UserProfileProvider({OnboardingStorageService? storage})
    : _storage = storage ?? OnboardingStorageService() {
    _load();
  }

  final OnboardingStorageService _storage;

  UserProfileModel? _profile;
  bool _loading = true;

  UserProfileModel? get profile => _profile;
  bool get isLoading => _loading;
  bool get hasProfile => _profile != null;

  Future<void> _load() async {
    _loading = true;
    notifyListeners();
    _profile = await _storage.loadProfile();
    _loading = false;
    notifyListeners();
  }

  Future<void> setProfile(UserProfileModel profile) async {
    _profile = profile;
    notifyListeners();
    await _storage.saveProfile(profile);
  }

  Future<void> clearProfile() async {
    _profile = null;
    notifyListeners();
    await _storage.clearProfile();
  }
}
