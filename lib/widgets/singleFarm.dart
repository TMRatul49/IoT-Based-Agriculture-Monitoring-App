import 'package:flutter/material.dart';

class SingleFarm extends StatelessWidget {
  final int? id;
  final String name;
  final String address;
  final String description;

  const SingleFarm({
    super.key,
    this.id,
    required this.name,
    required this.description,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed('/farm-details-screens', arguments: id);
        },
        child: Container(          
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00692B), Color(0xFF00692B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(top: 12, bottom: 12), // Add padding to the top and bottom
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Text(
                    address,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      elevation: 0, // No shadow
      margin: EdgeInsets.all(2), // Reduced margin
    );
  }
}
