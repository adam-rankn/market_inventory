import 'package:sales_tracker/models/product.dart';

class Bundle {
  final String title;
  final List<Product> products;
  final double price;


  Bundle({required this.title, required this.products, required this.price});
}
