import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:password_manager/model/password_preferences.dart';
import 'package:password_manager/route.dart' as route;
import 'package:crypto/crypto.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final enteredPasswordController = TextEditingController();
  String encryptionKey = '';
  String messageToDisplay = '';
  final String wrongMessage = "Incorrect Password";
  bool _passwordVisible = false;

/*****************************************BACKEND STARTS**************************************************** */
  @override
  void initState() {
    super.initState();
  }

  String hashString(String value) {
    String passwordhash = sha256.convert(utf8.encode(value)).toString();
    return passwordhash;
  }

  void _comparePassword() {
    String? rootPassword = PasswordSharedPreferences.getRootPassword();
    String passwordhash = hashString(enteredPasswordController.text);
    if (rootPassword != null && rootPassword == passwordhash) {
      encryptionKey = enteredPasswordController.text;
      Navigator.pushNamed(context, route.mainScreen, arguments: encryptionKey);
    }
    else {
      setState(() {
        messageToDisplay = wrongMessage;
      });
    }
    enteredPasswordController.clear();
  }

  Future<bool> onWillPop() async {
    enteredPasswordController.clear();
    _showDialog("Confirm Exit?", "Yes", _exitButtonHandler);
    return false;
  }

  void _exitButtonHandler() {
    SystemNavigator.pop();
  }

  void _onTextFieldChange() {
    setState(() {
      messageToDisplay = '';
    });
    String? rootPassword = PasswordSharedPreferences.getRootPassword();
    String passwordhash = hashString(enteredPasswordController.text);
    if (rootPassword != null && rootPassword == passwordhash) {
      encryptionKey = enteredPasswordController.text;
      Navigator.pushNamed(context, route.mainScreen, arguments: encryptionKey);
    }
      
  }
  /*****************************************BACKEND ENDS**************************************************** */

  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: loginScreenScaffold(), onWillPop: onWillPop);
  }

/*****************************************FRONTEND STARTS**************************************************** */

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


  Scaffold loginScreenScaffold() {
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
                SizedBox(height: 60.0),
                Text("Your Passwords?",
                    style:
                        TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                SizedBox(height: 10.0),
                Text("Got you covered!!",
                    style:
                        TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                SizedBox(height: 40.0),
                Icon(
                  Icons.lock_open,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  size: 85.0,
                ),
                SizedBox(height: 80.0),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 60.0, right: 60.0, top: 10.0),
                  child: TextField(
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0)),
                        hintText: 'Root password',
                        hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      controller: enteredPasswordController,
                      onChanged: (value) => _onTextFieldChange()),
                ),
                SizedBox(height: 10.0),
                ElevatedButton(
                    onPressed: _comparePassword, child: Text('Submit', style:
                        TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color))),
                Text(messageToDisplay, style:
                        TextStyle(fontWeight: FontWeight.normal, color: Theme.of(context).textTheme.bodyLarge?.color)),
              ],
            ),
          ),
        ));
  }
/*****************************************FRONTEND ENDS**************************************************** */
}
