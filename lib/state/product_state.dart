// import 'dart:convert';
// import 'package:flutter/cupertino.dart';
// import 'package:http/http.dart' as http;
// import '../models/product.dart';

// class ProductState with ChangeNotifier {
//   // List to store registered products
//   List<Product> _products = [];

//   // Replace with your API endpoint and token
//   static const String apiUrl = 'http://10.0.2.2:8000/agri/farm/';
//   static const String authToken = 'token 3caf981624872cf8914eb71963d7b97cd31539bc';

//   Future<void> registerProduct({
//     required String name,
//     required String address,
//     required String description,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           "Content-Type": "application/json",
//           'Authorization': "token 3caf981624872cf8914eb71963d7b97cd31539bc",
//         },
//         body: json.encode({
//           'name': name,
//           'address': address,
//           'description': description,
//           "user":
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body) as Map<String, dynamic>;
//         if (!data['error']) {
//           // Product registered successfully, you can handle the response as needed.
//         } else {
//           print("Error registering product: ${data['message']}");
//         }
//       } else {
//         print("Error registering product: HTTP ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error registering product: $e");
//     }
//   }
// }
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';

LocalStorage storage = new LocalStorage('usertoken');

class ProductState with ChangeNotifier {
  // List to store registered products
  List<Product> _products = [];

  // Replace with your API endpoint
  static const String apiUrl = 'http://192.168.236.23:8000/agri/farma/';

  Future<String> getAuthToken() async {
    final token = storage.getItem("token");
    return token ?? ''; // Provide a default empty string if the token is null
  }

  Future<void> registerProduct({
    required String name,
    required String address,
    required String description,
  }) async {
    String authTokena = await getAuthToken();
    final userId = await fetchUserId(authTokena);
    try {
      print('userId');
      print(userId);
      print('userId');
      if (userId != null) {
        final response = await http.post(
          Uri.parse('http://192.168.236.23:8000/agri/farma/'),
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Token $authTokena',
          },
          body: json.encode({
            'name': name,
            'address': address,
            'description': description,
            "user": userId, // Assign the user ID here
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          if (!data['error']) {
            // Product registered successfully, you can handle the response as needed.
          } else {
            print("Error registering product: ${data['message']}");
          }
        } else {
          print("Error registering product: HTTP ${response.statusCode}");
        }
      } else {
        print("Failed to fetch user ID.");
      }
    } catch (e) {
      print("Error registering product: $e");
    }
  }

  Future<int?> fetchUserId(String authToken) async {
    var authTokend = await getAuthToken();
    final url = Uri.parse('http://192.168.236.23:8000/agri/get_user_info/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Token $authToken',
      },
    );
    print('authTokend');
    print(authToken);
    print('authTokend');
    if (response.statusCode == 200) {
      final userInfo = json.decode(response.body);
      print('userInfo');
      print(userInfo);
      print(userInfo['user_id']);
      print('userInfo');
      return userInfo['user_id'];
    } else {
      return null;
    }
  }
}

class Product {
  final String name;
  final String address;
  final String description;

  Product({
    required this.name,
    required this.address,
    required this.description,
  });
}
