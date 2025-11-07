import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';


final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {

  throw UnimplementedError('This provider must be overridden in the main function.');
});


final userTokenProvider = Provider<String?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString('user_token');
});