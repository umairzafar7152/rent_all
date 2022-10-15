import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rent_all/sign_up.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rent All',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Burbank',
        primaryColor: Color(0xFF0C0467),
      ),
      home: LogInPage(title: 'Log In'),
    );
  }
}

class LogInPage extends StatefulWidget {
  LogInPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void initState() {
    if (Firebase.apps.length == 0) {
      Firebase.initializeApp();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0C0467))),
            )
          : ListView(children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                          controller: emailController,
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
                          controller: passwordController,
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
                        height: 10.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 30.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            TextButton(
                              onPressed: () {
                                isConnected().then((value) {
                                  if (value == false) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('No internet connection!'),
                                      ),
                                    );
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return forgotPasswordAlert();
                                      },
                                    );
                                  }
                                });
                              },
                              child: Text(
                                'forgot password?',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF0C0467),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              'Log In',
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('No internet connection!'),
                                      ),
                                    );
                                  } else {
                                    if (isValidEmail(emailController.text) ==
                                        false) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return customAlertDialog('email');
                                        },
                                      );
                                    } else if (isValidPassword(
                                            passwordController.text) ==
                                        false) {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return customAlertDialog(
                                                'password');
                                          });
                                    } else {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setBool('SignUp', false);
                                      await FirebaseAuth.instance
                                          .signInWithEmailAndPassword(
                                        email: emailController.text.trim(),
                                        password:
                                            passwordController.text.trim(),
                                      )
                                          .then((value) {
                                        // Navigator.pushReplacement(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //       builder: (BuildContext context) =>
                                        //           MainPage()),
                                        // );
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }).catchError((_) {
                                        ScaffoldMessenger.of(
                                                _scaffoldKey.currentContext)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'User not found (incorrect Email/Password)'),
                                          ),
                                        );
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      });
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
                          "Don't have account?",
                          style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF0C0467),
                              fontWeight: FontWeight.w500),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => SignUp()),
                            );
                          },
                          child: Text(
                            'Register',
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
            ]),
    );
  }

  Widget customAlertDialog(String typeOfError) {
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
      content: typeOfError == 'email'
          ? Text(
              "Enter valid Email Address!",
              style: TextStyle(
                color: Color(0xFF0C0467),
              ),
            )
          : Container(
              height: 130,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Your password should contain at least:',
                    style: TextStyle(
                      color: Color(0xFF0C0467),
                    ),
                  ),
                  Text(
                    '\u2022 one upper case',
                    style: TextStyle(
                      color: Color(0xFF0C0467),
                    ),
                  ),
                  Text(
                    '\u2022 one lower case',
                    style: TextStyle(
                      color: Color(0xFF0C0467),
                    ),
                  ),
                  Text(
                    '\u2022 one digit',
                    style: TextStyle(
                      color: Color(0xFF0C0467),
                    ),
                  ),
                  Text(
                    '\u2022 one special character',
                    style: TextStyle(
                      color: Color(0xFF0C0467),
                    ),
                  ),
                ],
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
        .hasMatch(emailController.text);
  }

  Widget forgotPasswordAlert() {
    String emailAddress;
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
            "Password Reset",
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
      insetPadding: EdgeInsets.all(10),
      content: Container(
        width: 300,
        child: TextField(
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            setState(() {
              emailAddress = value;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white70,
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(
                // width: 0.0 produces a thin "hairline" border
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                borderSide: BorderSide(color: Colors.white24)
                //borderSide: const BorderSide(),
                ),
            contentPadding:
                EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
            hintText: 'Enter Your Email',
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text(
            'Reset Password',
            style: TextStyle(
                color: Colors.white, backgroundColor: Color(0xFF0C0467)),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            if (emailAddress != null) {
              if (resetPassword(emailAddress)) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Mail is sent! Reset your password...'),
                ));
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Email is not registered yet.'),
              ));
            }
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

  bool resetPassword(String emailAddress) {
    bool done = false;
    FirebaseAuth auth = FirebaseAuth.instance;

    auth
        .sendPasswordResetEmail(email: emailAddress)
        .whenComplete(() => {done = true});
    return done;
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
    emailController.clear();
    passwordController.clear();
    _isLoading = null;
    super.dispose();
  }
}
