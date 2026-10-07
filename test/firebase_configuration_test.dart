import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ping_my_therapist/firebase_options.dart';

void main() {
  test(
    'Android Firebase options match the app registered in Google Services',
    () {
      final configFile = File('android/app/google-services.json');
      expect(configFile.existsSync(), isTrue);

      final config =
          jsonDecode(configFile.readAsStringSync()) as Map<String, dynamic>;
      final project = config['project_info'] as Map<String, dynamic>;
      final clients = config['client'] as List<dynamic>;
      final client = clients.cast<Map<String, dynamic>>().singleWhere((entry) {
        final info = entry['client_info'] as Map<String, dynamic>;
        final android = info['android_client_info'] as Map<String, dynamic>;
        return android['package_name'] ==
            'com.pingmytherapist.ping_my_therapist';
      });
      final clientInfo = client['client_info'] as Map<String, dynamic>;
      final apiKeys = client['api_key'] as List<dynamic>;
      final androidOptions = DefaultFirebaseOptions.android;

      expect(androidOptions.projectId, project['project_id']);
      expect(androidOptions.messagingSenderId, project['project_number']);
      expect(androidOptions.storageBucket, project['storage_bucket']);
      expect(androidOptions.appId, clientInfo['mobilesdk_app_id']);
      expect(
        androidOptions.apiKey,
        (apiKeys.single as Map<String, dynamic>)['current_key'],
      );
    },
  );

  test('Firebase CLI points to the same project as the Android app', () {
    final aliases =
        jsonDecode(File('.firebaserc').readAsStringSync())
            as Map<String, dynamic>;
    final projects = aliases['projects'] as Map<String, dynamic>;
    expect(projects['default'], DefaultFirebaseOptions.android.projectId);
  });
}
