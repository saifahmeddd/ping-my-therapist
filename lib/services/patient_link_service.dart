import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Manages the therapist–patient link stored on the patient's user document.
///
/// When a therapist links a patient in the portal it writes `therapistUid`
/// to the patient's `users/{uid}` document. This service reads that field
/// and exposes it to screens that need to co-tag Firestore writes so the
/// therapist can query the data later.
class PatientLinkService {
  static const String _usersCollection = 'users';
  static const String _therapistUidField = 'therapistUid';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Returns the therapist UID assigned to the current patient, or null if
  /// no therapist has been linked yet.
  Future<String?> getTherapistUid() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc =
          await _firestore.collection(_usersCollection).doc(user.uid).get();
      if (!doc.exists) return null;
      final data = doc.data();
      final therapistUid = data?[_therapistUidField];
      return therapistUid is String && therapistUid.isNotEmpty
          ? therapistUid
          : null;
    } catch (_) {
      return null;
    }
  }

  /// Returns a real-time stream of the current patient's therapist UID.
  /// Emits null when no therapist is linked.
  Stream<String?> watchTherapistUid() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection(_usersCollection)
        .doc(user.uid)
        .snapshots()
        .map((snap) {
          if (!snap.exists) return null;
          final data = snap.data();
          final therapistUid = data?[_therapistUidField];
          return therapistUid is String && therapistUid.isNotEmpty
              ? therapistUid
              : null;
        });
  }

  /// Stores [therapistUid] on the current patient's user document.
  /// Called from the mobile onboarding or settings flow when a patient
  /// enters/accepts a therapist invitation code.
  Future<void> setTherapistUid(String therapistUid) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection(_usersCollection)
        .doc(user.uid)
        .set({_therapistUidField: therapistUid}, SetOptions(merge: true));
  }

  /// Removes the therapist link from the current patient's user document.
  Future<void> clearTherapistUid() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection(_usersCollection)
        .doc(user.uid)
        .update({_therapistUidField: FieldValue.delete()});
  }
}
