import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ping_my_therapist/core/config/env.dart';
import 'package:ping_my_therapist/core/network/api_client.dart';

final apiClientProvider = Provider<Dio>((ref) {
  return ApiClient.create(baseUrl: Env.apiBaseUrl);
});
