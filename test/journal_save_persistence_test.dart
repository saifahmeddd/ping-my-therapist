import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ping_my_therapist/screens/journal_entry_screen.dart';
import 'package:ping_my_therapist/screens/journal_scratch_entry_screen.dart';

void main() {
  for (final editor in ['prompted', 'free write']) {
    testWidgets('$editor journal keeps unsaved text and retries once', (
      tester,
    ) async {
      var attempts = 0;
      final saved = <String>[];
      Future<void> save(String entry) async {
        attempts++;
        if (attempts == 1) throw Exception('Offline');
        saved.add(entry);
      }

      await tester.pumpWidget(
        MaterialApp(
          home:
              editor == 'prompted'
                  ? JournalEntryScreen(
                    prompt: 'What helped today?',
                    tips: const [],
                    saveEntry: save,
                  )
                  : JournalScratchEntryScreen(saveEntry: save),
        ),
      );
      await tester.enterText(find.byType(TextField), 'A quiet walk helped.');
      await tester.tap(find.text('Save entry'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Failed to save:'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'A quiet walk helped.',
      );

      await tester.tap(find.text('Save entry'));
      await tester.pumpAndSettle();
      expect(saved, ['A quiet walk helped.']);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
    });
  }

  testWidgets('journal disables another save while a write is pending', (
    tester,
  ) async {
    final pending = Completer<void>();
    var writes = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: JournalScratchEntryScreen(
          saveEntry: (_) {
            writes++;
            return pending.future;
          },
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'One entry');
    await tester.tap(find.text('Save entry'));
    await tester.pump();

    expect(find.text('Saving…'), findsOneWidget);
    expect(writes, 1);
    expect(
      tester.widget<FilledButton>(find.bySubtype<FilledButton>()).onPressed,
      isNull,
    );

    pending.complete();
    await tester.pumpAndSettle();
    expect(writes, 1);
  });
}
