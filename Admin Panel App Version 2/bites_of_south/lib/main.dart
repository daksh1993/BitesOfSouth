import 'dart:math';

import 'package:bites_of_south/Controller/Authentication/login_auth_provider.dart';
import 'package:bites_of_south/Controller/Authentication/otp_verify_screen_auth.dart';
import 'package:bites_of_south/Controller/Authentication/phone_auth_provider.dart';
import 'package:bites_of_south/Controller/Menu/item_detail_auth_provider.dart';
import 'package:bites_of_south/Controller/Menu/menu_load_auth.dart';
import 'package:bites_of_south/View/Authentication/loginScreen.dart';
import 'package:bites_of_south/View/Dashboard.dart';
import 'package:bites_of_south/View/Orders/orderspanel.dart';
import 'package:bites_of_south/firebase_options.dart';
import 'package:bites_of_south/generate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        // ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => LoginAuthProvider()),
        ChangeNotifierProvider(create: (_) => PhoneValidityProvider()),
        ChangeNotifierProvider(create: (_) => OTPVerifyScreenAuth()),
        ChangeNotifierProvider(create: (_) => MenuLoadAuth()),
        ChangeNotifierProvider(create: (_) => ItemDetailAuthProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // initialRoute: '/mainPage', // Set initial route to login
      initialRoute: '/login', // Set initial route to login
      // initialRoute: '/generate', // Set initial route to login
      // initialRoute: '/cookPage', // Set initial route to login

      routes: {
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/cookPage': (context) => CookOrderScreen(),
        '/mainPage': (context) => MyHomePage(
              title: 'BitesOf South',
            ),
        '/generate': (context) => OrderGeneratorButton(),
      },
      // Remove home property since we're using routes
    );
  }
}

// You can keep MyHomePage if you need it for testing, but it's not used in the current flow
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> updateMenuMakingPrices() async {
    try {
      // Get reference to the menu collection
      CollectionReference menuRef =
          FirebaseFirestore.instance.collection('menu');

      // List of possible percentage reductions
      final List<int> percentages = [45, 32, 67, 74];

      // Get random percentage
      int getRandomPercentage() =>
          percentages[Random().nextInt(percentages.length)];

      // Get all documents
      QuerySnapshot snapshot = await menuRef.get();

      // Create a batch write
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Process each document
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        // Get the price from document data
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('price')) {
          // Convert price to double, handling both String and num cases
          double price;
          if (data['price'] is String) {
            price = double.parse(data['price']);
          } else if (data['price'] is num) {
            price = (data['price'] as num).toDouble();
          } else {
            continue; // Skip if price is neither String nor num
          }

          // Calculate makingPrice with random reduction
          int reductionPercent = getRandomPercentage();
          double reductionAmount = price * (reductionPercent / 100);
          double makingPrice = price - reductionAmount;

          // Add update to batch
          batch.update(doc.reference, {
            'makingPrice': double.parse(makingPrice.toStringAsFixed(2)),
          });
        }
      }

      // Commit the batch
      await batch.commit();
      print('Menu prices updated successfully');
    } catch (e) {
      print('Error updating menu prices: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: updateMenuMakingPrices,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
