import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:plant_monitor_app/screens/login_Screens.dart';
import 'package:plant_monitor_app/widgets/singleFarm.dart';
import 'package:provider/provider.dart';
import 'package:plant_monitor_app/screens/product_registration_screen.dart';
import 'package:plant_monitor_app/state/product_state.dart';
import '../state/farm_state.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/homeScreen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LocalStorage storage = LocalStorage('usertoken');

  bool _init = true;
  bool _isLoading = false;

  // Add a function for logging out
  void logout() async {
    await storage.clear();
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }

  // Function to open the registration page
  void openRegistrationPage() {
    Navigator.of(context).pushNamed(ProductRegistrationScreen.routeName);
  }

  @override
  void didChangeDependencies() async {
    if (_init) {
      _isLoading =
          await Provider.of<FarmState>(context, listen: false).getFarms();
      setState(() {
        // Your logic for data loading
      });
    }
    _init = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final farm = Provider.of<FarmState>(context).farms;
    if (!_isLoading)
      return Scaffold(
        appBar: AppBar(
          title: Text('Sensor Data'),
          actions: [
            IconButton(
              icon: Icon(Icons.power_settings_new),
              onPressed: () {
                logout();
              },
            ),
          ],
        ),
        body: Center(
          child: Text('No Data Found'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: openRegistrationPage, // Open the registration page
          child: Icon(Icons.add),
        ),
      );
    else
      return Scaffold(
        appBar: AppBar(
          title: Text('Home Screen'),
          actions: [
            IconButton(
              icon: Icon(Icons.power_settings_new),
              onPressed: () {
                logout();
              },
            ),
          ],
        ),
        body: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 3 / 2,
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            return SingleFarm(
              id: farm[index].id,
              name: farm[index]?.name ?? 'Default Name',
              description: farm[index].description ?? 'Default Description',
              address: farm[index].address ?? 'Default Address',
            );
          },
          itemCount: farm.length,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: openRegistrationPage,
          child: Icon(Icons.add),
        ),
      );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Color customGreen = Color(0xFF00692B);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProductState()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MPI Product Registration',
        theme: ThemeData(
          primarySwatch: MaterialColor(
            customGreen.value,
            <int, Color>{
              50: customGreen,
              100: customGreen,
              200: customGreen,
              300: customGreen,
              400: customGreen,
              500: customGreen,
              600: customGreen,
              700: customGreen,
              800: customGreen,
              900: customGreen,
            },
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => HomeScreen(),
          ProductRegistrationScreen.routeName: (context) =>
              ProductRegistrationScreen(),
        },
      ),
    );
  }
}
