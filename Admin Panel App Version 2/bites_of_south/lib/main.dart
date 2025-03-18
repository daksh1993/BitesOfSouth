import 'package:bites_of_south/Controller/Authentication/login_auth_provider.dart';
import 'package:bites_of_south/Controller/Authentication/otp_verify_screen_auth.dart';
import 'package:bites_of_south/Controller/Authentication/phone_auth_provider.dart';
import 'package:bites_of_south/Controller/Menu/menu_load_auth.dart';
import 'package:bites_of_south/Controller/menu_provider.dart';
import 'package:bites_of_south/View/Authentication/loginScreen.dart';
import 'package:bites_of_south/View/Dashboard.dart';
import 'package:bites_of_south/firebase_options.dart';
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
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => LoginAuthProvider()),
        ChangeNotifierProvider(create: (_) => PhoneValidityProvider()),
        ChangeNotifierProvider(create: (_) => OTPVerifyScreenAuth()),
        ChangeNotifierProvider(create: (_) => MenuLoadAuth()),
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
      initialRoute: '/login', // Set initial route to login
      routes: {
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => DashboardScreen(),
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
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
