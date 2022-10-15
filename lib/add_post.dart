import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:rent_all/main_page.dart';

class AddPost extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Add Post',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Burbank',
        primaryColor: Color(0xFF0C0467),
      ),
      home: AddPostPage(title: 'Add Post'),
    );
  }
}

class AddPostPage extends StatefulWidget {
  AddPostPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  DocumentSnapshot _userSnapshot;
  String imageUrl1;
  String imageUrl2;
  String imageUrl3;
  String imageUrl4;
  String imageUrl5;
  String itemCategory;
  var _lat;
  var _long;
  final LatLng _center = const LatLng(45.521563, -122.677433);
  bool _isOnline;
  bool _isLoading = false;

  PickedFile _imageFile1;
  PickedFile _imageFile2;
  PickedFile _imageFile3;
  PickedFile _imageFile4;
  PickedFile _imageFile5;
  String _userEmail;
  String _uId;
  String _descriptionText;
  String _amountText;
  String _requirementsText;
  String _itemName;

  Map<String, dynamic> _dataToUpload;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _userEmail = getUserEmail();
    isConnected().then((value) {
      _isOnline = value;
      if (_isOnline) {
        getDataOfUser(_uId).then((value) {
          if(value['paypal_email']!=null && value['paypal_email']!='') {
            getLocationPermissions().then((value) {
              if (value)
                myCurrentLocation().then((value) {
                  setState(() {
                    _isLoading = false;
                  });
                });
            });
          } else {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return customDialog('Error');
              },
            );
            setState(() {
              _isLoading = false;
            });
          }
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0C0467), // status bar color
        brightness: Brightness.dark,
        title: Text(
          widget.title,
        ),
      ),
      body: _isLoading
          ? Center(
        child: LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0C0467)),
        ),
      )
          : (!_isLoading && !_isOnline)
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons
                  .signal_cellular_connected_no_internet_4_bar_rounded,
              size: 50,
              color: Color(0xFF0C0467),
            ),
            Text(
              'No internet connection',
              style: TextStyle(fontSize: 18, color: Color(0xFF0C0467)),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Add Post',
                    style: TextStyle(fontSize: 24, color: Color(0xFF0C0467), fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 80,
                    child: GridView.count(
                      crossAxisCount: 5,
                      children: <Widget>[
                        itemImage(1, _imageFile1),
                        itemImage(2, _imageFile2),
                        itemImage(3, _imageFile3),
                        itemImage(4, _imageFile4),
                        itemImage(5, _imageFile5),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Note: ', style: TextStyle(color: Colors.red,)),
                      Text('Add at least first image for the item!',)
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  customTextFields('Item Name', 'name'),
                  SizedBox(
                    height: 15,
                  ),
                  customTextFields('Description', 'multiline'),
                  SizedBox(
                    height: 15,
                  ),
                  customTextFields('Rent Amount per day (CAD)', 'number'),
                  SizedBox(height: 15,),
                  customTextFields('Requirements', 'multiline'),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: 300.0,
                    child: DropdownButton<String>(
                      value: itemCategory,
                      hint: Text('Category', style: TextStyle(fontFamily: 'Burbank'),),
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(color: Color(0xFF0C0467)),
                      // underline: Container(
                      //   height: 2,
                      //   color: Colors.deepPurpleAccent,
                      // ),
                      onChanged: (newValue) {
                        setState(() {
                          itemCategory = newValue;
                        });
                      },
                      items: <String>[
                        'Equipments',
                        'Tools',
                        'Electronics',
                        'Furniture',
                        'Sport Goods',
                        'Appliances',
                        'Outdoors',
                        'Real Estate',
                        'Machinery',
                        'Others'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 0.0, horizontal: 30.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          'Add',
                          style: TextStyle(fontSize: 18, color: Color(0xFF0C0467)),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            isConnected().then((value) async {
                              if(value==false) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text('No internet connection!'),
                                ),);
                              } else {
                                setState(() {
                                  _isLoading = true;
                                });
                                if (_imageFile1 != null) {
                                  imageUrl1 =
                                      await uploadPhoto(File(_imageFile1.path));
                                }
                                if (_imageFile2 != null) {
                                  imageUrl2 =
                                      await uploadPhoto(File(_imageFile2.path));
                                }
                                if (_imageFile3 != null) {
                                  imageUrl3 =
                                      await uploadPhoto(File(_imageFile3.path));
                                }
                                if (_imageFile4 != null) {
                                  imageUrl4 =
                                      await uploadPhoto(File(_imageFile4.path));
                                }
                                if (_imageFile5 != null) {
                                  imageUrl5 =
                                      await uploadPhoto(File(_imageFile5.path));
                                }
                                if (imageUrl1 == null) {
                                  imageUrl1 = '';
                                }
                                if (imageUrl2 == null) {
                                  imageUrl2 = '';
                                }
                                if (imageUrl3 == null) {
                                  imageUrl3 = '';
                                }
                                if (imageUrl4 == null) {
                                  imageUrl4 = '';
                                }
                                if (imageUrl5 == null) {
                                  imageUrl5 = '';
                                }
                                if (_itemName == null || _amountText == null ||
                                    itemCategory == null ||
                                    _descriptionText == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Fill all fields...'),
                                    ),
                                  );
                                  setState(() {
                                    _isLoading=false;
                                  });
                                } else if(imageUrl1=='' && imageUrl2=='' && imageUrl3=='' &&
                                    imageUrl4=='' && imageUrl5=='') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Add at least one image of the rent item!'),
                                    ),
                                  );
                                  setState(() {
                                    _isLoading=false;
                                  });
                                } else {
                                  addDataToCloud();
                                }
                              }
                            });
                          },
                          child: Icon(Icons.arrow_forward_sharp),
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color(0xFF0C0467)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(20.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget customTextFields(String hintName, String typeOfText) {
    TextInputType typeText;
    switch (typeOfText) {
      case 'text':
        {
          typeText = TextInputType.text;
        }
        break;
      case 'number':
        {
          typeText = TextInputType.number;
        }
        break;
      case 'multiline':
        {
          typeText = TextInputType.multiline;
        }
        break;
      case 'name':
        {
          typeText = TextInputType.name;
        }
        break;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        onChanged: (value) {
          setState(() {
            if (hintName == 'Description') {
              _descriptionText = value;
            } else if (hintName == 'Rent Amount per day (CAD)') {
              _amountText = value;
            } else if(hintName == 'Requirements') {
              _requirementsText = value;
            } else if(hintName == 'Item Name') {
              _itemName = value;
            }
          });
        },
        keyboardType: typeText,
        maxLines: typeText==TextInputType.multiline ? 8 : 1,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white70,
          labelText: hintName,
          border: OutlineInputBorder(
              // width: 0.0 produces a thin "hairline" border
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              borderSide: BorderSide(color: Colors.white24)
              //borderSide: const BorderSide(),
              ),
          contentPadding:
              EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
          hintText: hintName,
        ),
      ),
    );
  }

  Widget itemImage(int imageNumber, PickedFile imageFile) {
    return TextButton(
      onPressed: () {
        showModalBottomSheet(
            context: context, builder: ((builder) => bottomSheet(imageNumber)));
      },
      child: CircleAvatar(
        radius: 80,
        backgroundImage: imageFile == null
            ? AssetImage("assets/image_icon.jpg")
            : FileImage(File(imageFile.path)),
      ),
    );
  }

  Widget bottomSheet(int imageNumber) {
    return Container(
      height: 80.0,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Column(
        children: <Widget>[
          Text(
            'Choose image of your item',
            style:
            TextStyle(fontSize: 14, color: Color(0xFF0C0467)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.camera_alt_outlined,
                    size: 30,
                    color: Color(0xFF0C0467),
                  ),
                  onPressed: () {
                    takePhoto(ImageSource.camera, imageNumber);
                  }),
              IconButton(
                  icon: Icon(
                    Icons.image_outlined,
                    size: 30,
                    color: Color(0xFF0C0467),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    takePhoto(ImageSource.gallery, imageNumber);
                  }),
            ],
          ),
        ],
      ),
    );
  }

  void takePhoto(ImageSource source, int imageNumber) async {
    final pickedFile = await _picker.getImage(source: source);
    setState(() {
      if (imageNumber == 1) {
        _imageFile1 = pickedFile;
      } else if (imageNumber == 2) {
        _imageFile2 = pickedFile;
      } else if (imageNumber == 3) {
        _imageFile3 = pickedFile;
      } else if (imageNumber == 4) {
        _imageFile4 = pickedFile;
      } else if (imageNumber == 5) {
        _imageFile5 = pickedFile;
      }
    });
  }

  Future<String> uploadPhoto(File imageToUpload) async {
    String imageUrl;
    Reference reference = FirebaseStorage.instance
        .ref()
        .child("post_images")
        .child(imageToUpload.path.split('/').last);

    UploadTask uploadTask = reference.putFile(imageToUpload);
    try {
      imageUrl = await (await uploadTask).ref.getDownloadURL();
      // imageUrl = await reference.getDownloadURL();
    } catch (onError) {
      print("ERROR GETTING URL: ${onError.toString()}");
    }
    print(imageUrl.toString());
    return imageUrl;
  }

  String getUserEmail() {
    final User user = _auth.currentUser;
    _uId = user.uid;
    return user.email;
    // here you write the codes to input the data into firestore
  }

  LocationData _currentLocation;
  var location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  Future<bool> getLocationPermissions() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        Navigator.of(context, rootNavigator: true).pop(context);
        return false;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        Navigator.of(context, rootNavigator: true).pop(context);
        return false;
      }
    }
    return true;
  }

  Future<LocationData> myCurrentLocation() async {
    try {
      _currentLocation = await location.getLocation();
      print("locationLatitude: ${_currentLocation.latitude.toString()}");
      print("locationLongitude: ${_currentLocation.longitude.toString()}");
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        String error = 'Permission denied';
        print(error);
      }
      _currentLocation = null;
    }
    setState(() {
      if (_currentLocation != null) {
        _lat = _currentLocation.latitude;
        _long = _currentLocation.longitude;
      }
    });
    return _currentLocation;
  }

  Future<DocumentSnapshot> getDataOfUser(String userIdRequired) async {
    var docRef =
    FirebaseFirestore.instance.collection("users").doc(userIdRequired);
    await docRef.get().then((value) {
      setState(() {
        _userSnapshot = value;
      });
    });
    return _userSnapshot;
  }

  void addDataToCloud() {
    var category;
    if (itemCategory == 'Equipments') {
      category = 'equipment';
    } else if (itemCategory == 'Tools') {
      category = 'tools';
    } else if (itemCategory == 'Electronics') {
      category = 'electronics';
    } else if (itemCategory == 'Furniture') {
      category = 'furniture';
    } else if (itemCategory == 'Sport Goods') {
      category = 'sport_goods';
    } else if (itemCategory == 'Appliances') {
      category = 'appliances';
    } else if (itemCategory == 'Outdoors') {
      category = 'Outdoors';
    } else if (itemCategory == 'Real Estate') {
      category = 'real_estate';
    } else if (itemCategory == 'Machinery') {
      category = 'machinery';
    } else if (itemCategory == 'Others') {
      category = 'other_items';
    }
    _dataToUpload = {
      "item_name": _itemName,
      "amount": _amountText,
      "email": _userEmail,
      "lessor_uid": _uId,
      "description": _descriptionText,
      "requirements": _requirementsText,
      "image1": imageUrl1,
      "image2": imageUrl2,
      "image3": imageUrl3,
      "image4": imageUrl4,
      "image5": imageUrl5,
      "lat": _lat != null ? _lat : _center.latitude,
      "long": _long != null ? _long : _center.longitude,
    };
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection(category);
    collectionReference.add(_dataToUpload).catchError((error, stackTrace) {
      print("FAILED TO ADD DATA: $error");
      print("STACKTRACE IS:  $stackTrace");
    });
    print('Data Uploaded');
    setState(() {
      _isLoading = false;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return customDialog("Post Added Successfully");
      },
    );
  }

  Widget customDialog(String dialogText) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      title: Row(
        children: <Widget>[
          Icon(
            Icons.reset_tv,
            color: Colors.red,
          ),
          Text(
            dialogText,
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
      insetPadding: EdgeInsets.all(10),
      content: dialogText=="Post Added Successfully"?Text(''):
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("Provide paypal account in profile to continue!"),
          SizedBox(height: 10.0,),
          RichText(
            text: TextSpan(
              text: 'Note: ',
              style: TextStyle(
                  fontFamily: 'Burbank',
                  fontWeight: FontWeight.bold,
                  color: Colors.red),
              children: <TextSpan>[
                TextSpan(
                  text:
                  "This will be used to send you rent amounts!",
                  style: TextStyle(
                      fontFamily: 'Burbank',
                      fontWeight: FontWeight.w300,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text(
            'Go Back',
            style: TextStyle(
                color: Colors.white, backgroundColor: Color(0xFF0C0467)),
          ),
          onPressed: ()async {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            await Navigator.of(context)
                .push(new MaterialPageRoute(builder: (context) => MainPage()));
          },
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            backgroundColor:
                MaterialStateProperty.all<Color>(Color(0xFF0C0467)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(20.0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> isConnected() async {
    var connected;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      connected = true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      connected = true;
    } else {
      connected = false;
    }
    return connected;
  }

  @override
  void dispose() {
    _isLoading = null;
    _currentLocation = null;
    super.dispose();
  }
}
