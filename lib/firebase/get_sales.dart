import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/sales_listing.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<List<Sale>> getSales(String period) async {
  DateTime now = DateTime.now();
  DateTime startOfWeek = DateTime(now.year, now.month, now.day - now.weekday + 1);
  DateTime startOfMonth = DateTime(now.year, now.month);
  DateTime startOfYear = DateTime(now.year);
  Timestamp startTimestamp = Timestamp.fromDate(now.toUtc());

  tz.initializeTimeZones();
  var mountainTime = tz.getLocation('America/Denver');

  switch (period) {
    case 'DAY':
      var now = tz.TZDateTime.now(mountainTime);
      startTimestamp = Timestamp.fromDate(tz.TZDateTime(mountainTime, now.year, now.month, now.day).toUtc());
      break;
    case 'WEEK':
      var lastWeek = tz.TZDateTime.now(mountainTime).subtract(const Duration(days: 7));
      startTimestamp = Timestamp.fromDate(tz.TZDateTime(mountainTime, lastWeek.year, lastWeek.month, lastWeek.day).toUtc());
      break;
    case 'MONTH':
      var now = tz.TZDateTime.now(mountainTime);
      startTimestamp = Timestamp.fromDate(tz.TZDateTime(mountainTime, now.year, now.month, 1).toUtc());
      break;
    case 'YEAR':
      var now = tz.TZDateTime.now(mountainTime);
      startTimestamp = Timestamp.fromDate(tz.TZDateTime(mountainTime, now.year, 1, 1).toUtc());
      break;
    default:
      startTimestamp = Timestamp.fromDate(tz.TZDateTime.now(mountainTime).toUtc());
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