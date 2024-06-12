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
    SystemNavigator.pop();
    return false;
  }

  void _routeToSignUpPage() {
    Navigator.pushNamed(context, route.firstScreen);
  }

  void _routeToLoginPage() {
    Navigator.pushNamed(context, route.loginScreen);
  }

  void _importButtonHandler() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      String jsonString = file.readAsStringSync();
      Map<String, dynamic> fileContents = jsonDecode(jsonString);
      if(!fileContents.containsKey("rootPassword") || !fileContents.containsKey("hasRegistered")) {
        String message = "Import Failed, Wrong file";
        _openImportFailedDialog(message);
        return;
      }
      PasswordSharedPreferences.importKeysFromJson(fileContents);
      _openImportSuccessDialog();
    } else {
      String message = "Import failed, Please try again";
      _openImportFailedDialog(message);
    }
  }

  Future _openImportSuccessDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
            content: Container(
                constraints: BoxConstraints.tightFor(height: 100.0),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Done importing, Please log back in',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(onPressed: _routeToLoginPage,
                      child: Text('Ok'))
                    ],
                  ),
                ))),
      );

  Future _openImportFailedDialog(String message) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
            content: Container(
                constraints: BoxConstraints.tightFor(height: 100.0),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        message,
                        style: TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Ok'))
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

            },
            child: Text('Import Backup'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, route.firstScreen);
            },
            child: Text('Sign Up'),
          ),
        ],
      );
    },
  );
}

  Scaffold welcomeScreenScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Password Manager',
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
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
                    color: Colors.black87),
              ),
              SizedBox(
                height: 80.0,
              ),
              Text(
                'New here or back?',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30.0,
              ),
              ElevatedButton(
                  onPressed: _routeToSignUpPage, child: Text('I\'m New')),
              SizedBox(
                height: 30.0,
              ),
              ElevatedButton(
                  onPressed: _signUpPageDialog, child: Text('I\'m Returning')),
            ],
          ),
        ),
      ),
    );
  }
}