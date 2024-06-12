import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:password_manager/model/password_preferences.dart';
import 'package:password_manager/route.dart' as route;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:password_manager/model/encrypt_decrypt_data.dart';
import 'package:permission_handler/permission_handler.dart';


class MainScreen extends StatefulWidget {
  final String encryptionKey;
  MainScreen(this.encryptionKey);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late List<String> servicesList;
  late List<String> searchList;
  Map viewDetailScreenMap = new Map<String, String>();
  final serviceNameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  static const String _logOut = 'Log Out';
  static const String _settings = 'Settings';
  static const String _exit = 'Exit';
  static const String _backup = 'Backup';
  static const String _import = 'Import';
  bool _isListItemSelected = false;
  int _selectedListItemIndex = -1;
  static const List<String> choices = <String>[/*_settings,*/ _backup, _import, _logOut, _exit];
  late bool _IsSearching;
  String _searchText = "";
  Icon actionIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  Widget appBarTitle = Text('Passwords',
      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold));

  @override
  void initState() {
    super.initState();
    _IsSearching = false;
    setState(() {
      servicesList = PasswordSharedPreferences.getServicesList() ?? [];
    });
    searchList = [];
  }

  Future<bool> onWillPop() async {
    if(_isListItemSelected) {
      setState(() {
        _isListItemSelected = false;
        _selectedListItemIndex = -1;
      });
      return false;
    }
    _openExitDialog();
    return false;
  }

  void _logoutButtonHandler() {
    Navigator.pushNamed(context, route.loginScreen);
  }

  void _downloadBackupFile() async {
    final jsonData = serializeSharedPreferences();
    final jsonString = jsonEncode(jsonData);
    final directory = await getExternalStorageDirectory();
    if (directory != null) {
    final filePath = '${directory.path}/backupDetails.txt';
    final file = File(filePath);
    try {
      await file.writeAsString(jsonString);
      print('File saved to downloads directory: $filePath');
      _downloadCompleteDialog(filePath);
    } catch (e) {
      print('Error saving file: $e');
    }
    } else {
      print('Downloads directory not found');
    }
    /*if (await _requestPermissions()) {
      final jsonData = serializeSharedPreferences();
      final jsonString = jsonEncode(jsonData);

      try {
        String? directoryPath = await FilePicker.platform.getDirectoryPath();
        if (directoryPath != null) {
          final filePath = '$directoryPath/backupDetails.txt';
          final file = File(filePath);

          await file.writeAsString(jsonString);
          print('File saved to chosen directory: $filePath');
          _downloadCompleteDialog(filePath);
        } else {
          print('Directory not selected');
        }
      } catch (e) {
        print('Error saving file: $e');
      }
    } else {
      print('Storage permissions not granted');
    }*/
  }

  Future<bool> _requestPermissions() async {
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      return true;
    } else {
      openAppSettings();
      return false;
    }
  }

  Future _downloadCompleteDialog(String path) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
            content: Container(
                constraints: BoxConstraints.tightFor(height: 100.0),
                child: Center(
                  child: Column(
                    children: [
                      SelectableText(
                        'Downloaded @ $path',
                        style: TextStyle(fontSize: 10.0),
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Ok'),
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(80, 25), // Adjust the width and height as needed
                        ),
                      )
                    ],
                  ),
                ))),
      );

  Widget _itemTitle(String service) {
    return Container(child: Text(service));
  }

  Widget _itemThumbnail(String service) {
    return Container(
        constraints: BoxConstraints.tightFor(width: 90.0),
        child: Image(image: AssetImage('assets/lockImage.png'), fit: BoxFit.fitWidth));
  }

  void _clearTextControllers() {
    serviceNameController.clear();
    usernameController.clear();
    passwordController.clear();
  }

  void _choiceAction(String choice) {
    if (choice == _logOut) {
      _logoutButtonHandler();
    } /*else if (choice == _settings) {
      print('Settings');
    }*/
    else if (choice == _exit) {
      _openExitDialog();
    }
    else if (choice == _backup) {
      _downloadBackupFile();
      //_openbackupDialog();
    }
    else if (choice == _import) {
      _importButtonHandler();
    }
  }

  void _handleSearchStart() {
    setState(() {
      _IsSearching = true;
      searchList.clear();
    });
  }

  void _handleSearchEnd() {
    setState(() {
      actionIcon = new Icon(
        Icons.search,
        color: Colors.white,
      );
      appBarTitle = new Text(
        "Passwords",
        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      );
      _IsSearching = false;
    });
  }

  void _buildSearchList(String value) {
    setState(() {
      searchList.clear();
    });
    this._searchText = value;
    if (!_IsSearching || _searchText == null || _searchText.isEmpty)
      return;
    for (int i = 0; i < servicesList.length; i++) {
      if (servicesList[i]
          .toUpperCase()
          .contains(_searchText.toUpperCase())) {
        setState(() {
          searchList.add(servicesList[i]);
        });
      }
    }
  }

  void _editDetail(String serviceName) {
    viewDetailScreenMap['serviceName'] = serviceName;
    viewDetailScreenMap['encryptionKey'] = widget.encryptionKey;
    Navigator.pushNamed(context, route.editDetailScreen,
      arguments: viewDetailScreenMap);
  }
  
  void _deleteDetail(String serviceName) {
    if(servicesList.contains(serviceName)) {
      setState(() {
        servicesList.remove(serviceName);
        PasswordSharedPreferences.setServicesList(servicesList);
        _isListItemSelected = false;
        _selectedListItemIndex = -1;
      });
      List<String> keysToRemove = ["Password", "Username", "Website", "Email"];
      for(String key in keysToRemove) {
        PasswordSharedPreferences.removeKey(serviceName+key);
      }
    }
  }

  void _importButtonHandler() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
    );
    if (result != null) {
        File file = File(result.files.single.path!);
        final input = file.openRead();
        final fields = await input.transform(utf8.decoder).transform(CsvToListConverter()).toList();
        if(fields[0][0].toString().toLowerCase() != 'service' || fields[0][1].toString().toLowerCase() != 'website'
           || fields[0][2].toString().toLowerCase() != 'email' || fields[0][3].toString().toLowerCase() != 'username'
           || fields[0][4].toString().toLowerCase() != 'password' || fields[0][5].toString().toLowerCase() != 'additional-info')
        {
          String message = "Import failed, CSV format mismatch";
          _openImportFailedDialog(message);
          return;
        }
        setState(() {
          importKeysFromCSV(fields);
        });
    } else {
      String message = "Import failed, Please try again";
      _openImportFailedDialog(message);
    }
  }

  Future importKeysFromCSV(List<List<dynamic>> csvList) async {
    List<dynamic> fields = csvList[0];
    for(int i=1;i<csvList.length;i++) {
      String serviceName = csvList[i][0];
      String website = csvList[i][1];
      String email = csvList[i][2];
      String username = csvList[i][3];
      String password = csvList[i][4];
      String additionalInfo = csvList[i][5];
      if(serviceName.isEmpty) continue;
      else {
        servicesList.add(serviceName);
        if(!website.isEmpty) {
          PasswordSharedPreferences.setWebsite(serviceName, website);
        }
        if(!email.isEmpty) {
          PasswordSharedPreferences.setEmail(serviceName, email);
        }
        if(!username.isEmpty) {
          PasswordSharedPreferences.setUsername(serviceName, username);
        }
        if(!password.isEmpty) {
          EncryptData encryptData = EncryptData(widget.encryptionKey);
          String encryptedPassword = encryptData.encryptAES(password);
          PasswordSharedPreferences.setPassword(serviceName, encryptedPassword);
        }
        if(!additionalInfo.isEmpty) {
          PasswordSharedPreferences.setAdditionalInfo(serviceName, additionalInfo);
        }
      }
    }
  }

  Map<String, dynamic> serializeSharedPreferences() {
    Set<String> keys = PasswordSharedPreferences.getAllKeys();
    Map<String, dynamic> data = {};
    for (var key in keys) {
      data[key] = PasswordSharedPreferences.getKeyValue(key);
    }
    return data;
  }

  void _exitApp() {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: mainScreenScaffold(), onWillPop: onWillPop);
  }

  Scaffold mainScreenScaffold() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: appBarTitle,
        actions: <Widget>[
          if (_isListItemSelected) // Show buttons only when a list tile is long-pressed
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              if(_selectedListItemIndex != -1) {
                _editDetail(servicesList[_selectedListItemIndex]);
                setState(() {
                  _selectedListItemIndex = -1;
                  _isListItemSelected = false;
                });
              }
            },
          ),
        if (_isListItemSelected) // Show buttons only when a list tile is long-pressed
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              if(_selectedListItemIndex != -1) {
                _openDeleteDialog(servicesList[_selectedListItemIndex]);
              }
              else {
                setState(() {
                  _selectedListItemIndex = -1;
                  _isListItemSelected = false;
                });
              }
            },
          ),
        if(!_isListItemSelected)
          new IconButton(
            icon: actionIcon,
            onPressed: () {
              setState(() {
                if (actionIcon.icon == Icons.search) {
                  this.actionIcon = new Icon(
                    Icons.close,
                    color: Colors.white,
                  );
                  appBarTitle = new TextField(
                    style: new TextStyle(
                      color: Colors.white,
                    ),
                    onChanged: (value) => _buildSearchList(value),
                    decoration: new InputDecoration(
                        prefixIcon: new Icon(Icons.search, color: Colors.white),
                        hintText: "Search...",
                        hintStyle: new TextStyle(color: Colors.white)),
                  );
                  _handleSearchStart();
                } else {
                  _handleSearchEnd();
                }
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: _choiceAction,
            itemBuilder: (BuildContext context) {
              return choices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ],
      ),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () =>
            Navigator.pushNamed(context, route.addDetailScreen, arguments: widget.encryptionKey),
      ),
      body: _IsSearching
          ? _buildListView(searchList)
          : _buildListView(servicesList),
    );
  }

  Future _openExitDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
            content: Container(
                constraints: BoxConstraints.tightFor(height: 100.0),
                child: Center(
                  child: Column(
                    children: [
                      const Text(
                        'Confirm Exit?',
                        style: TextStyle(fontSize: 22.0),
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(onPressed: _exitApp, child: Text('Exit'))
                    ],
                  ),
                ))),
      );

  Future _openDeleteDialog(String serviceName) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
            content: Container(
                constraints: BoxConstraints.tightFor(height: 100.0),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Delete $serviceName credentials?',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(onPressed: () {
                        _deleteDetail(serviceName);
                        Navigator.of(context).pop();
                      }, child: Text('Delete'))
                    ],
                  ),
                ))),
      );

  Future _openbackupDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
            content: Container(
                constraints: BoxConstraints.tightFor(height: 100.0),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Download backup file?',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(onPressed: () {
                        _downloadBackupFile();
                        Navigator.of(context).pop();
                      },
                      child: Text('Yes'))
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

  ListView _buildListView(List<String> serviceList) {
    return ListView.separated(
      itemCount: serviceList.length,
      itemBuilder: (context, index) {
        final isSelected = index == _selectedListItemIndex;
        return GestureDetector(
            onLongPress: () {
              setState(() {
                _isListItemSelected = true;
                _selectedListItemIndex = index;
              });
            },
            child: ListTile(
              contentPadding: EdgeInsets.all(10.0),
              tileColor: isSelected ? Colors.blue.shade50 : null,
              leading: _itemThumbnail(serviceList[index]),
              title: _itemTitle(serviceList[index]),
              onTap: () {
            if (_isListItemSelected) {
              // If selection is active, toggle selection
              setState(() {
                /*if (isSelected) {
                  // Deselect the item
                  _isListItemSelected = false;
                  _selectedListItemIndex = -1;
                } else {
                  // Select the item
                  _selectedListItemIndex = index;
                }*/
              });
            } else {
              // Handle regular tap action
              viewDetailScreenMap['serviceName'] = serviceList[index];
              viewDetailScreenMap['encryptionKey'] = widget.encryptionKey;
              Navigator.pushNamed(context, route.viewDetailScreen,
                  arguments: viewDetailScreenMap);
            }
          },
            ));
      },
      separatorBuilder: (context, index) {
        return const Divider(
          color: Colors.black,
        );
      },
    );
  }
}
