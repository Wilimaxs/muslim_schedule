import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore fire = FirebaseFirestore.instance;

  Future<void> setDocumentWithMerge(String docId, bool status) async {
    try {
      await FirebaseFirestore.instance.collection("alarm").doc(docId).set({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print("Document set with merge successfully");
    } catch (e) {
      print("Error setting document: $e");
    }
  }

  Future<bool> readData(String docId) async {
    try {
      final DocumentSnapshot document =
          await fire.collection('alarm').doc(docId).get();
      final data = document.data() as Map<String, dynamic>?;
      if (!data!.containsKey('status')) {
        print("❌ Field 'status' not found in document: $docId");
        return false;
      } else if (data['status'] == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error setting document: $e");
      return false;
    }
  }
}
