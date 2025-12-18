import 'package:cloud_firestore/cloud_firestore.dart';
// Scenario 2
class CrisisSupportRepository {
  // Collection for mental health and emergency hotlines
  final CollectionReference mentalHealthHotline =
      FirebaseFirestore.instance.collection('mentalHealthHotline');
  final CollectionReference emergencyHotline =
      FirebaseFirestore.instance.collection('emergencyHotline');

  // CREATE for mental health hotline
  Future<void> addMentalHealthHotline(String mhName, String mhNumber) {
    return mentalHealthHotline.add({
      'name': mhName,
      'number': mhNumber,
    });
  }

  // CREATE for emergency hotline
  Future<void> addEmergencyHotline(String ecName, String ecNumber) {
    return emergencyHotline.add({
      'name': ecName,
      'number': ecNumber,
    });
  }

  // READ: Get mental health hotlines stream
  Stream<QuerySnapshot> getMentalHealthHotlineStream() {
    return mentalHealthHotline.snapshots();
  }

  // READ: Get emergency hotlines stream
  Stream<QuerySnapshot> getEmergencyHotlineStream() {
    return emergencyHotline.snapshots();
  }

  // UPDATE for mental health hotline
  Future<void> updateMentalHealthHotline(
      String docID, String mhName, String mhNumber) {
    return mentalHealthHotline.doc(docID).update({
      'name': mhName,
      'number': mhNumber,
    });
  }

  // UPDATE for emergency hotline
  Future<void> updateEmergencyHotline(
      String docID, String ecName, String ecNumber) {
    return emergencyHotline.doc(docID).update({
      'name': ecName,
      'number': ecNumber,
    });
  }

  // DELETE for mental health hotline
  Future<void> deleteMentalHealthHotline(String docID) {
    return mentalHealthHotline.doc(docID).delete();
  }

  // DELETE for emergency hotline
  Future<void> deleteEmergencyHotline(String docID) {
    return emergencyHotline.doc(docID).delete();
  }
}

/*
📞 Befrienders 082-242800

👮🏻 Polis Bantuan UNIMAS 017-212 7464
🧑🏻‍🚒 Rescue 991
☎️ Hotline 082-244444
🏥 Hospital 082-230689
*/