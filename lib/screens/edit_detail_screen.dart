import 'package:flutter/material.dart';
import 'package:password_manager/model/password_preferences.dart';
import 'package:clipboard/clipboard.dart';
import 'package:password_manager/model/encrypt_decrypt_data.dart';
import 'package:regexed_validator/regexed_validator.dart';
import 'package:password_manager/route.dart' as route;

class EditDetailScreen extends StatefulWidget {
  late String serviceName;
  late String encryptionKey;
  var viewDetailScreenMap;
  EditDetailScreen(this.viewDetailScreenMap) {
    late Map argumentsMap;
    if(viewDetailScreenMap is Map){
      argumentsMap = viewDetailScreenMap as Map;
      encryptionKey = argumentsMap['encryptionKey'];
      serviceName = argumentsMap['serviceName'];
    } 
  }

  @override
  EditDetailScreenState createState() => EditDetailScreenState();
}

class EditDetailScreenState extends State<EditDetailScreen> {
  final emailController = TextEditingController();
  final websiteController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isUsernameAvailable = false;
  bool isWebsiteAvailable = false;
  bool _passwordVisible = false;
  bool isSubmitButtonEnabled = true;
  String? emailErrorText;

    @override
  void initState() {
    super.initState();
    _retrieveAllData();
  }

  void _retrieveAllData() async {
    emailController.text =
        PasswordSharedPreferences.getEmail(widget.serviceName) ?? '';
    websiteController.text =
        PasswordSharedPreferences.getWebsite(widget.serviceName) ?? '';
    usernameController.text =
        PasswordSharedPreferences.getUsername(widget.serviceName) ?? '';
    passwordController.text =
        PasswordSharedPreferences.getPassword(widget.serviceName) ?? '';
    EncryptData encryptData =  EncryptData(widget.encryptionKey);
    String decryptedPassword = encryptData.decryptAES(passwordController.text);
    passwordController.text = decryptedPassword;
    if (websiteController.text.isNotEmpty) {
      setState(() {
        isWebsiteAvailable = true;
      });
    }
    if (usernameController.text.isNotEmpty) {
      setState(() {
        isUsernameAvailable = true;
      });
    }
  }

  void _setFalseStateSubmitButton() {
    setState(() {
      isSubmitButtonEnabled = false;
    });
  }

  String? get _emailErrorText {
    String email = emailController.text;
    if (email.isEmpty) {
      _setFalseStateSubmitButton();
      emailErrorText = null;
      return null;
    }
    if (!email.isEmpty && !validator.email(email)) {
      _setFalseStateSubmitButton();
      emailErrorText = "Enter correct email";
      return "Enter correct email";
    }
    emailErrorText = null;
    return null;
  }

  String? get _passwordErrorText {
    String password = passwordController.text;
    if (password.isEmpty) {
      _setFalseStateSubmitButton();
    } else if (password.isNotEmpty && (password.contains(' ') || password.contains("\""))) {
      _setFalseStateSubmitButton();
    }
    return null;
  }

  void _copyToClipboard(String value) {
    FlutterClipboard.copy(value);
  }

  Future _openSubmitButtonDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
            content: Container(
                constraints: BoxConstraints.tightFor(height: 100.0),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Overwrite existing data?',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(onPressed: () => _submitButtonHandler(), child: Text('Yes'))
                    ],
                  ),
                ))),
      );

  void _submitButtonHandler() {
    String existingPassword = PasswordSharedPreferences.getPassword(widget.serviceName) ?? '';
    String existingUsername = PasswordSharedPreferences.getUsername(widget.serviceName) ?? '';
    EncryptData encryptData =  EncryptData(widget.encryptionKey);
    String decryptedPassword = encryptData.decryptAES(existingPassword);
    existingPassword = decryptedPassword;
    String existingEmail = PasswordSharedPreferences.getEmail(widget.serviceName) ?? '';
    if(existingPassword != passwordController.text) {
    String encryptedPassword = encryptData.encryptAES(passwordController.text);
      PasswordSharedPreferences.setPassword(widget.serviceName, encryptedPassword);
    }
    if(existingUsername != usernameController.text) {
      PasswordSharedPreferences.setUsername(widget.serviceName, usernameController.text);
    }
    if(existingEmail != emailController.text) {
      PasswordSharedPreferences.setEmail(widget.serviceName, emailController.text);
    }
    Navigator.pushNamed(context, route.mainScreen, arguments: widget.encryptionKey);
  }

  @override
  Widget build(BuildContext context) {
    /*Future.delayed(Duration.zero, () {
      _retrieveAllData();
    });*/
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.serviceName.toUpperCase(),
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _emailTextField(),
            _passwordTextField(),
            if (isUsernameAvailable) _usernameTextField(),
            if (isWebsiteAvailable) _websiteTextField(),
            ElevatedButton(
                  onPressed:
                      isSubmitButtonEnabled ? _openSubmitButtonDialog : null,
                  child: Text('Submit')),
          ],
        ),
      ),
    );
  }

  Widget _emailTextField() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: TextField(
        enableInteractiveSelection: true,
        decoration: InputDecoration(
          labelText: 'Email',
          errorText : _emailErrorText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        controller: emailController,
        onTap: (() => _copyToClipboard(emailController.text)),
      ),
    );
  }

  Widget _passwordTextField() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: TextField(
        enableInteractiveSelection: true,
        obscureText: !_passwordVisible,
        decoration: InputDecoration(
          labelText: 'Password',
          errorText: _passwordErrorText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: IconButton(
            icon: Icon(
              _passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: Theme.of(context).primaryColorDark,
            ),
            onPressed: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
          ),
        ),
        controller: passwordController,
        onTap: (() => _copyToClipboard(passwordController.text)),
      ),
    );
  }

  Widget _usernameTextField() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: TextField(
        enableInteractiveSelection: true,
        decoration: InputDecoration(
          labelText: 'Username',
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        controller: usernameController,
        onTap: (() => _copyToClipboard(usernameController.text)),
      ),
    );
  }

  Widget _websiteTextField() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: TextField(
        readOnly: true,
        enableInteractiveSelection: true,
        decoration: InputDecoration(
          labelText: 'Website',
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        controller: websiteController,
        onTap: (() => _copyToClipboard(websiteController.text)),
      ),
    );
  }
}
