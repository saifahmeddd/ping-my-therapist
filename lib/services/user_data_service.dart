import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDataService {
  static const String _collection1 = 'users';
  static const String _collection2 = 'onboarding_responses';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> getUserData() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final doc = await _firestore.collection(_collection1).doc(user.uid).get();
    if (!doc.exists) throw Exception('User data not found');
    return doc.data() ?? {};
  }

  Future<Map<String, dynamic>> getOnboardingResponses() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final querySnapshot =
        await _firestore
            .collection(_collection2)
            .where('uid', isEqualTo: user.uid)
            .get();

    if (querySnapshot.docs.isEmpty) {
      return {'answers': {'answer1': '', 'answer2': '', 'additional_context': ''}};
    }

    return querySnapshot.docs.first.data();
  }
}
