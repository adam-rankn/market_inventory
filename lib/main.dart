import 'package:flutter/material.dart';
import 'firebase/add_order.dart';
import 'sales.dart';
import 'setup.dart';
import 'models/product.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data/locations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        textTheme: const TextTheme(
          titleMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        primarySwatch: Colors.blue,
      ),
      home: FoodTruckScreen(),
      routes: {
    // Define the routes for the other pages
    '/sales': (context) =>  Sales(),
    '/setup': (context) => const Setup(),
    },
    );
  }
}

class FoodTruckScreen extends StatefulWidget {
  @override
  _FoodTruckScreenState createState() => _FoodTruckScreenState();
}

class _FoodTruckScreenState extends State<FoodTruckScreen> {
  final List<Product> _products = [
    Product(title: 'Tzatziki 235g', image: 'assets/images/water.png', price: 7.0),
    Product(title: 'Tzatziki 500g', image: 'assets/images/fries.png', price: 3.0),
    Product(title: 'Tiro-Kafterio', image: 'assets/images/fries.png', price: 7.0),
    Product(title: 'Hummus 250g', image: 'assets/images/onion_rings.png', price: 5.0),
    Product(title: 'Hummus 500g', image: 'assets/images/soft_drink.png', price: 3.0),

    Product(title: 'Saganaki', image: 'assets/images/saganaki.png', price: 10.0),
    Product(title: 'Dolmades', image: 'assets/images/dolmades.png', price: 8.0),
    Product(title: 'Gyros', image: 'assets/images/hot_dog.png', price: 6.0),
    Product(title: 'Olives', image: 'assets/images/fries.png', price: 3.0),
    Product(title: 'Baklava', image: 'assets/images/onion_rings.png', price: 5.0),
    Product(title: 'Pita', image: 'assets/images/soft_drink.png', price: 3.0),
    Product(title: 'Mousaka', image: 'assets/images/water.png', price: 15.0),
    Product(title: 'Keftedes', image: 'assets/images/fries.png', price: 10.0),
    Product(title: 'Pastichio', image: 'assets/images/onion_rings.png', price: 15.0),
    Product(title: 'Tarama', image: 'assets/images/soft_drink.png', price: 7.0),


    Product(title: 'Feta', image: 'assets/images/water.png', price: 4.0),
  ];

  Map<Product, int> _currentOrder = {};
  double _totalPrice = 0.0;
  double _discount = 0.0;
  bool _discountIsPercentage = true;
  String _selectedLocation = 'Downtown';

  double grandTotal = 0;



  void _addToOrder(Product product) {
    setState(() {
      if (_currentOrder.containsKey(product)) {
        _currentOrder[product] = _currentOrder[product]! + 1;
      } else {
        _currentOrder[product] = 1;
      }
      _totalPrice += product.price; // or adjust price based on product
    });
  }

  void _removeFromOrder(Product product) {
    setState(() {
      if (_currentOrder.containsKey(product)) {
        if (_currentOrder[product] != null && _currentOrder[product]! > 1) {
          _currentOrder[product] = _currentOrder[product]! - 1;
        } else {
          _currentOrder.remove(product);
        }
        _totalPrice -= product.price; // or adjust price based on product
        //todo preec
      }
    });
  }

  void _finalizeOrder() async {
    // perform actions to finalize order
    List<Future> updates = [];
    _currentOrder.forEach((product, count) {
      // Access the key (Product) using the variable 'product'
      // Access the value (int) using the variable 'count'
      updates.add(updateSalesTotals(_selectedLocation,product.title,count,product.price*count));
    });
    await Future.wait(updates);
  }

  void updateTotals(){

    setState(() {
      if (_discountIsPercentage) {
        grandTotal = _totalPrice * (1 - _discount / 100);
      } else {
        grandTotal = _totalPrice - _discount;
      }
    });
  }

  final TextEditingController _searchController = TextEditingController();

  List<Product> _getFilteredProducts() {
    List<Product> products;

    if (_searchController.text.isEmpty) {
      products = _products;
    } else {
      products = _products
          .where((product) => product.title
          .toLowerCase()
          .contains(_searchController.text.toLowerCase()))
          .toList();
    }

    // Sort the products list based on the title.
    products.sort((a, b) => a.title.compareTo(b.title));

    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: DropdownButton<String>(
          value: _selectedLocation,
          onChanged: (String? newValue) {
            setState(() {
              _selectedLocation = newValue!;
            });
          },
          items: locations.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        actions: <Widget>[

          IconButton(
            icon: const Icon(Icons.attach_money_outlined),
            tooltip: 'Sales',
            onPressed: () {
              // Navigate to the next page.
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Sales()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Setup',
            onPressed: () {
              // Navigate to another page.
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Setup()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search',
                        suffixIcon: IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              updateTotals();
                            });  // This triggers a rebuild
                          },
                          icon: const Icon(Icons.clear),
                        ),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _getFilteredProducts().length,
                      itemBuilder: (context, index) {
                        Product product = _getFilteredProducts()[index];
                        return ListTile(
                          leading: Image.network('https://www.mygreekdish.com/wp-content/uploads/2013/10/Greek-Saganaki-recipe-Pan-seared-Greek-cheese-appetizer-scaled.jpg'),
                          title: Text(product.title),
                          trailing: SizedBox(
                              width: 120,
                              height: 36,
                              child: ElevatedButton(
                                onPressed: () {
                                  _addToOrder(product);
                                  updateTotals();
                                },

                                child: const Text('Add'),
                              )
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Current Order',
                        style: TextStyle(fontSize: 36.0),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _currentOrder.length,
                      itemBuilder: (context, index) {
                        Product product = _currentOrder.keys.elementAt(index);
                        int quantity = _currentOrder.values.elementAt(index);
                        String title = product.title;
                        return ListTile(
                          title: Text('$title x $quantity'),
                          trailing: ElevatedButton(
                            onPressed: () {
                              _removeFromOrder(product);
                              updateTotals();
                            },
                            child: const Text('Remove'),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Price:'),
                      Text('\$${_totalPrice.toStringAsFixed(2)}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Discount:'),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal:48.0),
                                child: TextField(
                                 // controller: _discountController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter discount',
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _discount = double.parse(value);
                                      updateTotals();
                                    });
                                  },
                                ),
                              ),
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _discountIsPercentage ? '%' : '\$',
                                items: <String>['%', '\$'].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Container(
                                      height: 60,  // Same as the height of the Row
                                      alignment: Alignment.center,  // To center the text vertically
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                          fontSize: 32,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    _discountIsPercentage = (value == '%');
                                    updateTotals();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Grand Total:',
                        style: TextStyle(fontSize: 24.0),
                      ),

                      Text(
                        '\$${grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 24.0),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      alignment: Alignment.center,
                      child: SizedBox(height: 60.0, width: 400.0,
                        child: ElevatedButton(
                          onPressed: () {
                            _finalizeOrder();
                            setState(() {
                              _currentOrder.clear();
                               _totalPrice = 0.0;
                              _discount = 0.0;
                              _discountIsPercentage = true;
                            });
                          },
                          child: const Text('Finalize Order'),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
