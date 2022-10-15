import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rent_all/log_in.dart';
import 'package:rent_all/main_page.dart';

class UserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Profile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Burbank',
        primaryColor: Color(0xFF0C0467),
      ),
      home: UserProfilePage(
        title: 'User Profile',
      ),
    );
  }
}

class UserProfilePage extends StatefulWidget {
  UserProfilePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String _emailText;
  String _firstNameText;
  String _lastNameText;
  String _mobileNumberText;
  String _paypalText;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _firstController = TextEditingController();
  TextEditingController _lastController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _paypalController = TextEditingController();

  Map<String, dynamic> _dataToUpload;
  final ImagePicker _picker = ImagePicker();
  PickedFile _pickedFile;
  String _imageUrl;
  bool _obscureText = true;
  bool _isLoading = false;
  String _userId;

  // String _avatarUrl =
  //     'https://firebasestorage.googleapis.com/v0/b/rent-all-deb4b.appspot.com/o/avatar_1.jpg?alt=media&token=0e21d82b-9c1a-4ae9-ad6e-33bde461b245';

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void initState() {
    _getCurrentUser();
    _isLoading = true;
    getDataOfUser(_userId).then((value) {
      _imageUrl = value.data()['image_url'];
      _emailText = value.data()['email'];
      _firstNameText = value.data()['first'];
      _lastNameText = value.data()['last'];
      _mobileNumberText = value.data()['mobile'];
      _paypalText = value.data()['paypal_email'];

      _emailController.text = _emailText;
      _firstController.text = _firstNameText;
      _lastController.text = _lastNameText;
      _mobileController.text = _mobileNumberText;
      _paypalController.text = _paypalText;
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
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
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          'Edit Profile',
                          style:
                              TextStyle(fontSize: 24, color: Color(0xFF0C0467)),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      imageProfile(_pickedFile),
                      SizedBox(
                        height: 10,
                      ),
                      customTextField('First Name'),
                      SizedBox(
                        height: 10,
                      ),
                      customTextField('Last Name'),
                      SizedBox(
                        height: 10,
                      ),
                      customTextField('Email'),
                      SizedBox(
                        height: 10,
                      ),
                      customTextField('Mobile Number'),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: RichText(
                          text: TextSpan(
                            text: 'Note: ',
                            style: TextStyle(
                                fontFamily: 'Burbank',
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                            children: <TextSpan>[
                              TextSpan(
                                text:
                                    "Enter email carefully as it will be used to send you rent payments!",
                                style: TextStyle(
                                    fontFamily: 'Burbank',
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      customTextField('Paypal Email'),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 30.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          'Update',
                          style:
                              TextStyle(fontSize: 18, color: Color(0xFF0C0467)),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            isConnected().then((value) async {
                              if (value == false) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('No internet connection!'),
                                  ),
                                );
                              } else {
                                // if (_emailText == null ||
                                //     _firstNameText == null ||
                                //     _lastNameText == null ||
                                //     _mobileNumberText == null) {
                                //   ScaffoldMessenger.of(context).showSnackBar(
                                //     SnackBar(
                                //       content: Text('Fill all fields...'),
                                //     ),
                                //   );
                                // } else {
                                setState(() {
                                  _isLoading = true;
                                });
                                if (_pickedFile != null) {
                                  await uploadPhoto(File(_pickedFile.path));
                                }
                                _dataToUpload = {
                                  'image_url': _imageUrl,
                                  'email': _emailText,
                                  'first': _firstNameText,
                                  'last': _lastNameText,
                                  'mobile': _mobileNumberText,
                                  'paypal_email': _paypalText
                                };
                                updateUserData(_dataToUpload, _userId)
                                    .then((value) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MainPage()),
                                  );
                                  setState(() {
                                    _isLoading = false;
                                  });
                                });
                                // }
                              }
                            });
                          },
                          child: Icon(Icons.arrow_forward_sharp),
                          style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color(0xFF0C0467)),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(20.0),
                                ),
                              ))),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget customTextField(String hintName) {
    TextInputType inputType;
    TextEditingController controller;
    if (hintName == 'Email') {
      inputType = TextInputType.emailAddress;
      controller = _emailController;
    } else if (hintName == 'First Name') {
      controller = _firstController;
      inputType = TextInputType.name;
    } else if (hintName == 'Last Name') {
      controller = _lastController;
      inputType = TextInputType.name;
    } else if (hintName == 'Mobile Number') {
      controller = _mobileController;
      inputType = TextInputType.number;
    } else if (hintName == 'Paypal Email') {
      controller = _paypalController;
      inputType = TextInputType.emailAddress;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        onChanged: (text) {
          setState(() {
            if (hintName == 'Email') {
              _emailText = text;
            } else if (hintName == 'First Name') {
              _firstNameText = text;
            } else if (hintName == 'Last Name') {
              _lastNameText = text;
            } else if (hintName == 'Mobile Number') {
              _mobileNumberText = text;
            } else if (hintName == 'Paypal Email') {
              _paypalText = text;
            }
          });
        },
        enabled: hintName == 'Email' ? false : true,
        controller: controller,
        keyboardType: inputType != null ? inputType : TextInputType.text,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white70,
          labelText: hintName,
          suffixIcon: hintName == 'Password'
              ? TextButton(
                  child: Text(
                    _obscureText ? 'Show' : 'Hide',
                    style: TextStyle(color: Color(0xFF0C0467)),
                  ),
                  onPressed: () {
                    _toggle();
                  },
                )
              : null,
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

  Widget imageProfile(PickedFile imageFile) {
    return TextButton(
      onPressed: () {
        showModalBottomSheet(
            context: context, builder: ((builder) => bottomSheet()));
      },
      child: CircleAvatar(
        radius: 80,
        backgroundImage: imageFile?.path != null
            ? FileImage(File(imageFile.path))
            : _imageUrl != null && _imageUrl == ''
                ? AssetImage('assets/avatar_1.jpg')
                : NetworkImage(_imageUrl),
      ),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 80.0,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Column(
        children: <Widget>[
          Text(
            'Choose your profile picture',
            style: TextStyle(fontSize: 14, color: Color(0xFF0C0467)),
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
                    takePhoto(ImageSource.camera);
                  }),
              IconButton(
                  icon: Icon(
                    Icons.image_outlined,
                    size: 30,
                    color: Color(0xFF0C0467),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    takePhoto(ImageSource.gallery);
                  }),
            ],
          ),
        ],
      ),
    );
  }

  void takePhoto(ImageSource source) async {
    final pickedFile = await _picker.getImage(source: source);
    setState(() {
      _pickedFile = pickedFile;
    });
  }

  Future<dynamic> uploadPhoto(File imageToUpload) async {
    Reference reference = FirebaseStorage.instance
        .ref()
        .child("profile_images")
        .child(imageToUpload.path.split('/').last);

    if (_imageUrl != '' && _imageUrl != null) {
      FirebaseStorage.instance.refFromURL(_imageUrl).delete();
    }
    UploadTask uploadTask = reference.putFile(imageToUpload);
    try {
      _imageUrl = await (await uploadTask).ref.getDownloadURL();
      // imageUrl = await reference.getDownloadURL();
    } catch (onError) {
      print("ERROR GETTING URL: ${onError.toString()}");
    }
    print(_imageUrl.toString());
  }

  Future<dynamic> updateUserData(dataToUpload, userId) async {
    // CollectionReference collectionReference =
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update(dataToUpload);
    // QuerySnapshot querySnapshot = await collectionReference.get();
    // querySnapshot.docs[0].reference.update(data);
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

  void _getCurrentUser() {
    User mCurrentUser = FirebaseAuth.instance.currentUser;
    if (mCurrentUser != null) {
      _userId = mCurrentUser.uid;
      // _userEmail = mCurrentUser.email;
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LogIn()));
    }
  }

  Future<DocumentSnapshot> getDataOfUser(String userIdRequired) async {
    var localSnapshot;
    var docRef =
        FirebaseFirestore.instance.collection("users").doc(userIdRequired);
    localSnapshot = await docRef.get();
    // setState(() {
    //   _snapshot = localSnapshot;
    // });
    return localSnapshot;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstController.dispose();
    _lastController.dispose();
    _mobileController.dispose();
    _paypalController.dispose();
    super.dispose();
  }
}
