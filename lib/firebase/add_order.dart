import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

Future<void> updateSalesTotals(String market,String item,int num , double saleAmount) async {
  // Assume this is your Firestore instance
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DateTime now = DateTime.now().toUtc();
  DateTime dat = DateTime(now.year, now.month, now.day);
  String date = dat.toIso8601String().substring(0,10);


  // Get a reference to the item's sales totals document for the specified date
  DocumentReference itemRef = firestore
      .collection('locations')
      .doc(market)
      .collection('salesTotals')
      .doc(date)
      .collection('items')
      .doc(item);

  // Start a Firestore transaction

  try {
    await firestore.runTransaction((transaction) async {
      // Get the current sales totals
      DocumentSnapshot snapshot = await transaction.get(itemRef);

      // Cast snapshot data to a Map
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic> ?? {};

      // Calculate the new total sales and times sold
      double newTotalSales = (data['totalSales'] ?? 0) + saleAmount;
      int newTimesSold = (data['timesSold'] ?? 0) + num;

      // Update the sales totals document with the new total sales and times sold
      transaction.set(itemRef, {'totalSales': newTotalSales, 'timesSold': newTimesSold});
    });
  } catch (e) {
    print("Error in updateSalesTotals: $e");
  }
}