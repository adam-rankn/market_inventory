import 'package:sales_tracker/models/saleable_item.dart';

class Product extends SaleableItem {
    final String title;
    final String image;
    final double productPrice;

    Product({required this.title, required this.image, required this.productPrice});

    @override
    double get price => productPrice;
}