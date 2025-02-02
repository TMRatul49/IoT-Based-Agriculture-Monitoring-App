import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plant_monitor_app/screens/home_Screens.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/product_state.dart';

class ProductRegistrationScreen extends StatelessWidget {
  static const routeName = '/product-registration';

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final darkGreenColor = Color(0xFF00692B);

    return Scaffold(
      appBar: AppBar(
        title: Text("Farm Registration"),
        backgroundColor: darkGreenColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Farm Name',
                    filled: true,
                    prefixIcon: Icon(Icons.business), // Add icon to the field
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    filled: true,
                    prefixIcon: Icon(Icons.location_on), // Add icon to the field
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Phone number',
                    filled: true,
                    prefixIcon: Icon(Icons.phone), // Add icon to the field
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    final title = _titleController.text;
                    final description = _descriptionController.text;
                    final price = _priceController.text;

                    final productState =
                        Provider.of<ProductState>(context, listen: false);

                    productState.registerProduct(
                      name: title,
                      address: description,
                      description: price,
                    );

                    Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(darkGreenColor),
                  ),
                  child: Text(
                    "Register Farm",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
