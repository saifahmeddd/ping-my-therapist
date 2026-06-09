import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ping_my_therapist/core/app_strings.dart';
import 'package:ping_my_therapist/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App shows onboarding splash screen', (WidgetTester tester) async {
    await dotenv.load(
      mergeWith: const {'API_BASE_URL': 'https://test.example.com'},
    );
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
