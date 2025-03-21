import 'package:cloud_firestore/cloud_firestore.dart';

class databasecalender{
  final FirebaseFirestore firecalender = FirebaseFirestore.instance;

Future<void> create(String title, DateTime tanggal) async {
  try {
    await firecalender.collection("calender").add({
      'title': title, 
      'tanggal': Timestamp.fromDate(tanggal)
    });
    print("Document added successfully");
  } catch (e) {
    print("Error adding document: ${e.toString()}");
  }
}

Future<List<Map<String, dynamic>>> getdata() async {
  try {
    final QuerySnapshot querySnapshot = await firecalender.collection('calender').get();
    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return data;
    }).toList();
  } catch (e) {
    print("Error getting documents: ${e.toString()}");
    return [];
  }
}
}