import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ping_my_therapist/services/journal_entry_order.dart';

void main() {
  test(
    'saved journal entries stay newest-first across stored date formats',
    () {
      final entries = <Map<String, dynamic>>[
        {'entry': 'Pending timestamp', 'timestamp': null},
        {
          'entry': 'Older',
          'timestamp': Timestamp.fromDate(DateTime.utc(2026, 1, 1)),
        },
        {'entry': 'Newest', 'timestamp': '2026-10-08T12:00:00Z'},
        {'entry': 'Middle', 'timestamp': DateTime.utc(2026, 5, 1)},
      ]..sort(compareJournalEntries);

      expect(entries.map((entry) => entry['entry']), [
        'Newest',
        'Middle',
        'Older',
        'Pending timestamp',
      ]);
    },
  );

  test('invalid and missing timestamps do not crash saved-entry loading', () {
    expect(journalEntryDate('not-a-date'), isNull);
    expect(journalEntryDate(null), isNull);
    expect(compareJournalEntries({}, {'timestamp': null}), 0);
    expect(
      compareJournalEntries(
        {'timestamp': 'invalid'},
        {'timestamp': Timestamp.fromDate(DateTime.utc(2026))},
      ),
      greaterThan(0),
    );
  });
}
