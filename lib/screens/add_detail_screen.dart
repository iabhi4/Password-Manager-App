import 'package:flutter/material.dart';
import 'package:password_manager/model/password_preferences.dart';
import 'package:regexed_validator/regexed_validator.dart';
import 'package:password_manager/model/encrypt_decrypt_data.dart';
import 'package:password_manager/route.dart' as route;

class AddDetailScreen extends StatefulWidget {

  final String encryptionKey;
  AddDetailScreen(this.encryptionKey);

  @override
  AddDetailScreenState createState() => AddDetailScreenState();
}

class AddDetailScreenState extends State<AddDetailScreen> {
  Icon closeIcon = new Icon(Icons.close, color: Colors.white, size: 30.0);
  final serviceNameController = TextEditingController();
  final websiteController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final additionalInfoController = TextEditingController();
  late List<String> servicesList;
  String? serviceNameErrorText;
  String? websiteErrorText;
  String? emailErrorText;
  bool isSubmitButtonEnabled = true;
  bool _passwordVisible = false;
  String serviceNameHelperText = '';

  @override
  void initState() {
    super.initState();
    servicesList = PasswordSharedPreferences.getServicesList() ?? [];
  }

  void dispose() {
    super.dispose();
  }

  void _routetoMainScreen() {
    Navigator.pushNamed(context, route.mainScreen, arguments: widget.encryptionKey);
  }

  void _clearTextControllers() {
    serviceNameController.clear();
    websiteController.clear();
    emailController.clear();
    usernameController.clear();
    passwordController.clear();
    additionalInfoController.clear();
  }

  void _submitButtonHandler() {
    if(!servicesList.contains(serviceNameController.text.toLowerCase())){
      servicesList.add(serviceNameController.text.toLowerCase());
    }
    EncryptData encryptData = EncryptData(widget.encryptionKey);
    String encryptedPassword = encryptData.encryptAES(passwordController.text);
    PasswordSharedPreferences.setServicesList(servicesList);
    PasswordSharedPreferences.setPassword(
        serviceNameController.text.toLowerCase(), encryptedPassword);
    PasswordSharedPreferences.setEmail(
        serviceNameController.text.toLowerCase(), emailController.text);
    if (websiteController.text.isNotEmpty) {
      PasswordSharedPreferences.setWebsite(
          serviceNameController.text.toLowerCase(), websiteController.text);
    }
    if (usernameController.text.isNotEmpty) {
      PasswordSharedPreferences.setUsername(
          serviceNameController.text.toLowerCase(), usernameController.text);
    }
    if(additionalInfoController.text.isNotEmpty) {
      PasswordSharedPreferences.setAdditionalInfo(serviceNameController.text.toLowerCase(), additionalInfoController.text);
    }
    _clearTextControllers();
    _routetoMainScreen();
  }

  void _closeButtonClickHandler() {
    _clearTextControllers();
    _routetoMainScreen();
  }

  void _setTrueStateSubmitButton() {
    setState(() {
      isSubmitButtonEnabled = true;
    });
  }

  void _setFalseStateSubmitButton() {
    setState(() {
      isSubmitButtonEnabled = false;
    });
  }

  String? get _serviceNameHelperText {
    String serviceName = serviceNameController.text;
    if(servicesList.contains(serviceName.toLowerCase())) {
        return "Already Exists, Data will be overwritten";
    }
  }

  String? get _serviceNameErrorText {
    String serviceName = serviceNameController.text;
    if (serviceName.isEmpty) {
      _setFalseStateSubmitButton();
      serviceNameErrorText = null;
      return null;
    }
    if (websiteErrorText == null && emailErrorText == null) {
      _setTrueStateSubmitButton();
    }
    serviceNameErrorText = null;
    return null;
  }

  String? get _websiteNameErrorText {
    String url = websiteController.text;
    if (!url.startsWith("http://") || !url.startsWith("https://")) {
      url = "https://" + url;
    }
    if (!url.endsWith("https://") && !validator.url(url)) {
      _setFalseStateSubmitButton();
      websiteErrorText = "Enter correct website";
      return "Enter correct website";
    }
    if (serviceNameErrorText == null && emailErrorText == null) {
      _setTrueStateSubmitButton();
    }
    websiteErrorText = null;
    return null;
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
    if (serviceNameErrorText == null && websiteErrorText == null) {
      _setTrueStateSubmitButton();
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

  Future<bool> _onWillPop() async {
    return true;
  }

  Widget addDetailScaffold() {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Add Detail',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge!.color)),
          backgroundColor: Theme.of(context).primaryColor,
          actions: [
            new IconButton(onPressed: _closeButtonClickHandler, icon: closeIcon)
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Service Name',
                    errorText: _serviceNameErrorText,
                    errorStyle: TextStyle(fontWeight: FontWeight.bold),
                    helperText: _serviceNameHelperText,
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    labelStyle: TextStyle(fontWeight: FontWeight.w200, color: Theme.of(context).textTheme.bodyLarge!.color),
                  ),
                  controller: serviceNameController,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Website',
                    errorText: _websiteNameErrorText,
                    errorStyle: TextStyle(fontWeight: FontWeight.bold),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    labelStyle: TextStyle(fontWeight: FontWeight.w200, color: Theme.of(context).textTheme.bodyLarge!.color),
                  ),
                  controller: websiteController,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: _emailErrorText,
                    errorStyle: TextStyle(fontWeight: FontWeight.bold),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    labelStyle: TextStyle(fontWeight: FontWeight.w200, color: Theme.of(context).textTheme.bodyLarge!.color),
                  ),
                  controller: emailController,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Username',
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    labelStyle: TextStyle(fontWeight: FontWeight.w200, color: Theme.of(context).textTheme.bodyLarge!.color),
                  ),
                  controller: usernameController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(fontWeight: FontWeight.w200, color: Theme.of(context).textTheme.bodyLarge!.color),
                    errorText: _passwordErrorText,
                    errorStyle: TextStyle(fontWeight: FontWeight.bold),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
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
                  controller: passwordController,
                  obscureText: !_passwordVisible,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Additonal Info (if any)',
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    labelStyle: TextStyle(fontWeight: FontWeight.w200, color: Theme.of(context).textTheme.bodyLarge!.color),
                  ),
                  controller: additionalInfoController,
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                  onPressed: _submitButtonHandler, child: Text('Submit', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color))),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext build) {
    return WillPopScope(child: addDetailScaffold(), onWillPop: _onWillPop);
  }
}
