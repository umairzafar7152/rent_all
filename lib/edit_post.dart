import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rent_all/my_posts.dart';

class EditPost extends StatelessWidget {
  EditPost({Key key, @required this.itemId, @required this.category})
      : super(key: key);
  final String itemId;
  final String category;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edit Post',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Burbank',
        primaryColor: Color(0xFF0C0467),
      ),
      home: EditPostPage(title: 'Edit Post', itemId: this.itemId, category: this.category),
    );
  }
}

class EditPostPage extends StatefulWidget {
  EditPostPage({Key key, this.title, @required this.itemId, @required this.category}) : super(key: key);
  final String itemId;
  final String category;
  final String title;

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  String _imageUrl1;
  String _imageUrl2;
  String _imageUrl3;
  String _imageUrl4;
  String _imageUrl5;
  String _itemCategory;
  var _lat;
  var _long;
  final LatLng _center = const LatLng(45.521563, -122.677433);

  bool _isLoading;
  TextEditingController _itemNameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _rentAmountController = TextEditingController();
  TextEditingController _requirementsController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();

  PickedFile _imageFile1;
  PickedFile _imageFile2;
  PickedFile _imageFile3;
  PickedFile _imageFile4;
  PickedFile _imageFile5;
  String _userEmail;
  String _descriptionText;
  String _amountText;
  String _requirementsText;
  String _itemName;

  Map<String, dynamic> _dataToUpload;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    _isLoading = true;
    getItemData().then((value) {
      _imageUrl1 = value.data()['image1'];
      _imageUrl2 = value.data()['image2'];
      _imageUrl3 = value.data()['image3'];
      _imageUrl4 = value.data()['image4'];
      _imageUrl5 = value.data()['image5'];
      _userEmail = value.data()['email'];
      _descriptionText = value.data()['description'];
      _amountText = value.data()['amount'];
      _requirementsText = value.data()['requirements'];
      _itemName = value.data()['item_name'];
      _itemCategory = widget.category;

      _itemNameController.text = _itemName;
      _descriptionController.text = _descriptionText;
      _rentAmountController.text = _amountText;
      _requirementsController.text = _requirementsText;
      _categoryController.text = _itemCategory;
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  var url;

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
          : SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              'Add Post',
              style: TextStyle(fontSize: 24, color: Color(0xFF0C0467)),
            ),
            SizedBox(
              height: 90,
              child: GridView.count(
                crossAxisCount: 5,
                children: <Widget>[
                  itemImage(1, _imageFile1, _imageUrl1),
                  itemImage(2, _imageFile2, _imageUrl2),
                  itemImage(3, _imageFile3, _imageUrl3),
                  itemImage(4, _imageFile4, _imageUrl4),
                  itemImage(5, _imageFile5, _imageUrl5),
                ],
              ),
            ),
            customTextFields('Item Name'),
            SizedBox(
              height: 15,
            ),
            customTextFields('Description'),
            SizedBox(
              height: 15,
            ),
            customTextFields('Rent Amount per day (CAD)'),
            SizedBox(height: 15,),
            customTextFields('Requirements'),
            SizedBox(
              height: 15,
            ),
            customTextFields('Category'),
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
                    'Update',
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
                            _imageUrl1 =
                            await uploadPhoto(File(_imageFile1.path), _imageUrl1);
                          }
                          if (_imageFile2 != null) {
                            _imageUrl2 =
                            await uploadPhoto(File(_imageFile2.path), _imageUrl2);
                          }
                          if (_imageFile3 != null) {
                            _imageUrl3 =
                            await uploadPhoto(File(_imageFile3.path), _imageUrl3);
                          }
                          if (_imageFile4 != null) {
                            _imageUrl4 =
                            await uploadPhoto(File(_imageFile4.path), _imageUrl4);
                          }
                          if (_imageFile5 != null) {
                            _imageUrl5 =
                            await uploadPhoto(File(_imageFile5.path), _imageUrl5);
                          }
                          if (_imageUrl1 == null) {
                            _imageUrl1 = '';
                          }
                          if (_imageUrl2 == null) {
                            _imageUrl2 = '';
                          }
                          if (_imageUrl3 == null) {
                            _imageUrl3 = '';
                          }
                          if (_imageUrl4 == null) {
                            _imageUrl4 = '';
                          }
                          if (_imageUrl5 == null) {
                            _imageUrl5 = '';
                          }
                          if (_itemName == null || _amountText == null ||
                              _itemCategory == null ||
                              _descriptionText == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Fill all fields...'),
                              ),
                            );
                            setState(() {
                              _isLoading=false;
                            });
                          } else if(_imageUrl1=='') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Add at least first image of the rent item!'),
                              ),
                            );
                            setState(() {
                              _isLoading=false;
                            });
                          } else {
                            updateItemData();
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

  Widget customTextFields(String hintName) {
    TextInputType typeText;
    TextEditingController controller;
    switch (hintName) {
      case 'Item Name':
        {
          typeText = TextInputType.name;
          controller = _itemNameController;
        }
        break;
      case 'Description':
        {
          typeText = TextInputType.multiline;
          controller = _descriptionController;
        }
        break;
      case 'Rent Amount per day (CAD)':
        {
          typeText = TextInputType.number;
          controller = _rentAmountController;
        }
        break;
      case 'Requirements':
        {
          typeText = TextInputType.multiline;
          controller = _requirementsController;
        }
        break;
      case 'Category':
        {
          typeText = TextInputType.name;
          controller = _categoryController;
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
            } else if(hintName == 'Category') {
              _itemCategory = value;
            }
          });
        },
        enabled: hintName == 'Category' ? false : true,
        controller: controller,
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

  Widget itemImage(int imageNumber, PickedFile imageFile, String imageUrl) {
    return TextButton(
      onPressed: () {
        showModalBottomSheet(
            context: context, builder: ((builder) => bottomSheet(imageNumber)));
      },
      child: CircleAvatar(
        radius: 80,
        backgroundImage: imageFile == null
            ? imageUrl!=null&&imageUrl!=''?NetworkImage(imageUrl):AssetImage('assets/image_icon.jpg')
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

  Future<String> uploadPhoto(File imageToUpload, String _imageUrl) async {
    String imageUrl;
    Reference reference = FirebaseStorage.instance
        .ref()
        .child("post_images")
        .child(imageToUpload.path.split('/').last);
    if (_imageUrl != '' && _imageUrl != null) {
      FirebaseStorage.instance.refFromURL(_imageUrl).delete();
    }
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
    return user.email;
    // here you write the codes to input the data into firestore
  }

  Future<DocumentSnapshot> getItemData() async {
    DocumentSnapshot localSnapshot;
    var docRef =
    FirebaseFirestore.instance.collection(widget.category).doc(widget.itemId);
    localSnapshot = await docRef.get();
    return localSnapshot;
  }

  void updateItemData() {
    _dataToUpload = {
      "item_name": _itemName,
      "amount": _amountText,
      "email": _userEmail,
      "description": _descriptionText,
      "requirements": _requirementsText,
      "image1": _imageUrl1,
      "image2": _imageUrl2,
      "image3": _imageUrl3,
      "image4": _imageUrl4,
      "image5": _imageUrl5,
      "lat": _lat != null ? _lat : _center.latitude,
      "long": _long != null ? _long : _center.longitude,
    };
    FirebaseFirestore.instance.collection(widget.category).doc(widget.itemId).update(_dataToUpload);
    // });
    print('Data Uploaded');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return itemUpdatedDialog();
      },
    );
  }

  Widget itemUpdatedDialog() {
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
            "Post updated Successfully",
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
      insetPadding: EdgeInsets.all(10),
      content: Text(''),
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
                .pushReplacement(new MaterialPageRoute(builder: (context) => MyPosts()));
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
    _itemNameController.dispose();
    _descriptionController.dispose();
    _rentAmountController.dispose();
    _requirementsController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
