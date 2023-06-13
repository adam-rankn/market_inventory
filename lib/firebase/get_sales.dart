import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/sales_listing.dart';

Future<List<Sale>> getSales(String period) async {
  DateTime now = DateTime.now();
  DateTime startOfWeek = DateTime(now.year, now.month, now.day - now.weekday + 1);
  DateTime startOfMonth = DateTime(now.year, now.month);
  DateTime startOfYear = DateTime(now.year);

  Timestamp startTimestamp = Timestamp.fromDate(now.toUtc());

  switch (period) {
    case 'DAY':
      startTimestamp = Timestamp.fromDate(now.toUtc());
      break;
    case 'WEEK':
      startTimestamp = Timestamp.fromDate(startOfWeek.toUtc());
      break;
    case 'MONTH':
      startTimestamp = Timestamp.fromDate(startOfMonth.toUtc());
      break;
    case 'YEAR':
      startTimestamp = Timestamp.fromDate(startOfYear.toUtc());
      break;
    default:
      startTimestamp = Timestamp.fromDate(now.toUtc());
  }


  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference salesRef = firestore.collection('sales');

  QuerySnapshot querySnapshot = await salesRef
      .where('date', isGreaterThanOrEqualTo: startTimestamp)
      .get();


  List<Sale> sales = querySnapshot.docs.map((doc) {
    return Sale(
      title: doc['item'] as String,
      number: doc['quantity'] as int,
      price: doc['totalPrice'] as double,
      location: doc['location'] as String,
      date: doc['date'] as Timestamp,
    );
  }).toList();

  return sales;

}