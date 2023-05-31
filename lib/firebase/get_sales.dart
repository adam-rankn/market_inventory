import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/sales_listing.dart';

Future<List<Sale>> getSales() async {
  DateTime startDate = DateTime.now().toUtc().subtract(Duration(days: 7));  // 7 days ago
  DateTime endDate = DateTime.now().toUtc();  // today

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference salesRef = firestore.collection('sales');

  QuerySnapshot querySnapshot = await salesRef
      .get();


  List<Sale> sales = querySnapshot.docs.map((doc) {
    return Sale(
      title: doc['item'] as String,
      number: doc['quantity'] as int,
      price: doc['totalPrice'] as double,
      location: doc['location'] as String,
      date: doc['date'] as String,
    );
  }).toList();

  return sales;

}