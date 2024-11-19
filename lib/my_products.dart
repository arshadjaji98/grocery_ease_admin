import 'package:flutter/material.dart';
import 'package:grocery_app_admin/services/database_services.dart';

class MyProducts extends StatefulWidget {
  const MyProducts({super.key});

  @override
  State<MyProducts> createState() => _MyProductsState();
}

class _MyProductsState extends State<MyProducts> {
  String? selectedCategory;
  final List<String> categories = [
    'Fruit',
    'Meat',
    'Beverages',
    'Bakery',
    'Oil'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Your Products"),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              hint: const Text("Select Category"),
              value: selectedCategory,
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
              items: categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: selectedCategory == null
                  ? const Center(child: Text("Please select a category"))
                  : StreamBuilder<List<Map<String, dynamic>>>(
                      stream: DatabaseServices()
                          .getFoodItem(selectedCategory!)
                          .map((snapshot) {
                        return snapshot.docs
                            .map((doc) => doc.data() as Map<String, dynamic>)
                            .toList();
                      }),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text("No items found"));
                        }

                        List<Map<String, dynamic>> foodItems = snapshot.data!;
                        return ListView.builder(
                          itemCount: foodItems.length,
                          itemBuilder: (context, index) {
                            final foodItem = foodItems[index];
                            return ListTile(
                              leading: foodItem['Image'] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        foodItem['Image'],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.fastfood),
                              title: Text(foodItem['Name'] ?? 'No Name'),
                              subtitle:
                                  Text(foodItem['Detail'] ?? 'No Description'),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
