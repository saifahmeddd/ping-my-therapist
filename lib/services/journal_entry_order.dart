import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore server timestamps may be temporarily null while a write is pending.
DateTime? journalEntryDate(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

/// Newest entries first, with undated legacy/pending entries at the end.
int compareJournalEntries(
  Map<String, dynamic> first,
  Map<String, dynamic> second,
) {
  final firstDate = journalEntryDate(first['timestamp']);
  final secondDate = journalEntryDate(second['timestamp']);
  if (firstDate == null) return secondDate == null ? 0 : 1;
  if (secondDate == null) return -1;
  return secondDate.compareTo(firstDate);
}
