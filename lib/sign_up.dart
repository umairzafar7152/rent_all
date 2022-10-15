import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rent_all/log_in.dart';
import 'package:rent_all/terms_conditions.dart';

class SignUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign Up',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Burbank',
        primaryColor: Color(0xFF0C0467),
      ),
      home: SignUpPage(
        title: 'Sign Up',
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Map<String, dynamic> _dataToUpload;

  bool _obscureText = true;
  bool _isLoading = false;
  bool _checkedValue = false;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          : ListView(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        SizedBox(
                          height: 60,
                        ),
                        Image(
                          image: AssetImage('assets/icon.jpg'),
                          height: 100,
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          'Rent All',
                          style: TextStyle(
                              fontSize: 26,
                              color: Color(0xFF0C0467),
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white70,
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                  // width: 0.0 produces a thin "hairline" border
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                  borderSide: BorderSide(color: Colors.white24)
                                  //borderSide: const BorderSide(),
                                  ),
                              contentPadding: EdgeInsets.only(
                                  left: 15, bottom: 11, top: 11, right: 15),
                              hintText: 'Email',
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: TextField(
                            controller: _passwordController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: _obscureText,
                            enableSuggestions: true,
                            autocorrect: true,
                            decoration: InputDecoration(
                              suffixIcon: TextButton(
                                child: Text(
                                  _obscureText ? 'Show' : 'Hide',
                                  style: TextStyle(color: Color(0xFF0C0467)),
                                ),
                                onPressed: () {
                                  _toggle();
                                },
                              ),
                              prefixIcon: Icon(Icons.lock_outline_rounded),
                              filled: true,
                              fillColor: Colors.white70,
                              border: OutlineInputBorder(
                                  // width: 0.0 produces a thin "hairline" border
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                  borderSide: BorderSide(color: Colors.white24)
                                  //borderSide: const BorderSide(),
                                  ),
                              contentPadding: EdgeInsets.only(
                                  left: 15, bottom: 11, top: 11, right: 15),
                              hintText: 'Password',
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Checkbox(
                                value: _checkedValue,
                                onChanged: (newValue) {
                                  setState(() {
                                    _checkedValue = newValue;
                                  });
                                },
                              ),
                              TextButton(
                                child: Text(
                                  "Agree to Terms and Conditions",
                                  style: TextStyle(color: Colors.lightBlue),
                                ),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            TermsConditions()),
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 0.0, horizontal: 30.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                'Sign Up',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF0C0467),
                                    fontWeight: FontWeight.w900),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  isConnected().then((value) async {
                                    if (value == false) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('No internet connection!'),
                                        ),
                                      );
                                    } else {
                                      if (isValidEmail(_emailController.text) ==
                                          false) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return customAlertDialog('email');
                                          },
                                        );
                                      } else if (isValidPassword(
                                              _passwordController.text) ==
                                          false) {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return customAlertDialog(
                                                  'password');
                                            });
                                      } else {
                                        if (_checkedValue) {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          await FirebaseAuth.instance
                                              .createUserWithEmailAndPassword(
                                            email: _emailController.text.trim(),
                                            password:
                                                _passwordController.text.trim(),
                                          ).then((value) {
                                            _dataToUpload = {
                                              'email':
                                                  _emailController.text.trim(),
                                              'password': _passwordController
                                                  .text
                                                  .trim(),
                                              'image_url': '',
                                              'first': '',
                                              'last': '',
                                              'mobile': '',
                                              'paypal_email': ''
                                            };
                                            addDataToCloud(
                                                _dataToUpload, value.user.uid);
                                          }).catchError((_) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Unable to add user (incorrect Email/Password)'),
                                              ),
                                            );
                                            setState(() {
                                              _isLoading = false;
                                            });
                                          });
                                        } else {
                                          Fluttertoast.showToast(
                                              msg:
                                                  "Agree to terms and services to continue!",
                                              toastLength: Toast.LENGTH_LONG,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 14.0);
                                        }
                                      }
                                    }
                                  });
                                },
                                child: Icon(Icons.arrow_forward_sharp),
                                style: ButtonStyle(
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
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
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Already have an account?",
                            style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF0C0467),
                                fontWeight: FontWeight.w600),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LogIn()),
                              );
                            },
                            child: Text(
                              'Log In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0C0467),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  bool isValidPassword(String value) {
    Pattern pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regex = new RegExp(pattern);
    print(value);
    if (value.isEmpty) {
      return false;
    } else {
      if (!regex.hasMatch(value))
        return false;
      else
        return true;
    }
  }

  bool isValidEmail(String value) {
    return RegExp(
            r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
        .hasMatch(_emailController.text);
  }

  Widget customTextField(String hintName, bool autoFocus) {
    TextInputType inputType;
    TextEditingController controller;
    if (hintName == 'Email') {
      controller = _emailController;
      inputType = TextInputType.emailAddress;
    } else if (hintName == 'Password') {
      controller = _passwordController;
      inputType = TextInputType.visiblePassword;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        // onChanged: (text) {
        //   setState(() {
        //     if (hintName == 'Email') {
        //       _emailText = text;
        //     } else if (hintName == 'Password') {
        //       _passwordText = text;
        //     }
        //   });
        // },
        obscureText: hintName == 'Password' ? _obscureText : false,
        enableSuggestions: hintName == 'Password' ? true : false,
        autocorrect: hintName == 'Password' ? true : false,
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

  void addDataToCloud(Map<String, dynamic> dataToUpload, String uid) {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('users');
    collectionReference
        .doc(uid)
        .set(dataToUpload)
        .catchError((error, stackTrace) {
      print("FAILED TO ADD DATA: $error");
      print("STACKTRACE IS:  $stackTrace");
    });
    print("USER ADDED!!!!!!!!!!!!");
  }

  Widget customAlertDialog(String alertText) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      title: Row(
        children: <Widget>[
          Icon(
            Icons.warning_amber_outlined,
            color: Colors.red,
          ),
          Text(
            "Warning",
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
      content: Text(
        alertText,
        style: TextStyle(
          color: Color(0xFF0C0467),
        ),
      ),
      actions: [
        TextButton(
          child: Text(
            'Retry',
            style: TextStyle(
                color: Colors.white, backgroundColor: Color(0xFF0C0467)),
          ),
          onPressed: () {
            setState(() {
              _isLoading = false;
            });
            Navigator.of(context, rootNavigator: true).pop('dialog');
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
    _emailController.dispose();
    _passwordController.dispose();
    _obscureText = null;
    _isLoading = null;
    super.dispose();
  }
}

// void fetchDataFromCloud() {
//   Map<String, dynamic> data;
//   CollectionReference collectionReference =
//   FirebaseFirestore.instance.collection('users');
//   collectionReference.snapshots().listen((event) {
//     setState(() {
//       data = event.docs[0].data();
//     });
//   });
// }

// void deleteData(data) async {
//   CollectionReference collectionReference =
//   FirebaseFirestore.instance.collection('users');
//   QuerySnapshot querySnapshot = await collectionReference.get();
//   querySnapshot.docs[0].reference.delete();
//   print('USER DATA DELETED!!!!!!!!!!!!!!!!!!');
// }
//
// void updateData(data) async {
//   CollectionReference collectionReference =
//   FirebaseFirestore.instance.collection('users');
//   QuerySnapshot querySnapshot = await collectionReference.get();
//   querySnapshot.docs[0].reference.update(data);
// }
