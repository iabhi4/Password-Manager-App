import 'package:flutter/material.dart';
import 'package:password_manager/screens/first_screen.dart';
import 'package:password_manager/screens/login_screen.dart';
import 'package:password_manager/screens/main_screen.dart';
import 'package:password_manager/screens/welcome_screen.dart';
import 'model/password_preferences.dart';
import 'package:password_manager/route.dart' as route;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PasswordSharedPreferences.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool hasRegistered = PasswordSharedPreferences.getHasRegistered() ?? false;
    return MaterialApp(
        theme: ThemeData(fontFamily: 'Lato', primaryColor: Color(0xFF212121), 
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue,
          ).copyWith(
            secondary: Color(0xFF4CAF50),
            background: Color(0xFFF5F5F5),
          ),
          scaffoldBackgroundColor: Color(0xFF303030),
          popupMenuTheme: PopupMenuThemeData(
            color: Color(0xFFF5F5F5)
          ),
          iconTheme: IconThemeData(
            color: Color.fromARGB(255, 204, 153, 255),
          ),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 204, 153, 255),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0),    
              borderSide: BorderSide(
                color: Color(0xFFFFFFFF),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0),   
              borderSide: BorderSide(
                color: Color.fromARGB(255, 204, 153, 255),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0),   
              borderSide: BorderSide(
                color: Color.fromARGB(255, 204, 153, 255),
              ),
            ),
          ),
          dialogTheme: DialogTheme(
            backgroundColor: Color(0xFF303030),
            elevation: 10.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            titleTextStyle: TextStyle(color: Color(0xFFFFFFFF), fontSize: 24),
            contentTextStyle: TextStyle(color: Color(0xFFFFFFFF),
          ),)),
        restorationScopeId: "root",
        onGenerateRoute: route.controller,
        home: hasRegistered ? LoginScreen() : WelcomeScreen());
  }
}
