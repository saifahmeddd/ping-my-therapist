import 'package:shared_preferences/shared_preferences.dart';

/// Shared preferences wrapper for non-sensitive flags.
class Preferences {
  Preferences(this._prefs);

  final SharedPreferences _prefs;

  static const _keyOnboardingComplete = 'onboarding_complete';

  bool get onboardingComplete =>
      _prefs.getBool(_keyOnboardingComplete) ?? false;

  Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool(_keyOnboardingComplete, value);
}
