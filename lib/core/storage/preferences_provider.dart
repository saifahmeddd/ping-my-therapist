import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ping_my_therapist/core/storage/preferences.dart';

final preferencesProvider = FutureProvider<Preferences>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return Preferences(prefs);
});
