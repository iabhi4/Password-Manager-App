import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';
import 'package:password_manager/model/password_preferences.dart';
import 'package:password_manager/route.dart' as route;
import 'package:file_picker/file_picker.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: welcomeScreenScaffold(), onWillPop: onWillPop);
  }

  Future<bool> onWillPop() async {
    _showDialog("Confirm Exit?", "Yes", _exitButtonHandler);
    return false;
  }

  void _exitButtonHandler() {
    SystemNavigator.pop();
  }

  void _routeToSignUpPage() {
    Navigator.pushNamed(context, route.firstScreen);
  }

  void _routeToLoginPage() {
    Navigator.pushNamed(context, route.loginScreen);
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  void _importButtonHandler() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      String jsonString = file.readAsStringSync();
      Map<String, dynamic> fileContents = jsonDecode(jsonString);
      if(!fileContents.containsKey("rootPassword") || !fileContents.containsKey("hasRegistered")) {
        _showDialog("Import Failed, Wrong file", "Ok", _closeDialog);
        return;
      }
      PasswordSharedPreferences.importKeysFromJson(fileContents);
      _showDialog('Done importing, Please log back in', 'Ok', _routeToLoginPage);
    } else {
      _showDialog("Import failed, Please try again", 'Ok', _closeDialog);
    }
  }

  Future _showDialog(String message, String buttonMessage, Function method) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
            content: Container(
                constraints: BoxConstraints.tightFor(height: 100.0),
                child: Center(
                  child: Column(
                    children: [
                      SelectableText(
                        message,
                        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () => method(),
                        child: Text(buttonMessage, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(80, 25),
                          backgroundColor: Theme.of(context).elevatedButtonTheme.style?.backgroundColor?.resolve({})
                        ),
                      )
                    ],
                  ),
                ))),
      );

  Future<void> _signUpPageDialog() async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Existing User'),
        content: Text('Do you have a backup file that you want to import?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              _importButtonHandler();
            },
            child: Text('Import Backup', style: TextStyle(fontWeight: FontWeight.bold ,color: Theme.of(context).iconTheme.color)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, route.firstScreen);
            },
            child: Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold ,color: Theme.of(context).iconTheme.color)),
          ),
        ],
      );
    },
  );
}

  Scaffold welcomeScreenScaffold() {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Password Manager", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),),
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
        ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 100.0),
              Text(
                'Welcome',
                style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              SizedBox(
                height: 80.0,
              ),
              Text(
                'New here or back?',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              SizedBox(
                height: 30.0,
              ),
              ElevatedButton(
                  onPressed: _routeToSignUpPage, child: Text('I\'m New', style: TextStyle(fontWeight: FontWeight.bold ,color: Theme.of(context).textTheme.bodyLarge?.color))),
              SizedBox(
                height: 30.0,
              ),
              ElevatedButton(
                  onPressed: _signUpPageDialog, child: Text('I\'m Returning', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color))),
            ],
          ),
        ),
      ),
    );
  }
}