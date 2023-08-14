import 'package:sales_tracker/models/product.dart';
import 'package:sales_tracker/models/saleable_item.dart';

class Bundle extends SaleableItem {
  final List<Product> products;

  final double productPrice;
  final String title;

  @override
  double get price => productPrice;
  
  Bundle( {required this.products, required this.productPrice,required this.title});


}