import 'package:flutter/material.dart';

import 'firebase/get_sales.dart';
import 'models/sales_listing.dart';

class Sales extends StatefulWidget {
  @override
  _SalesFilterScreenState createState() => _SalesFilterScreenState();
}

class _SalesFilterScreenState extends State<Sales> {
  String selectedTimeFrame = 'Day';
  String selectedCategory = 'All';
  String selectedLocation = 'All';

  List<Sale> products = [];
  List<Sale> filteredProducts = [];
  List<Sale> displayProducts = [];

  void loadSales() async {
    products = await getSales();
    filteredProducts = products;
    combineSales();
    setState(() {});  // trigger a rebuild
  }

  @override
  void initState() {
    super.initState();
    loadSales();
  }

  void combineSales() {
    Map<String, Sale> combinedSalesMap = {};

    for (Sale sale in filteredProducts) {
      if (combinedSalesMap.containsKey(sale.title)) {
        // if the map already contains the title, add the price and number to existing values
        combinedSalesMap[sale.title]?.price += sale.price;
        combinedSalesMap[sale.title]?.number += sale.number;
      } else {
        // else, add the sale to the map
        combinedSalesMap[sale.title] = Sale(
          title: sale.title,
          number: sale.number,
          price: sale.price,
          location: sale.location, // assuming location and date are same for same title
          date: sale.date,
        );
      }
    }

    // convert the map back to a list
    List<Sale> combinedSales = combinedSalesMap.values.toList();

    // replace the original list with the combined list
    displayProducts = combinedSales;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Data'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedTimeFrame,
                    items: <String>['Day', 'Week', 'Month', 'Year']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedTimeFrame = value!;
                      });
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedCategory,
                    items: <String>['All', 'Product', 'Category']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedLocation,
                    items: <String>[
                      'All',
                      'Location 1',
                      'Location 2',
                      'Location 3'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedLocation = value!;
                      });
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Call your method to fetch and filter data here
                    },
                    child: Text('Fetch Data'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: displayProducts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.network('https://www.mygreekdish.com/wp-content/uploads/2013/10/Greek-Saganaki-recipe-Pan-seared-Greek-cheese-appetizer-scaled.jpg'),
                  title: Text(displayProducts[index].title),
                  subtitle: Text('Number Sold: ${displayProducts[index].number}'),
                  trailing: Text('Total Sales: \$${displayProducts[index].price}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}