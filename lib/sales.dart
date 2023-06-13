import 'package:flutter/material.dart';
import 'data/locations.dart';

import 'firebase/get_sales.dart';
import 'models/category.dart';
import 'models/sales_listing.dart';

class Sales extends StatefulWidget {
  @override
  _SalesFilterScreenState createState() => _SalesFilterScreenState();
}

class _SalesFilterScreenState extends State<Sales> {
  String selectedTimeFrame = 'Day';
  String selectedCategory = 'Product';
  String selectedLocation = 'All';

  List<Sale> products = [];
  List<Sale> filteredProducts = [];
  List<Sale> displayProducts = [];
  double totalSalesPrice = 0.0;

  Map<String, Category> categories = {};
  List<Category> categoryList = [];

  void loadSales([String name = 'DAY']) async {
    products = await getSales(name);
    updateSales();
    setState(() {});  // trigger a rebuild
    combineCategories();
  }

  void updateSales() {
    filterSalesByLocation();
    combineSales();
    totalSalesPrice = displayProducts.fold(0.0, (sum, item) => sum + item.price);
    setState(() {});
    combineCategories();
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
          location: sale.location,
          date: sale.date,
        );
      }
    }

    // convert the map back to a list
    List<Sale> combinedSales = combinedSalesMap.values.toList();
    combinedSales.sort((a, b) => a.title.compareTo(b.title));

    // replace the original list with the combined list
    displayProducts = combinedSales;
  }

  void combineCategories() {
    // Map for categories
    Map<String, Category> categoryMap = {};

    for (Sale sale in filteredProducts) {
      String name = sale.title;
      // Check if the title is a key in categoryMap, if not, initialize it
      if (!categoryMap.containsKey(name)) {
        categoryMap[name] = Category(
          titles: [name],
          totalNumber: 0,
          totalPrice: 0.0,
          name: '',
        );
        // Add the number and price of the sale to the appropriate category
        categoryMap[name]!.totalNumber += sale.number;
        categoryMap[name]!.totalPrice += sale.price;
      }
    }

    // Convert the map back to a list
    List<Category> categories = categoryMap.values.toList();

    // If needed, sort categories by title of the first product
    categories.sort((a, b) => a.name.compareTo(b.name));
  }

  void filterSalesByLocation() {
    if (selectedLocation == 'All') {
      // if 'All' is selected, no need to filter
      filteredProducts = List.from(products);
    } else {
      // otherwise, filter products by the selected location
      filteredProducts = products.where((sale) => sale.location == selectedLocation).toList();
    }

    setState(() {});  // trigger a rebuild
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Data'),
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
                        loadSales(selectedTimeFrame.toUpperCase());
                        updateSales();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedCategory,
                    items: <String>['Product', 'Category']
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
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedLocation,
                    items: locations.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedLocation = value!;
                        updateSales();
                      });
                    },
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
                  trailing: Text('Sales: \$${displayProducts[index].price}'),
                );
              },
            ),
          ),

          Container(
            color: Colors.grey[300], // optional: give it a background color for visibility
            padding: const EdgeInsets.all(16.0), // optional: add some padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // optional: space out the items
              children: [
                const Text('Total Sales:', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                Text('\$${totalSalesPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

        ],
      ),
    );
  }
}