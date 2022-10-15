import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rent_all/acquired_items.dart';
import 'package:rent_all/add_post.dart';
import 'package:rent_all/approvals.dart';
import 'package:rent_all/log_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rent_all/my_posts.dart';
import 'package:rent_all/my_rent_items.dart';
import 'package:rent_all/posts.dart';
import 'package:rent_all/user_profile.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatelessWidget {
  MainPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Burbank',
        primaryColor: Color(0xFF0C0467),
      ),
      home: HomePage(
        title: 'Home',
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({
    Key key,
    this.title,
  }) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _avatarUrl =
      'https://firebasestorage.googleapis.com/v0/b/rent-all-deb4b.appspot.com/o/avatar_1.jpg?alt=media&token=0e21d82b-9c1a-4ae9-ad6e-33bde461b245';

  DocumentSnapshot _snapshot;
  bool _isLoading;
  String _distance = "5";
  String _userEmail;
  String _userId;

  @override
  void initState() {
    if (Firebase.apps.length == 0) {
      Firebase.initializeApp();
    }
    _isLoading = true;
    _getCurrentUser();
    getDataOfUser(_userId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _snapshot == null ? _isLoading = true : _isLoading = false;
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0C0467), // status bar color
        brightness: Brightness.dark,
        title: Text(
          widget.title,
        ),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () async {
                  await _auth.signOut().then((_) {
                    Navigator.pushReplacement(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => new LogIn()));
                  });
                },
                child: Icon(
                  Icons.logout,
                  size: 26.0,
                ),
              )),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Color(0xFF0C0467),
                backgroundImage: NetworkImage(_snapshot != null
                    ? _snapshot.data()['image_url'] == ''
                        ? _avatarUrl
                        : "${_snapshot.data()['image_url'].toString()}"
                    : _avatarUrl),
              ),
              accountName: Text(
                _snapshot != null
                    ? (_snapshot.data()['first'] != '' &&
                            _snapshot.data()['last'] != '')
                        ? "${capitalize(_snapshot.data()['first'].toString())} ${capitalize(_snapshot.data()['last'].toString())}"
                        : "Mr. XYZ"
                    : "Mr. XYZ",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                "$_userEmail",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Distance',
                    style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF0C0467),
                        fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xFF0C0467),
                          ),
                        ),
                        child: Text(
                          "${_distance}km",
                          style:
                              TextStyle(fontSize: 18, color: Color(0xFF0C0467)),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      CircleAvatar(
                        maxRadius: 18,
                        backgroundColor: Colors.red,
                        child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return changeDistanceDialog();
                                },
                              );
                            }),
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                'Acquired Items',
                style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF0C0467),
                    fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new AcquiredItems()));
              },
            ),
            ListTile(
              title: Text(
                'My Rent Items',
                style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF0C0467),
                    fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new MyRentItems()));
              },
            ),
            ListTile(
              title: Text(
                'Profile',
                style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF0C0467),
                    fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new UserProfile()));
              },
            ),
            ListTile(
              title: Text(
                'Contact Us',
                style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF0C0467),
                    fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return contactUsDialog();
                  },
                );
              },
            ),
            ListTile(
              title: Text(
                'Log Out',
                style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF0C0467),
                    fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                await _auth.signOut().then((_) {
                  Navigator.pushReplacement(context,
                      new MaterialPageRoute(builder: (context) => new LogIn()));
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0C0467)),
              ),
            )
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
              child: GridView.count(
                semanticChildCount: 2,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                mainAxisSpacing: 25,
                crossAxisSpacing: 60,
                crossAxisCount: 2,
                children: <Widget>[
                  categoryItems('Equipments', 'assets/equipment.png'),
                  categoryItems('Tools', 'assets/tool.png'),
                  categoryItems('Electronics', 'assets/electronics.png'),
                  categoryItems('Furniture', 'assets/furniture.png'),
                  categoryItems('Sport Goods', 'assets/sport_good.png'),
                  categoryItems('Appliances', 'assets/appliance.png'),
                  categoryItems('Outdoors', 'assets/outdoor.png'),
                  categoryItems('Real Estate', 'assets/real_estate.png'),
                  categoryItems('Machinery', 'assets/machinery.png'),
                  categoryItems('Others', 'assets/others.png'),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF0C0467),
        selectedLabelStyle: TextStyle(
            fontSize: 14,
            color: Color(0xFF0C0467),
            fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
        ),
        unselectedItemColor: Color(0xFF0C0467),
        iconSize: 26,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Post Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_page_outlined),
            label: 'Approvals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'My Posts',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) async {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddPost()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Approvals()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyPosts()),
      );
    }

    setState(() {
      _selectedIndex = index;
      print('$_selectedIndex');
    });
  }

  Widget categoryItems(String itemName, String itemUrl) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Posts(distance: _distance, category: itemName)),
        );
      },
      child: itemButton(itemName, itemUrl),
    );
  }

  Widget itemButton(String itemName, String iconUrl) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Color(0xFF0C0467), spreadRadius: 3)],
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Colors.white,
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 70,
            child: Image.asset(
              iconUrl,
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            flex: 30,
            child: Center(
              child: Text(
                itemName,
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF0C0467),
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void addDataToCloud(dataToUpload) {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('users');
    collectionReference
        .doc(_userId)
        .set(dataToUpload)
        .catchError((error, stackTrace) {
      print("FAILED TO ADD DATA: $error");
      print("STACKTRACE IS:  $stackTrace");
    });
    print("USER DATA ADDED!!!!!!!!!!!!");
  }

  Future<DocumentSnapshot> getDataOfUser(String userIdRequired) async {
    var docRef =
        FirebaseFirestore.instance.collection("users").doc(userIdRequired);
    await docRef.get().then((value) {
      setState(() {
        _snapshot = value;
      });
    });
    return _snapshot;
  }

  void _getCurrentUser() {
    User mCurrentUser = _auth.currentUser;
    if (mCurrentUser != null) {
      _userId = mCurrentUser.uid;
      _userEmail = mCurrentUser.email;
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LogIn()));
    }
  }

  Widget contactUsDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      title: Row(
        children: <Widget>[
          Icon(
            Icons.contact_mail_rounded,
            color: Color(0xFF0C0467),
          ),
          SizedBox(
            width: 5.0,
          ),
          Text(
            "Contact Us",
            style: TextStyle(color: Color(0xFF0C0467)),
            // style: GoogleFonts.righteous(color: Colors.red),
          ),
        ],
      ),
      insetPadding: EdgeInsets.all(10),
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('For any queries or claims, contact us at our email.'),
            SizedBox(height: 5.0),
            Text('rentall2021@gmail.com', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(
            'Send Now',
            style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                backgroundColor: Color(0xFF0C0467)),
            // style: GoogleFonts.righteous(
            //     color: Colors.white, backgroundColor: Color(0xFF0C0467)),
          ),
          onPressed: () {
            setState(() {
              _openUrl("mailto: rentall2021@gmail.com");
            });
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

  Future<void> _openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget changeDistanceDialog() {
    var distance;
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      title: Row(
        children: <Widget>[
          Icon(
            Icons.edit,
            color: Colors.red,
          ),
          Text(
            "Change Distance",
            style: TextStyle(color: Colors.red),
            // style: GoogleFonts.righteous(color: Colors.red),
          ),
        ],
      ),
      insetPadding: EdgeInsets.all(10),
      content: Container(
        width: 280,
        child: TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              distance = value;
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
            hintText: 'Enter the distance (KM)',
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text(
            'Change',
            style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                backgroundColor: Color(0xFF0C0467)),
            // style: GoogleFonts.righteous(
            //     color: Colors.white, backgroundColor: Color(0xFF0C0467)),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            if (distance != null) {
              setState(() {
                _distance = distance;
              });
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

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  void dispose() {
    _snapshot = null;
    _isLoading = null;
    _distance = null;
    super.dispose();
  }
}
