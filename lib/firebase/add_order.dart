import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> _finalizeOrder() async {
  // Assume this is your Firestore instance
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Assume this is the total from the current order
  double orderTotal = calculateOrderTotal();

  // Start a Firestore transaction
  await firestore.runTransaction((transaction) async {
    // Get a reference to the sales totals document
    DocumentReference salesRef = firestore.collection('salesTotals').doc('today');

    // Get the current sales total
    DocumentSnapshot salesSnapshot = await transaction.get(salesRef);

    // Calculate the new sales total
    double newSalesTotal = salesSnapshot.exists
        ? (salesSnapshot.data()?['total'] ?? 0) + orderTotal
        : orderTotal;

    // Update the sales totals document with the new total
    transaction.set(salesRef, {'total': newSalesTotal});
  });
}