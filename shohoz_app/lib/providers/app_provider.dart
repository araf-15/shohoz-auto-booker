import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/profile.dart';

class AppProvider extends ChangeNotifier {
  late Box<BookingProfile> _profileBox;
  late Box _settingsBox;
  bool _isGlobalActive = false;

  List<BookingProfile> get profiles => _profileBox.values.toList();
  bool get isGlobalActive => _isGlobalActive;

  AppProvider() {
    _profileBox = Hive.box<BookingProfile>('profiles');
    _settingsBox = Hive.box('settings');
    _isGlobalActive = _settingsBox.get('globalActive', defaultValue: false);
  }

  void toggleGlobalActive() {
    _isGlobalActive = !_isGlobalActive;
    _settingsBox.put('globalActive', _isGlobalActive);
    notifyListeners();
  }

  Future<void> saveProfile(BookingProfile profile) async {
    await _profileBox.put(profile.id, profile);
    notifyListeners();
  }

  Future<void> deleteProfile(String id) async {
    await _profileBox.delete(id);
    notifyListeners();
  }

  BookingProfile? getProfile(String id) => _profileBox.get(id);
}
