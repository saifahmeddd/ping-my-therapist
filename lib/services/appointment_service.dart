import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────

/// Represents a therapist profile fetched from the `therapists` collection.
/// Availability slots: { dayOfWeek: int (0=Sun…6=Sat), startTime: "HH:MM", endTime: "HH:MM" }
class TherapistInfo {
  final String uid;
  final String name;
  final String email;
  final String bio;
  final List<String> specializations;
  final int yearsOfExperience;
  final String? profilePhoto;
  final List<Map<String, dynamic>> availability;

  const TherapistInfo({
    required this.uid,
    required this.name,
    required this.email,
    required this.bio,
    required this.specializations,
    required this.yearsOfExperience,
    this.profilePhoto,
    required this.availability,
  });

  /// Converts portal settings format or legacy fields into mobile booking format.
  static List<Map<String, dynamic>> normalizeAvailability(List<dynamic> raw) {
    const dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    int dayNameToDayOfWeek(String day) {
      final index = dayNames.indexOf(day);
      if (index < 0) return -1;
      return index == 6 ? 0 : index + 1;
    }

    final normalized = <Map<String, dynamic>>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      final map = Map<String, dynamic>.from(entry);

      if (map.containsKey('dayOfWeek')) {
        final dayOfWeek = (map['dayOfWeek'] as num?)?.toInt();
        if (dayOfWeek == null || dayOfWeek < 0 || dayOfWeek > 6) continue;
        normalized.add({
          'dayOfWeek': dayOfWeek,
          'startTime': map['startTime'] ?? map['start'] ?? '09:00',
          'endTime': map['endTime'] ?? map['end'] ?? '17:00',
        });
        continue;
      }

      if (map.containsKey('day') && (map['enabled'] ?? true) == true) {
        final dayOfWeek = dayNameToDayOfWeek(map['day'] as String? ?? '');
        if (dayOfWeek < 0) continue;
        normalized.add({
          'dayOfWeek': dayOfWeek,
          'startTime': map['start'] ?? map['startTime'] ?? '09:00',
          'endTime': map['end'] ?? map['endTime'] ?? '17:00',
        });
      }
    }

    return normalized;
  }

  factory TherapistInfo.fromMap(Map<String, dynamic> data) {
    return TherapistInfo(
      uid: (data['uid'] as String?) ?? '',
      name: (data['name'] as String?) ?? 'Unknown Therapist',
      email: (data['email'] as String?) ?? '',
      bio: (data['bio'] as String?) ?? '',
      specializations: List<String>.from(data['specializations'] ?? []),
      yearsOfExperience: (data['yearsOfExperience'] as num?)?.toInt() ?? 0,
      profilePhoto: data['profilePhoto'] as String?,
      availability: normalizeAvailability(data['availability'] ?? []),
    );
  }
}

/// Represents an appointment document from the `appointments` collection.
class AppointmentModel {
  final String id;
  final String patientId;
  final String therapistUid;
  final String? patientName;
  final String? therapistName;
  final DateTime scheduledAt;
  final int duration;
  final String type;
  final String status;
  final String? notes;
  final String? source;
  final DateTime? createdAt;

  const AppointmentModel({
    required this.id,
    required this.patientId,
    required this.therapistUid,
    this.patientName,
    this.therapistName,
    required this.scheduledAt,
    required this.duration,
    required this.type,
    required this.status,
    this.notes,
    this.source,
    this.createdAt,
  });

  factory AppointmentModel.fromMap(String id, Map<String, dynamic> data) {
    DateTime scheduledAt;
    final raw = data['scheduledAt'];
    if (raw is Timestamp) {
      scheduledAt = raw.toDate();
    } else if (raw is String) {
      scheduledAt = DateTime.tryParse(raw) ?? DateTime.now();
    } else {
      scheduledAt = DateTime.now();
    }

    DateTime? createdAt;
    final rawCreated = data['createdAt'];
    if (rawCreated is Timestamp) {
      createdAt = rawCreated.toDate();
    }

    return AppointmentModel(
      id: id,
      patientId: (data['patientId'] as String?) ?? '',
      therapistUid: (data['therapistUid'] as String?) ?? '',
      patientName: data['patientName'] as String?,
      therapistName: data['therapistName'] as String?,
      scheduledAt: scheduledAt,
      duration: (data['duration'] as num?)?.toInt() ?? 60,
      type: (data['type'] as String?) ?? 'individual',
      status: ((data['status'] as String?) ?? 'pending').toLowerCase(),
      notes: data['notes'] as String?,
      source: data['source'] as String?,
      createdAt: createdAt,
    );
  }
}

bool containsPendingAppointment(
  Iterable<Map<String, dynamic>> appointments,
  String therapistUid,
  DateTime scheduledAt,
) {
  for (final appointment in appointments) {
    if (appointment['therapistUid'] != therapistUid ||
        (appointment['status'] as String?)?.toLowerCase() != 'pending') {
      continue;
    }
    final raw = appointment['scheduledAt'];
    final appointmentTime =
        raw is Timestamp
            ? raw.toDate()
            : raw is String
            ? DateTime.tryParse(raw)
            : null;
    if (appointmentTime != null &&
        appointmentTime.difference(scheduledAt).abs() <
            const Duration(minutes: 5)) {
      return true;
    }
  }
  return false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────

class AppointmentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetch all admin-approved therapists from the `therapists` collection.
  Future<List<TherapistInfo>> getVerifiedTherapists() async {
    final snapshot =
        await _db
            .collection('therapists')
            .where('verified', isEqualTo: true)
            .get();

    return snapshot.docs
        .where((doc) {
          final data = doc.data();
          final status = data['status'] as String?;
          // Admin approval sets status to "verified"; exclude suspended/revoked profiles.
          return status == null || status == 'verified';
        })
        .map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          final authUid = data['uid'] as String?;
          if (authUid == null || authUid.isEmpty) {
            data['uid'] = doc.id;
          }
          return TherapistInfo.fromMap(data);
        })
        .toList();
  }

  /// Returns true if the patient already has a pending request
  /// for the same therapist within 5 minutes of [scheduledAt].
  Future<bool> hasPendingRequest(
    String therapistUid,
    DateTime scheduledAt,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final snapshot =
        await _db
            .collection('appointments')
            .where('patientId', isEqualTo: user.uid)
            .get();
    return containsPendingAppointment(
      snapshot.docs.map((doc) => doc.data()),
      therapistUid,
      scheduledAt,
    );
  }

  /// Creates an appointment request document in Firestore.
  /// The document is owned by the patient (patientId = auth.uid) and
  /// assigned to the therapist (therapistUid).
  Future<String> requestAppointment({
    required String therapistUid,
    required String therapistName,
    required DateTime scheduledAt,
    required int duration,
    required String type,
    String? notes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final userDoc = await _db.collection('users').doc(user.uid).get();
    final patientName =
        (userDoc.data()?['name'] as String?) ?? user.displayName ?? 'Patient';
    final patientEmail = user.email ?? '';

    final docRef = await _db.collection('appointments').add({
      'patientId': user.uid,
      'therapistUid': therapistUid,
      'patientName': patientName,
      'patientEmail': patientEmail,
      'therapistName': therapistName,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'duration': duration,
      'type': type,
      'status': 'pending',
      'notes': notes,
      'source': 'mobile',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Real-time stream of the current patient's appointments,
  /// sorted newest-first by scheduledAt.
  Stream<List<AppointmentModel>> getMyAppointments() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('appointments')
        .where('patientId', isEqualTo: user.uid)
        .snapshots()
        .map((snap) {
          final list =
              snap.docs
                  .map((doc) => AppointmentModel.fromMap(doc.id, doc.data()))
                  .toList()
                ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
          return list;
        });
  }
}
