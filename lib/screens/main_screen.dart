import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:password_manager/model/password_preferences.dart';
import 'package:password_manager/route.dart' as route;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:password_manager/model/encrypt_decrypt_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:media_store_plus/media_store_plus.dart';


class MainScreen extends StatefulWidget {
  final String encryptionKey; //Passed during runtime, Inaccessible to anyone trying to gain the key
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
  static const String _reset = 'Reset';
  bool _isListItemSelected = false;
  int _selectedListItemIndex = -1;
  static const List<String> choices = <String>[_backup, _import, _reset, _logOut, _exit];
  late bool _IsSearching;
  String _searchText = "";
  final MediaStore mediaStore = MediaStore();
  Icon actionIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  Widget appBarTitle = Text('Passwords',
      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color(0xFFFFFFFF)));

/**********************************BACKEND CODE STARTS ******************************************************************/
  @override
  void initState() {
    super.initState();
    _IsSearching = false;
    initializeMediaStore();
    setState(() {
      servicesList = PasswordSharedPreferences.getServicesList() ?? [];
    });
    searchList = [];
  }

  Future<void> initializeMediaStore() async {
    await MediaStore.ensureInitialized();
    MediaStore.appFolder = 'MyAppBackup';
  }

  Future<bool> onWillPop() async {
    if(_isListItemSelected) {
      setState(() {
        _isListItemSelected = false;
        _selectedListItemIndex = -1;
      });
      return false;
    }
    _showDialog("Confirm Exit?", "Yes", _exitButtonHandler);
    return false;
  }

  void _logoutButtonHandler() {
    Navigator.pushNamed(context, route.loginScreen);
  }

  void _exitButtonHandler() {
    SystemNavigator.pop();
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  void _downloadBackupFile() async {
    final jsonData = serializeSharedPreferences();
    final jsonString = jsonEncode(jsonData);
    
    final tempDir = await getTemporaryDirectory();
    final tempFilePath = '${tempDir.path}/backupDetails.txt';
    final tempFile = File(tempFilePath);
    
    try {
      await tempFile.writeAsString(jsonString);
      
      //Save to download location using MediaStore
      final saveInfo = await mediaStore.saveFile(
        tempFilePath: tempFilePath,
        dirType: DirType.download,
        dirName: DirName.download,
        relativePath: FilePath.root,
      );
      
      if (saveInfo != null) {
        String message = 'Saved the file in Download';
        String buttonMessage = 'Ok';
        _showDialog(message, buttonMessage, _closeDialog);
      } else {
        String message = "Failed to download backup file";
        String buttonMessage = 'Ok';
        _showDialog(message, buttonMessage, _closeDialog);
      }
      await tempFile.delete();
      _closeDialog();
    } catch (e) {
      print('Error saving file: $e');
    }
  }

  void _choiceAction(String choice) {
    if (choice == _logOut) {
      _logoutButtonHandler();
    }
    else if (choice == _exit) {
      _showDialog("Confirm Exit?", "Yes", _exitButtonHandler);
    }
    else if (choice == _backup) {
      _showDialog("Download backup file?", "Yes", _downloadBackupFile);
    }
    else if (choice == _import) {
      _importButtonHandler();
    }
    else if (choice == _reset) {
      _showDialog("Delete everything and start over?", "Yes", _clearSharedPreferences);
    }
  }

  void _clearSharedPreferences() {
    PasswordSharedPreferences.clearSharedPreferences();
    Navigator.pushNamed(context, route.firstScreen);
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
        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
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
          _showDialog("Import failed, CSV format mismatch", "Ok", _closeDialog);
          return;
        }
        setState(() {
          importKeysFromCSV(fields);
        });
    } else {
      _showDialog("Import failed, Please try again", "Ok", _closeDialog);
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

  void _clearTextControllers() {
    serviceNameController.clear();
    usernameController.clear();
    passwordController.clear();
  }
/**********************************BACKEND CODE ENDS ******************************************************************/


/**********************************FRONTEND CODE STARTS ******************************************************************/  

  Widget _itemTitle(String service) {
    return Container(child: Text(service, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),));
  }

  Widget _itemThumbnail(String service) {
    return Container(
      constraints: BoxConstraints.tightFor(width: 90.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0), // Adjust the radius as needed
      ),
      clipBehavior: Clip.antiAlias, // This ensures the image respects the border radius
      child: Image(
        image: AssetImage('assets/lockImage.png'), 
        fit: BoxFit.fitWidth,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: mainScreenScaffold(), onWillPop: onWillPop);
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
                      const SizedBox(height: 25.0),
                      ElevatedButton(
                        onPressed: () => method(),
                        child: Text(buttonMessage, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(70, 25),
                          backgroundColor: Theme.of(context).elevatedButtonTheme.style?.backgroundColor?.resolve({})
                        ),
                      )
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
                        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                      const SizedBox(height: 25.0),
                      ElevatedButton(onPressed: () {
                        _deleteDetail(serviceName);
                        Navigator.of(context).pop();
                      }, child: Text('Yes', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)), style: ElevatedButton.styleFrom(
                          fixedSize: Size(70, 25),
                          backgroundColor: Theme.of(context).elevatedButtonTheme.style?.backgroundColor?.resolve({})
                        ))
                    ],
                  ),
                ))),
      );  

  Scaffold mainScreenScaffold() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: appBarTitle,
        backgroundColor: Theme.of(context).primaryColor,
        actions: <Widget>[
          if (_isListItemSelected) // Show buttons only when a list tile is long-pressed
          IconButton(
            icon: Icon(Icons.edit, color: Theme.of(context).iconTheme.color),
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
            icon: Icon(Icons.delete, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              if(_selectedListItemIndex != -1) {
                String serviceName = servicesList[_selectedListItemIndex];
                _openDeleteDialog(serviceName);
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
            icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).popupMenuTheme.color, // Change the color of the three-dot icon
              ),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        foregroundColor: Color.fromARGB(255, 204, 153, 255),
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () =>
            Navigator.pushNamed(context, route.addDetailScreen, arguments: widget.encryptionKey),
      ),
      body: _IsSearching
          ? _buildListView(searchList)
          : _buildListView(servicesList),
    );
  }

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
          color: Colors.white,
        );
      },
    );
  }
/**********************************FRONTEND CODE ENDS ******************************************************************/  
}