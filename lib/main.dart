import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:vitbhopal/features/app/splach_screen/splash_screen.dart';
import 'package:vitbhopal/features/user_auth/presentation/pages/home_page.dart';
import 'package:vitbhopal/features/user_auth/presentation/pages/login_page.dart';
import 'package:vitbhopal/features/user_auth/presentation/pages/sign_up_page.dart';
import 'package:vitbhopal/features/user_auth/presentation/pages/home.dart';
import 'package:vitbhopal/features/user_auth/presentation/pages/search.dart';
import 'package:vitbhopal/features/user_auth/presentation/pages/ai.dart';
import 'package:vitbhopal/features/user_auth/presentation/pages/profile.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb)
  {
    await Firebase.initializeApp(options:FirebaseOptions(apiKey: "AIzaSyCko9BA7YDPrIYevZWdtTbFqAGJkf_JDTU", appId:"1:244302198963:web:8f49b3d671db5c6db098c6", messagingSenderId:"244302198963", projectId:"vitchatbot-94975",),);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase',
      routes: {
        '/': (context) => SplashScreen(
          // Here, you can decide whether to show the LoginPage or HomePage based on user authentication
          child: LoginPage(),
        ),
        '/login': (context) => LoginPage(),
        '/signUp': (context) => SignUpPage(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
