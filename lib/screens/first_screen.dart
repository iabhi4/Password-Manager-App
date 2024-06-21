import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:password_manager/model/password_preferences.dart';
import 'package:password_manager/route.dart' as route;
import 'package:crypto/crypto.dart';
import 'dart:convert';


class FirstScreen extends StatefulWidget {
  const FirstScreen({Key? key}) : super(key: key);

  @override
  FirstScreenState createState() => FirstScreenState();
}

class FirstScreenState extends State<FirstScreen> {
  final enteredPasswordController = TextEditingController();
  final reEnteredPasswordController = TextEditingController();
  String warningMessage = '';
  bool _passwordVisible = false;
  double passwordStrength = 0.0;

/*****************************************BACKEND STARTS**************************************************** */

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialogForFirstTime();
    });

    enteredPasswordController.addListener(() {
      setState(() {
        passwordStrength = _calculatePasswordStrength(enteredPasswordController.text);
      });
    });
  }

  Future<bool> onWillPop() async {
    _clearTextControllers();
    _showDialog("Confirm Exit?", "Yes", _exitButtonHandler);
    return false;
  }
  
  void _exitButtonHandler() {
    SystemNavigator.pop();
  }

  void _clearTextControllers() {
    enteredPasswordController.clear();
    reEnteredPasswordController.clear();
  }

  void _submitButtonHandler() async {
    if (enteredPasswordController.text.isEmpty) {
      return;
    }
    if(passwordStrength < 0.7) {
      setState(() {
        warningMessage = "Please choose a strong password";
      }); 
    }
    if(enteredPasswordController.text.contains(' ') || enteredPasswordController.text.contains("\"") ||
      reEnteredPasswordController.text.contains(' ') || reEnteredPasswordController.text.contains("\"")) {
      setState(() {
        warningMessage = "You cannot have space or \" in your password";
      }); 
    }
    else if (enteredPasswordController.text == reEnteredPasswordController.text) {
      String passwordhash = sha256.convert(utf8.encode(enteredPasswordController.text)).toString();
      await PasswordSharedPreferences.setRootPassword(
          passwordhash);
      await PasswordSharedPreferences.setHasRegistered(true);
      Navigator.pushNamed(context, route.loginScreen);
    } else {
      setState(() {
        warningMessage = "Your passwords didn't match";
      });
    }
    _clearTextControllers();
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) {
      return 0.0;
    }
    int strength = 0;
    if (password.length >= 8) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) strength++;
    return strength / 5;
  }
/*****************************************BACKEND ENDS**************************************************** */


/*****************************************FRONTEND STARTS**************************************************** */

  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: firstScreenScaffold(), onWillPop: onWillPop);
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

  Future<void> _showWelcomeDialogForFirstTime() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Welcome!', style:
                        TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
          content: Text('Please configure your root password to secure the app\n\nThis is the only password that you have to remember so choose a strong one', style:
                        TextStyle(fontWeight: FontWeight.normal, color: Theme.of(context).textTheme.bodyLarge?.color)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            ),
          ],
        );
      },
    );
  }

  Scaffold firstScreenScaffold() {
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
              Text(
                'Own your passwords',
                style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              SizedBox(
                height: 30.0,
              ),
              Icon(
                  Icons.lock_open,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  size: 85.0,
                ),
              SizedBox(
                height: 100.0,
              ),
              Text(
                'Configure your root password here',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 35.0, right: 35.0, top: 5.0),
                child: TextField(
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22.0)),
                      hintText: 'Enter a password',
                      hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7))),
                  controller: enteredPasswordController,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 35.0, right: 35.0, top: 5.0),
                child: TextField(
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22.0)),
                    hintText: 'Re-enter password',
                    hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7)),
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
                  controller: reEnteredPasswordController,
                ),
              ),
              SizedBox(height: 8.0),
              ElevatedButton(
                  onPressed: _submitButtonHandler, child: Text('Submit', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color))),
              if (!enteredPasswordController.text.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 35.0, right: 35.0, top: 5.0),
                  child: LinearProgressIndicator(
                    value: passwordStrength,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      passwordStrength < 0.3
                          ? Colors.red
                          : passwordStrength < 0.7
                              ? Colors.yellow
                              : Colors.green,
                    ),
                  ),
                ),
              SizedBox(height: 6.0),
              Text(warningMessage, style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.red))
            ],
          ),
        ),
      ),
    );
  }
/*****************************************FRONTEND ENDS**************************************************** */

}
