import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  String title;
  int number;
  double price;
  String location;
  Timestamp date;

  Sale({required this.title,
    required this.number,
    required this.price,
    required this.location,
    required this.date,

  });
}