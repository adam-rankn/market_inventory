import 'package:flutter/material.dart';
import 'data/categories.dart';
import 'data/locations.dart';

import 'firebase/get_sales.dart';
import 'models/category.dart';
import 'models/sales_listing.dart';

class Sales extends StatefulWidget {
  const Sales({super.key});

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
  List<Category> categoryList = categoriesList;

  void loadSales([String name = 'DAY']) async {
    products = await getSales(name);
    updateSales();
    combineCategories(displayProducts);
    setState(() {});  // trigger a rebuild
  }

  void updateSales() {
    filterSalesByLocation();
    combineSales();
    totalSalesPrice = displayProducts.fold(0.0, (sum, item) => sum + item.price);
    combineCategories(displayProducts);
    setState(() {});
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

  void combineCategories(List<Sale> sales) {
    for (Category category in categoryList) {

        category.totalNumber = 0;
        category.totalPrice = 0;

    }
    // Loop over each sale
    for (Sale sale in sales) {
      // Loop over each category
      for (Category category in categoryList) {
        // Check if the sale's title is contained in the category's titles
        if (category.titles.contains(sale.title)) {
          // Update the total number and total price for the category
          category.totalNumber += sale.number;
          category.totalPrice += sale.price;
        }
      }
    }
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
              itemCount: selectedCategory == 'Product' ? displayProducts.length : categoryList.length,
              itemBuilder: (context, index) {
                if (selectedCategory == 'Product') {
                  return ListTile(
                    leading: Image.network('https://www.mygreekdish.com/wp-content/uploads/2013/10/Greek-Saganaki-recipe-Pan-seared-Greek-cheese-appetizer-scaled.jpg'),
                    title: Text(displayProducts[index].title),
                    subtitle: Text('Number Sold: ${displayProducts[index].number}'),
                    trailing: Text('Sales: \$${displayProducts[index].price.toStringAsFixed(2)}'),
                  );
                } else {
                  return ListTile(
                    title: Text(categoryList[index].name),
                    subtitle: Text('Number Sold: ${categoryList[index].totalNumber}'),
                    trailing: Text('Sales: \$${categoryList[index].totalPrice.toStringAsFixed(2)}'),
                  );
                }
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